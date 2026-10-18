"""Acto 3: graves y sombrio, frenetico. Do menor, 170 bpm, 64 compases (~1:30)."""
import numpy as np
from mus import *

BPM, BARS = 170, 64
song = Song("Steel and Magic - Acto 3", BPM, BARS, target_rms=-18.0, seed=41)

prog8 = ["Cm", "Cm", "Ab", "Bb", "Cm", "Cm", "Ab", "G"]
rt = {"Cm": 36, "Ab": 32, "Bb": 34, "G": 31}
third = {"Cm": 3, "Ab": 4, "Bb": 4, "G": 4}
tri = {"Cm": [55, 60, 63, 67], "Ab": [56, 60, 63, 68], "Bb": [58, 62, 65, 70], "G": [55, 59, 62, 67]}
def ch(bar):
    if 32 <= bar < 40:
        return ["Cm", "Cm", "Ab", "Ab", "Cm", "Cm", "G", "G"][bar % 8]
    return prog8[bar % 8]

def sec(bar):
    if bar < 8: return 0.78
    if bar < 16: return 0.9
    if bar < 32: return 1.0
    if bar < 40: return 0.88
    if bar < 48: return 0.62 + 0.04 * (bar - 40)
    return 1.05
in_break = lambda b: 40 <= b < 48

theme = ["C4/1 C4/.5 Eb4/.5 G4/2", "F4/1 Eb4/1 D4/1 C4/1", "Eb4/1.5 C4/.5 Ab3/2", "Bb3/1 D4/1 F4/2",
         "C4/1 Eb4/.5 G4/.5 C5/2", "Bb4/1 G4/1 Eb4/1 G4/1", "Ab4/1.5 G4/.5 F4/1 Eb4/1", "D4/1 G4/1 B4/2"]

# ------------------------------------------------ cuerdas graves: ostinato de semicorcheas (el motor)
cl = song.add(Part("Violonchelos ostinato", 42, gain=3, pan=40, hall=0.3, room=0.12, jit=0.003, vjit=4))
cb = song.add(Part("Contrabajos ostinato", 43, gain=7, pan=88, hall=0.3, room=0.12, jit=0.003, vjit=4))
fg = song.add(Part("Fagot ostinato", 70, gain=2, pan=64, hall=0.25, room=0.12, jit=0.003, vjit=4))
for bar in range(BARS):
    s = sec(bar)
    c = ch(bar); r = rt[c] + 12; t = third[c]
    P = [0, 0, 12, 0, 0, 0, 12, 0, 0, 12, 0, 12, t, 0, 7, t]
    if in_break(bar):
        P = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    for i, o in enumerate(P):
        v = int((92 if i % 4 == 0 else (78 if i % 2 == 0 else 66)) * s)
        cl.n(bar * 4 + i * 0.25, 0.22, r + o, v)
        cb.n(bar * 4 + i * 0.25, 0.22, r - 12 + o, int(v * 0.95))
        if not in_break(bar) and (bar >= 8 or i % 2 == 0):
            fg.n(bar * 4 + i * 0.25, 0.22, r + o, int(v * 0.9))

# ------------------------------------------------ tuba: raices pulsantes
tu = song.add(Part("Tuba", 58, gain=0, pan=64, hall=0.25, room=0.1, jit=0.004, vjit=4))
for bar in range(8, BARS):
    s = sec(bar); r = rt[ch(bar)]
    if in_break(bar):
        tu.n(bar * 4, 3.8, r, int(90 * s)); continue
    for i in range(8):
        tu.n(bar * 4 + i * 0.5, 0.42 if i % 2 else 0.46, r if i % 2 == 0 else r + (12 if i % 4 == 3 else 0), int((100 if i % 4 == 0 else 80) * s))

# ------------------------------------------------ metales: el tema (tromboncitos + trompas, trompeta en el climax)
tb = song.add(Part("Trombones", 57, gain=4, pan=44, hall=0.35, room=0.12, jit=0.005, vjit=4))
hn = song.add(Part("Trompas", 60, gain=9, pan=84, hall=0.35, room=0.12, jit=0.005, vjit=4))
tp = song.add(Part("Trompetas", 56, gain=4, pan=100, hall=0.35, room=0.12, jit=0.005, vjit=4))
for start, vel in ((8, 92), (16, 100), (24, 106), (48, 108), (56, 114)):
    tb.melody(start, theme, vel=vel, legato=0.93)
    hn.melody(start, theme, vel=vel - 6, transpose=12, legato=0.93)
for start in (24, 48, 56):
    tp.melody(start, theme, vel=100 + (6 if start >= 48 else 0), transpose=12, legato=0.93)

# ------------------------------------------------ cuerdas agudas tremolo (tension)
tr = song.add(Part("Cuerdas tremolo", 44, gain=9, pan=64, hall=0.5, room=0.05, jit=0, vjit=3))
for bar in list(range(16, 40)) + list(range(48, 64)):
    for p in [x + 12 for x in tri[ch(bar)]]:
        tr.n(bar * 4, 3.97, p, int(52 * sec(bar)))
for bar in range(32, 40):
    tr.cc(bar * 4, 11, int(70 + 50 * (bar - 32) / 7.0))
tr.cc(40 * 4, 11, 127)

# ------------------------------------------------ coro (oohs / coro de concierto): acordes largos
co = song.add(Part("Coro", 52, gain=8, pan=64, hall=0.65, room=0.05, jit=0, vjit=3))
for bar in list(range(16, 32)) + list(range(48, 64)):
    for p in tri[ch(bar)]:
        co.n(bar * 4, 3.97, p, int(56 * sec(bar)))

# ------------------------------------------------ organo de iglesia: puente y final
og = song.add(Part("Organo", 19, gain=-3, pan=64, hall=0.55, room=0.05, jit=0, vjit=0))
for bar in list(range(32, 48)) + list(range(56, 64)):
    c = ch(bar); r = rt[c]
    for p in (r, r + 12, r + 19, r + 12 + third[c]):
        og.n(bar * 4, 3.97, p, int(70 * (0.8 if in_break(bar) else 1.0)))

# ------------------------------------------------ campana tubular: tañido en cada inicio de frase, tritono en los remates
bl = song.add(Part("Campana tubular", 14, gain=4, pan=64, hall=0.7, room=0.1, jit=0.003, vjit=3))
for bar in range(0, BARS, 4):
    bl.n(bar * 4, 3.9, 60, 100); bl.n(bar * 4, 3.9, 48, 90)
for bar in (7, 15, 23, 31, 39, 47, 55, 63):
    bl.n(bar * 4 + 2, 1.9, 66, 92); bl.n(bar * 4 + 3, 0.9, 60, 88)

# ------------------------------------------------ sintetizador oscuro: bajo sub y arpegio filtrado (sci-fi)
sb = song.add(Part("Bajo sintetico", 38, gain=-2, pan=64, hall=0.0, room=0.1, lp=1800, jit=0.0, vjit=3))
for bar in range(16, BARS):
    if in_break(bar): continue
    s = sec(bar); r = rt[ch(bar)]
    for i in range(8):
        sb.n(bar * 4 + i * 0.5, 0.44, r, int((98 if i % 2 == 0 else 80) * s))
sa = song.add(Part("Arpegio sintetico", 81, gain=12, pan=100, hall=0.4, room=0.1, hp=200, lp=2200, jit=0.0, vjit=3))
for bar in list(range(32, 40)) + list(range(56, 64)):
    c = ch(bar); r = rt[c] + 36; t = third[c]
    for i in range(16):
        p = [r, r + 7, r + 12, r + 7, r + t, r + 7, r + 12 + t, r + 7][i % 8]
        sa.n(bar * 4 + i * 0.25, 0.2, p, int(58 if i % 4 else 76))
rv = song.add(Part("Platillo inverso", 119, gain=14, pan=64, hall=0.3, jit=0, vjit=0))
for bar in (7, 15, 23, 31, 39, 47, 55):
    rv.n(bar * 4 + 1.5, 2.5, 60, 90)

# ------------------------------------------------ percusion: timbales + taiko + kit potente
ti = song.add(Part("Timbales", 47, gain=-7, pan=64, hall=0.35, room=0.2, jit=0.003, vjit=4))
ta = song.add(Part("Taiko", 116, gain=-7, pan=64, hall=0.25, room=0.25, jit=0.003, vjit=4))
for bar in range(BARS):
    s = sec(bar); b4 = bar * 4
    for beat in (0, 1.5, 2.5):
        ta.n(b4 + beat, 0.4, 36, int(100 * s))
    if not in_break(bar):
        for beat in (0.75, 3.5):
            ta.n(b4 + beat, 0.3, 43, int(86 * s))
    for beat in (0, 2):
        ti.n(b4 + beat, 0.5, 36 if ch(bar) in ("Cm",) else rt[ch(bar)], int(96 * s))
    if bar % 8 == 7:
        for i in range(8):
            ti.n(b4 + 2 + i * 0.25, 0.25, 36 + (0 if i % 2 == 0 else 7), int(70 + i * 7))

dr = song.add(Part("Bateria (kit potente)", 16, drum=True, gain=-9, pan=64, hall=0.12, room=0.4, jit=0.0025, vjit=6))
for bar in range(BARS):
    s = sec(bar); b4 = bar * 4
    if bar < 8:
        if bar >= 4:
            for beat in (0, 1.5, 2):
                dr.n(b4 + beat, 0.2, 36, int(104 * s))
            dr.n(b4 + 1, 0.2, 45, int(100 * s)); dr.n(b4 + 3, 0.2, 47, int(104 * s))
    elif in_break(bar):
        dr.n(b4, 0.2, 36, int(108 * s))
        for beat, p in ((1.5, 45), (2.5, 47), (3.25, 48), (3.75, 45)):
            dr.n(b4 + beat, 0.2, p, int(94 * s))
    elif 32 <= bar < 40:
        for i in range(8):
            dr.n(b4 + i * 0.5, 0.2, [45, 47, 48, 47][i % 4], int((100 if i % 2 == 0 else 84) * s))
        for beat in (0, 2):
            dr.n(b4 + beat, 0.2, 36, int(106 * s))
        dr.n(b4 + 1, 0.2, 38, int(104 * s)); dr.n(b4 + 3, 0.2, 38, int(108 * s))
    else:
        for beat in (0, 0.5, 0.75, 1.5, 2, 2.5, 2.75, 3.5):
            dr.n(b4 + beat, 0.2, 36, int((108 if beat % 1 == 0 else 90) * s))
        dr.n(b4 + 1, 0.2, 38, int(112 * s)); dr.n(b4 + 3, 0.2, 38, int(114 * s))
        for i in range(8):
            dr.n(b4 + i * 0.5, 0.2, 42 if i % 2 else 46, int((70 if i % 2 else 80) * s))
        if bar % 2 == 0: dr.n(b4, 2.0, 52, int(96 * s))
    if bar % 8 == 7:
        for i, p in enumerate([50, 50, 48, 48, 47, 47, 45, 45]):
            dr.n(b4 + 3 + i * 0.125, 0.2, p, min(127, 76 + i * 7))
for bar in (8, 16, 24, 48, 56):
    dr.n(bar * 4, 3.0, 49, 112)

if __name__ == "__main__":
    out = song.render()
    os.makedirs("out", exist_ok=True)
    export(out, "out/musica_acto3")
    song.save_midi("out/musica_acto3.mid")
