"""Acto 1: cuerdas (piano, violines, violonchelo, guitarras) + vientos (flauta, flauta de pan). Mi menor, 156 bpm, 64 compases (~1:38). Frenetico y heroico.
v2: violines mas suaves (menos agudos, filtro, menos velocidad) y vientos llevando el tema."""
import numpy as np
from mus import *

BPM, BARS = 156, 64
song = Song("Steel and Magic - Acto 1", BPM, BARS, target_rms=-18.0, seed=21)

prog16 = ["Em", "Em", "C", "D", "Em", "Em", "C", "D", "Am", "Am", "C", "D", "Em", "B", "Em", "B"]
chord = {"Em": [64, 67, 71, 76], "C": [60, 64, 67, 72], "D": [62, 66, 69, 74], "Am": [60, 64, 69, 72], "B": [63, 66, 71, 75]}
root = {"Em": 40, "C": 36, "D": 38, "Am": 45, "B": 47}
gtr = {"Em": [52, 59, 64, 67, 71], "C": [48, 55, 60, 64, 67], "D": [50, 57, 62, 66], "Am": [45, 52, 57, 60, 64], "B": [47, 54, 59, 63, 66]}
pad = {"Em": [55, 59, 64], "C": [55, 60, 64], "D": [57, 62, 66], "Am": [57, 60, 64], "B": [54, 59, 63]}


def ch(bar):
    return prog16[bar % 16]


def sec(bar):
    """intensidad por seccion: 0.. 1"""
    if bar < 8: return 0.55 + 0.04 * bar
    if bar < 24: return 0.8
    if bar < 40: return 0.9
    if bar < 48: return 0.7 + 0.03 * (bar - 40)
    return 1.0


theme = ["E5/1 G5/.5 B5/.5 E6/1.5 D6/.5", "B5/1 G5/1 E5/2", "C6/1 E6/.5 G6/.5 E6/1.5 C6/.5", "D6/1 F#6/.5 A6/.5 F#6/1 D6/1",
         "E6/1 B5/.5 G5/.5 B5/1.5 E6/.5", "G6/1.5 F#6/.5 E6/1 D6/1", "C6/.5 D6/.5 E6/1 G6/1 E6/1", "D6/2 A5/1 F#5/1",
         "A5/1 C6/.5 E6/.5 A6/1.5 G6/.5", "E6/1 C6/1 A5/2", "G5/1 C6/.5 E6/.5 G6/1.5 E6/.5", "F#6/1 A6/1 D6/2",
         "B5/1 E6/.5 G6/.5 B6/1.5 G6/.5", "F#6/1 D#6/1 B5/2", "E6/.5 F#6/.5 G6/1 B6/1 G6/1", "D#6/1 F#6/1 B5/2"]

# ------------------------------------------------ piano: ostinato de semicorcheas (motor del tema)
pi = song.add(Part("Piano ostinato", 0, gain=-1, pan=50, hall=0.35, room=0.12, jit=0.004, vjit=5))
idx = [0, 1, 2, 3, 2, 1, 2, 1] * 2
for bar in range(BARS):
    c = chord[ch(bar)]
    for i, k in enumerate(idx):
        v = 60 + (10 if i % 4 == 0 else (4 if i % 2 == 0 else 0))
        pi.n(bar * 4 + i * 0.25, 0.23, c[k], int(v * sec(bar)))
pi.pedal(0, BARS)

# ------------------------------------------------ piano: acordes a contratiempo (desde el compas 8)
ps = song.add(Part("Piano acordes", 0, gain=-5, pan=76, hall=0.35, room=0.1, jit=0.005, vjit=5))
for bar in range(8, BARS):
    if 40 <= bar < 48 and bar % 2 == 0:
        continue
    c = [p - 12 for p in chord[ch(bar)][:3]] + [chord[ch(bar)][0]]
    for beat in (0.5, 1.5, 2.5, 3.5):
        for p in c:
            ps.n(bar * 4 + beat, 0.4, p, int(62 * sec(bar)))

# ------------------------------------------------ violonchelo: raices (corcheas)
ce = song.add(Part("Violonchelo", 42, gain=-2, pan=46, hall=0.3, room=0.1, jit=0.004, vjit=4))
for bar in range(BARS):
    r = root[ch(bar)]
    if bar < 8:
        ce.n(bar * 4, 1.9, r + 12, int(70 * sec(bar)))
        ce.n(bar * 4 + 2, 1.9, r + 12, int(66 * sec(bar)))
    else:
        for i in range(8):
            p = r + 12 if i % 4 == 3 else r + 12
            if i in (3, 7): p = r + 19 if bar % 2 == 0 else r + 12
            ce.n(bar * 4 + i * 0.5, 0.46, p, int((84 if i % 2 == 0 else 72) * sec(bar)))

# ------------------------------------------------ contrabajo pizzicato (desde el 24)
cb = song.add(Part("Contrabajo pizz.", 45, gain=-4, pan=60, hall=0.15, room=0.1, jit=0.004, vjit=4))
for bar in range(24, BARS):
    r = root[ch(bar)] - 12 if root[ch(bar)] >= 40 else root[ch(bar)]
    for beat in range(4):
        cb.n(bar * 4 + beat, 0.5, r + 12 if beat % 2 else r + 12, int(88 * sec(bar)))
cb.notes = [[b, d, (p if p >= 28 else p + 12), v] for b, d, p, v in cb.notes]

# ------------------------------------------------ cuerdas tremolo (pad de tension, compases 4-7, 40-63)
tr = song.add(Part("Cuerdas tremolo", 44, gain=8, pan=66, hall=0.5, room=0.05, jit=0, vjit=3, lp=4500))
for bar in list(range(4, 8)) + list(range(40, 64)):
    for p in pad[ch(bar)]:
        tr.n(bar * 4, 3.97, p + 12, int(56 * sec(bar)))
for bar in range(40, 48):
    tr.cc(bar * 4, 11, int(70 + 55 * (bar - 40) / 7.0))
tr.cc(48 * 4, 11, 120)

# ------------------------------------------------ violines: tema (compases 8-39 y 48-63), vibrato en notas largas
v1 = song.add(Part("Violines (tema)", 40, gain=0, pan=40, hall=0.5, room=0.08, jit=0.006, vjit=4, lp=4000))
vo = song.add(Part("Violines 8va grave", 41, gain=3, pan=90, hall=0.5, room=0.08, jit=0.006, vjit=4, lp=3200))
v1.melody(8, theme, vel=66, legato=0.97)
v1.melody(24, theme, vel=76, legato=0.97)
vo.melody(24, theme, vel=76, transpose=-12, legato=0.97)
v1.melody(48, theme, vel=82, legato=0.97)
vo.melody(48, theme, vel=86, transpose=-12, legato=0.97)
# expresion: vibrato de viola/violin con CC1 (modulacion) en todo el tema
for s0, e0 in ((8, 24), (24, 40), (48, 64)):
    for b in range(s0 * 4, e0 * 4, 2):
        v1.cc(b, 1, 70)


# ------------------------------------------------ vientos: flauta (tema) y flauta de pan (tramo suave)
def vib_notas(part, bar0, bars):
    """vibrato con pitch bend solo en las notas largas (>= 1.5 tiempos) de una melodia escrita con tokens"""
    for bi, txt in enumerate(bars):
        t = 0.0
        for tok in txt.split():
            nm, d = tok.split('/')
            d = float(d)
            if nm != 'r' and d >= 1.5:
                part.vibrato((bar0 + bi) * 4 + t, d * 0.97, BPM, depth=0.16, rate=5.2, delay=0.3)
            t += d

fl = song.add(Part("Flauta (tema)", 73, gain=-9, pan=58, hall=0.45, room=0.1, jit=0.006, vjit=4))
fl_intro = ["r/2 E5/1 G5/1", "B5/3 A5/1", "G5/1 E5/1 C5/2", "F#5/1 A5/1 D6/2"]
fl.melody(4, fl_intro, vel=66, legato=0.95)
vib_notas(fl, 4, fl_intro)
for b0, vv in ((8, 80), (24, 84), (48, 92)):
    fl.melody(b0, theme, vel=vv, legato=0.95)
    vib_notas(fl, b0, theme)
pf = song.add(Part("Flauta de pan", 75, gain=7, pan=50, hall=0.55, room=0.08, jit=0.008, vjit=4))
pan_lin = ["E5/2 A5/1 C6/1", "B5/3 A5/1", "G5/2 E5/1 G5/1", "A5/2 F#5/1 A5/1",
           "B5/2 G5/1 E5/1", "F#5/2 D#5/1 F#5/1", "G5/1 B5/1 E6/2", "D#6/3 r/1"]
pf.melody(40, pan_lin, vel=70, legato=0.96)
vib_notas(pf, 40, pan_lin)

# ------------------------------------------------ violin II: contramelodia rapida en el compas 40-47 (cuerdas rapidas)
fs = song.add(Part("Cuerdas rapidas", 48, gain=8, pan=36, hall=0.4, room=0.08, jit=0.004, vjit=4, lp=4500))
for bar in range(40, 48):
    c = chord[ch(bar)]
    for i in range(16):
        k = [0, 2, 1, 3][i % 4]
        fs.n(bar * 4 + i * 0.25, 0.22, c[k] + 12, int((52 + 4 * (bar - 40)) * (1.12 if i % 4 == 0 else 1.0)))

# ------------------------------------------------ guitarra de nylon: arpegio de corcheas (compases 8-23)
ny = song.add(Part("Guitarra nylon", 24, gain=4, pan=24, hall=0.25, room=0.15, jit=0.006, vjit=5))
for bar in range(8, 24):
    g = gtr[ch(bar)]
    for i, k in enumerate([0, 2, 3, 2, 1, 2, 3, 4 if len(g) > 4 else 2]):
        ny.n(bar * 4 + i * 0.5, 0.6, g[k], int(70 * sec(bar)))

# ------------------------------------------------ guitarra de acero: rasgueos de corcheas (desde el 24)
sg = song.add(Part("Guitarra acero", 25, gain=3, pan=100, hall=0.2, room=0.15, jit=0.008, vjit=5))
for bar in range(24, BARS):
    if 40 <= bar < 48 and bar % 2 == 1:
        continue
    g = gtr[ch(bar)]
    for i in range(8):
        down = (i % 2 == 0)
        sg.strum(bar * 4 + i * 0.5, g, 0.45, int((88 if i % 4 == 0 else (78 if down else 66)) * sec(bar)), BPM, spread_ms=11, down=down)

# ------------------------------------------------ arpa: glissando de entrada al tema (compas 7, 23, 47)
ha = song.add(Part("Arpa", 46, gain=-6, pan=84, hall=0.5, jit=0.004, vjit=4))
for bar in (7, 23, 39, 47):
    for i, p in enumerate([64, 67, 71, 76, 79, 83, 88, 91]):
        ha.n(bar * 4 + 3.0 + i * 0.12, 0.8, p, 72 + i * 2)

# ------------------------------------------------ percusion: taiko (pulso) y bateria
ta = song.add(Part("Taiko", 116, gain=-9, pan=64, hall=0.25, room=0.2, jit=0.003, vjit=5))
for bar in range(16, BARS):
    for beat in (0, 2):
        ta.n(bar * 4 + beat, 0.5, 40, int(88 * sec(bar)))
    if bar >= 24:
        ta.n(bar * 4 + 3.5, 0.3, 40, int(70 * sec(bar)))
for bar in (23, 39, 47, 63):
    for i in range(8):
        ta.n(bar * 4 + 2 + i * 0.25, 0.25, 40 if i % 2 == 0 else 43, 70 + i * 6)

dr = song.add(Part("Bateria", 0, drum=True, gain=-4, pan=64, hall=0.1, room=0.35, jit=0.003, vjit=6))
for bar in range(24, BARS):
    if 40 <= bar < 48 and bar % 2 == 1 and False:
        continue
    s = sec(bar)
    quiet = 40 <= bar < 48
    for i in range(8):
        dr.n(bar * 4 + i * 0.5, 0.2, 42, int((62 if i % 2 == 0 else 48) * s))      # hi-hat
    for beat in (0, 2):
        dr.n(bar * 4 + beat, 0.2, 36, int((98 if not quiet else 72) * s))           # bombo
    dr.n(bar * 4 + 1, 0.2, 38, int((96 if not quiet else 60) * s))                  # caja
    dr.n(bar * 4 + 3, 0.2, 38, int((100 if not quiet else 66) * s))
    if bar % 4 == 3:
        dr.n(bar * 4 + 2.5, 0.2, 36, int(86 * s))
        dr.n(bar * 4 + 3.5, 0.2, 38, int(82 * s))
for bar in (24, 48):
    dr.n(bar * 4, 2.0, 49, 100)        # platillo crash al entrar
for bar in (39, 47, 63):
    for i, p in enumerate([48, 48, 47, 47, 45, 45, 43, 43]):
        dr.n(bar * 4 + 2 + i * 0.25, 0.25, p, 76 + i * 6)    # redoble de toms

if __name__ == "__main__":
    out = song.render()
    os.makedirs("out", exist_ok=True)
    export(out, "out/musica_acto1")
    song.save_midi("out/musica_acto1.mid")
