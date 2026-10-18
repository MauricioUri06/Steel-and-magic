"""Mini secuenciador + renderizador para Steel and Magic.
Compone en codigo (notas por partes), renderiza cada parte por separado con un SoundFont (TinySoundFont),
les agrega reverb por convolucion, mezcla, hace el loop perfecto (la cola se pliega sobre el inicio)
y exporta WAV/OGG y MIDI.
"""
import os
import numpy as np
import tinysoundfont
import mido
import soundfile as sf
import subprocess
from scipy.signal import fftconvolve, butter, sosfilt

SF2 = "/home/claude/mrbumpy409/generaluser-gs/GeneralUser-GS.sf2"
SR = 44100
_BASE = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}


def N(name):
    """'F#4' -> 66, 'Bb3' -> 58"""
    i = 1
    acc = 0
    while i < len(name) and name[i] in '#b':
        acc += 1 if name[i] == '#' else -1
        i += 1
    return 12 * (int(name[i:]) + 1) + _BASE[name[0]] + acc


class Part:
    def __init__(s, name, prog, drum=False, gain=0.0, pan=64, hall=0.0, room=0.0,
                 hp=None, lp=None, jit=0.004, vjit=5, bank=0):
        s.name, s.prog, s.drum, s.gain, s.pan = name, prog, drum, gain, pan
        s.hall, s.room, s.hp, s.lp, s.jit, s.vjit, s.bank = hall, room, hp, lp, jit, vjit, bank
        s.notes = []   # [beat, dur, pitch, vel]
        s.ccs = []     # (beat, controller, value)
        s.bends = []   # (beat, value 0..16383)

    def n(s, beat, dur, pitch, vel):
        if isinstance(pitch, str):
            pitch = N(pitch)
        s.notes.append([float(beat), float(dur), int(pitch), int(vel)])

    def cc(s, beat, num, val):
        s.ccs.append((float(beat), num, int(val)))

    # ---- ayudas de composicion ----
    def melody(s, bar0, bars, vel=96, transpose=0, legato=0.96, vel_curve=None):
        """bars: lista de strings por compas, tokens 'E5/1.5' o 'r/1' (silencio). Cada compas debe sumar 4 tiempos."""
        for bi, txt in enumerate(bars):
            t = 0.0
            for tok in txt.split():
                nm, d = tok.split('/')
                d = float(d)
                if nm != 'r':
                    v = vel
                    if t % 1 == 0 and t % 2 == 0:
                        v += 4
                    s.n((bar0 + bi) * 4 + t, d * legato, N(nm) + transpose, v)
                t += d
            assert abs(t - 4) < 1e-6, "compas %d suma %.3f: %s" % (bar0 + bi, t, txt)

    def pedal(s, bar0, nbars, every=1):
        """pedal de sustain del piano: se suelta y se vuelve a pisar al inicio de cada 'every' compases"""
        for b in range(bar0, bar0 + nbars, every):
            s.cc(b * 4 - 0.06, 64, 0)
            s.cc(b * 4 + 0.03, 64, 127)
        s.cc((bar0 + nbars) * 4 - 0.06, 64, 0)

    def vibrato(s, beat, dur, bpm, depth=0.22, rate=5.6, delay=0.35):
        """vibrato con pitch bend (rango +-2 semitonos) sobre una nota larga"""
        spb = 60.0 / bpm
        t = 0.0
        step = 0.04
        total = dur * spb
        while t < total:
            if t > delay:
                a = min(1.0, (t - delay) / 0.4) * depth
                v = 8192 + int(a / 2.0 * 8191 * np.sin(2 * np.pi * rate * (t - delay)))
            else:
                v = 8192
            s.bends.append((beat + t / spb, v))
            t += step
        s.bends.append((beat + dur, 8192))

    def strum(s, beat, pitches, dur, vel, bpm, spread_ms=14, down=True):
        ps = list(pitches) if down else list(reversed(pitches))
        for i, p in enumerate(ps):
            off = i * spread_ms / 1000.0 * bpm / 60.0
            s.n(beat + off, dur, p, vel - i * 2 if down else vel - (len(ps) - i) * 1)


class Song:
    def __init__(s, name, bpm, bars, target_rms=-18.0, tail=4.0, seed=1):
        s.name, s.bpm, s.bars, s.target_rms, s.tail, s.seed = name, bpm, bars, target_rms, tail, seed
        s.parts = []

    def add(s, part):
        s.parts.append(part)
        return part

    @property
    def spb(s):
        return 60.0 / s.bpm

    @property
    def L(s):
        return int(round(s.bars * 4 * s.spb * SR))

    # ------------------------------------------------------------------ MIDI
    def save_midi(s, path):
        """Escribe el MIDI. MIDI solo tiene 15 canales melodicos + 1 de bateria por archivo:
        si hay mas instrumentos, el excedente va a <nombre>_parte2.mid (mismo tempo, mismos compases)."""
        melodic = [p for p in s.parts if not p.drum]
        drums = [p for p in s.parts if p.drum]
        groups = [melodic[i:i + 15] for i in range(0, max(1, len(melodic)), 15)]
        paths = []
        for gi, grp in enumerate(groups):
            pth = path if gi == 0 else path.replace('.mid', '_parte%d.mid' % (gi + 1))
            s._write_midi(pth, grp + (drums if gi == 0 else []))
            paths.append(pth)
        return paths

    def _write_midi(s, path, parts):
        mid = mido.MidiFile(ticks_per_beat=480)
        tr0 = mido.MidiTrack()
        tr0.append(mido.MetaMessage('set_tempo', tempo=mido.bpm2tempo(s.bpm), time=0))
        tr0.append(mido.MetaMessage('track_name', name=s.name, time=0))
        tr0.append(mido.MetaMessage('time_signature', numerator=4, denominator=4, time=0))
        mid.tracks.append(tr0)
        ch = 0
        for p in parts:
            tr = mido.MidiTrack()
            tr.append(mido.MetaMessage('track_name', name=p.name, time=0))
            if p.drum:
                c = 9
                tr.append(mido.Message('control_change', channel=c, control=0, value=p.bank if p.bank else 0, time=0))
                tr.append(mido.Message('program_change', channel=c, program=p.prog, time=0))
            else:
                if ch == 9:
                    ch += 1
                c = ch
                ch += 1
                tr.append(mido.Message('program_change', channel=c, program=p.prog, time=0))
            tr.append(mido.Message('control_change', channel=c, control=10, value=p.pan, time=0))
            ev = []
            for b, d, pit, v in p.notes:
                ev.append((b, 1, mido.Message('note_on', channel=c, note=pit, velocity=v)))
                ev.append((b + d, 0, mido.Message('note_off', channel=c, note=pit, velocity=0)))
            for b, num, val in p.ccs:
                ev.append((b, 0, mido.Message('control_change', channel=c, control=num, value=val)))
            for b, val in p.bends:
                ev.append((b, 0, mido.Message('pitchwheel', channel=c, pitch=val - 8192)))
            ev.sort(key=lambda e: (e[0], e[1]))
            last = 0
            for b, _, m in ev:
                tick = int(round(b * 480))
                m.time = max(0, tick - last)
                last += m.time
                tr.append(m)
            mid.tracks.append(tr)
        mid.save(path)

    # ------------------------------------------------------------------ audio
    def _render_part(s, p, idx, total):
        rng = np.random.default_rng(s.seed * 1000 + idx)
        syn = tinysoundfont.Synth(gain=-6.0, samplerate=SR)
        sfid = syn.sfload(SF2)
        chn = 9 if p.drum else 0
        if p.drum:
            syn.program_select(9, sfid, 128, p.prog)
        else:
            syn.program_select(0, sfid, p.bank, p.prog)
        syn.control_change(chn, 7, 127)
        syn.control_change(chn, 10, p.pan)
        ev = []
        spb = s.spb
        for b, d, pit, v in p.notes:
            t0 = b * spb + (rng.normal(0, p.jit) if p.jit else 0.0)
            t0 = max(0.0, t0)
            vv = int(np.clip(v + (rng.integers(-p.vjit, p.vjit + 1) if p.vjit else 0), 1, 127))
            t1 = max(t0 + 0.02, b * spb + d * spb)
            ev.append((t0, 2, 'on', pit, vv))
            ev.append((t1, 1, 'off', pit, 0))
        for b, num, val in p.ccs:
            ev.append((b * spb, 0, 'cc', num, val))
        for b, val in p.bends:
            ev.append((b * spb, 0, 'bend', val, 0))
        ev.sort(key=lambda e: (e[0], e[1]))
        chunks = []
        pos = 0
        for t, _, kind, a, b2 in ev:
            if t >= total / SR:
                continue
            n = int(round(t * SR)) - pos
            if n > 0:
                chunks.append(np.frombuffer(syn.generate(n), dtype=np.float32).reshape(-1, 2).copy())
                pos += n
            if kind == 'on':
                syn.noteon(chn, a, b2)
            elif kind == 'off':
                syn.noteoff(chn, a)
            elif kind == 'cc':
                syn.control_change(chn, a, b2)
            elif kind == 'bend':
                syn.pitchbend(chn, int(a))
        n = total - pos
        if n > 0:
            chunks.append(np.frombuffer(syn.generate(n), dtype=np.float32).reshape(-1, 2).copy())
        out = np.vstack(chunks)[:total].astype(np.float64)
        if p.hp:
            out = sosfilt(butter(2, p.hp, 'highpass', fs=SR, output='sos'), out, axis=0)
        if p.lp:
            out = sosfilt(butter(2, p.lp, 'lowpass', fs=SR, output='sos'), out, axis=0)
        return out

    @staticmethod
    def _ir(rt60, predelay, damp, seed):
        rng = np.random.default_rng(seed)
        n = int(rt60 * SR)
        t = np.arange(n) / SR
        env = 10 ** (-3.0 * t / rt60)
        ir = rng.standard_normal((n, 2)) * env[:, None]
        ir = sosfilt(butter(2, damp, 'lowpass', fs=SR, output='sos'), ir, axis=0)
        ir = sosfilt(butter(2, 120, 'highpass', fs=SR, output='sos'), ir, axis=0)
        ir = np.vstack([np.zeros((int(predelay * SR), 2)), ir])
        return ir / np.sqrt(np.sum(ir ** 2, axis=0, keepdims=True))

    def render(s, hall_rt=2.2, room_rt=0.7, report=True):
        total = s.L + int(s.tail * SR)
        dry = np.zeros((total, 2))
        hall_bus = np.zeros((total, 2))
        room_bus = np.zeros((total, 2))
        stats = []
        for i, p in enumerate(s.parts):
            st = s._render_part(p, i, total) * 10 ** (p.gain / 20.0)
            dry += st
            hall_bus += st * p.hall
            room_bus += st * p.room
            rms = 20 * np.log10(np.sqrt(np.mean(st ** 2)) + 1e-9)
            stats.append((p.name, rms, 20 * np.log10(np.max(np.abs(st)) + 1e-9)))
        mix = dry
        if np.any(hall_bus):
            mix = mix + fftconvolve(hall_bus, s._ir(hall_rt, 0.022, 5200, s.seed + 11), axes=0)[:total] * 0.5
        if np.any(room_bus):
            mix = mix + fftconvolve(room_bus, s._ir(room_rt, 0.008, 6500, s.seed + 23), axes=0)[:total] * 0.5
        # loop perfecto: la cola (reverb y notas que cruzan el final) se suma al inicio
        L = s.L
        out = mix[:L].copy()
        tail = mix[L:L + int(s.tail * SR)]
        out[:len(tail)] += tail
        # normalizacion: RMS objetivo y limitador suave
        rms = np.sqrt(np.mean(out ** 2))
        g = 10 ** (s.target_rms / 20.0) / rms
        out = out * g
        out = np.tanh(out * 0.95) / np.tanh(0.95) * 0.98 if np.max(np.abs(out)) > 0.9 else out
        peak = np.max(np.abs(out))
        if peak > 0.97:
            out *= 0.97 / peak
        # igualar el volumen final (despues del limitador) para que todos los temas suenen parejos
        g2 = 10 ** (s.target_rms / 20.0) / np.sqrt(np.mean(out ** 2))
        out *= min(g2, 0.97 / np.max(np.abs(out)))
        if report:
            print("== %s: %.1f s, %d compases a %d bpm, RMS final %.1f dB, pico %.2f" % (
                s.name, L / SR, s.bars, s.bpm, 20 * np.log10(np.sqrt(np.mean(out ** 2))), np.max(np.abs(out))))
            for nme, r, pk in stats:
                print("   %-22s RMS %6.1f dB   pico %6.1f dB" % (nme, r + 20 * np.log10(g), pk + 20 * np.log10(g)))
        return out.astype(np.float32)


def export(out, path_base, quality=6):
    sf.write(path_base + '.wav', out, SR, subtype='PCM_16')
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', path_base + '.wav', '-c:a', 'libvorbis', '-q:a', str(quality),
                    path_base + '.ogg'], check=True)
