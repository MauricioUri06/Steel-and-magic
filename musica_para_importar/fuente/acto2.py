"""Acto 2: guitarra electrica + percusion protagonista. Mi frigio, 150 bpm, 64 compases (~1:42)."""
import numpy as np
from mus import *

BPM, BARS = 150, 64
song = Song("Steel and Magic - Acto 2", BPM, BARS, target_rms=-18.0, seed=31)

off8 = [0, 0, 1, 0, 0, 0, 3, 1]                      # raiz relativa a Mi por compas (ciclo de 8)
def off(bar): return off8[bar % 8]
RIFF = ["xx.xxx.xxx.xxxyx", "xx.xxx.xxx.xxzyz", "xx.xxx.xxx.xxxyx", "xx.xxx.xxx.xzxyx"]
def riff(bar): return RIFF[bar % 4]
SH = {'x': 0, 'y': 1, 'z': 3, 'w': 7, 'o': 12}

def sec(bar):
    if bar < 4: return 0.0
    if bar < 8: return 0.85
    if bar < 24: return 0.95
    if bar < 40: return 1.0
    if bar < 48: return 0.55
    return 1.05

in_break = lambda b: 40 <= b < 48

# ------------------------------------------------ guitarras ritmicas (palm-mute en semicorcheas / acordes abiertos en el estribillo)
gl = song.add(Part("Guitarra rit. izq.", 30, gain=1, pan=14, hall=0.1, room=0.2, hp=70, lp=5500, jit=0.004, vjit=5))
gr = song.add(Part("Guitarra rit. der.", 29, gain=2, pan=114, hall=0.1, room=0.2, hp=70, lp=5500, jit=0.004, vjit=5))
for bar in range(4, BARS):
    s = sec(bar)
    r = 40 + off(bar)
    for g in (gl, gr):
        if in_break(bar):
            if bar % 2 == 0:
                g.n(bar * 4, 0.45, r, int(100 * s)); g.n(bar * 4, 0.45, r + 7, int(96 * s))
                g.n(bar * 4 + 3, 0.2, r, int(90 * s)); g.n(bar * 4 + 3.5, 0.2, r, int(88 * s))
            continue
        if 24 <= bar < 40 or bar >= 56:
            # estribillo: acordes de potencia abiertos, golpes de corchea
            for i in range(8):
                v = int((104 if i % 4 == 0 else 92) * s)
                dur = 0.9 if i % 4 == 0 else 0.42
                for p in (r + 12, r + 19, r + 24):
                    g.n(bar * 4 + i * 0.5, dur, p, v)
        else:
            for i, ch in enumerate(riff(bar)):
                if ch == '.': continue
                v = int((102 if i % 4 == 0 else 92) * s)
                g.n(bar * 4 + i * 0.25, 0.2, r + SH[ch], v)
                g.n(bar * 4 + i * 0.25, 0.2, r + SH[ch] + 7, v - 6)

# ------------------------------------------------ bajo (pick) siguiendo el riff
ba = song.add(Part("Bajo", 34, gain=3, pan=64, hall=0.0, room=0.1, lp=2500, jit=0.003, vjit=5))
for bar in range(4, BARS):
    s = sec(bar); r = 28 + off(bar)
    if in_break(bar):
        for beat in (0, 1.5, 2, 3.5):
            ba.n(bar * 4 + beat, 0.45, r, int(100 * s))
    elif 24 <= bar < 40 or bar >= 56:
        for i in range(8):
            ba.n(bar * 4 + i * 0.5, 0.45, r if i % 2 == 0 else r + 12, int((104 if i % 2 == 0 else 86) * s))
    else:
        for i, ch in enumerate(riff(bar)):
            if ch == '.': continue
            ba.n(bar * 4 + i * 0.25, 0.2, r + SH[ch], int((100 if i % 4 == 0 else 88) * s))

# ------------------------------------------------ guitarra lider (distorsion + vibrato en notas largas)
leadA = ["E5/.5 E5/.5 G5/1 E5/.5 B4/.5 E5/1", "G5/.5 A5/.5 B5/1 A5/1 G5/1", "F5/1 A5/.5 C6/.5 B5/1 A5/1", "B5/1.5 G5/.5 E5/2",
         "E5/.5 E5/.5 G5/1 E5/.5 B5/.5 A5/1", "G5/1 B5/1 E6/2", "D6/1 B5/.5 G5/.5 D6/1 B5/1", "C6/1 A5/1 F5/1 E5/1"]
leadB = ["B5/2 A5/1 G5/1", "E6/3 D6/1", "C6/2 B5/1 A5/1", "B5/4",
         "G5/1 A5/1 B5/1 D6/1", "E6/2 G6/2", "F6/1.5 E6/.5 D6/1 B5/1", "C6/1 B5/1 A5/1 E5/1"]
ld = song.add(Part("Guitarra lider", 30, gain=7, pan=70, hall=0.35, room=0.15, hp=180, lp=7000, jit=0.006, vjit=4))
lh = song.add(Part("Guitarra lider 2", 29, gain=3, pan=50, hall=0.35, room=0.15, hp=150, lp=6000, jit=0.006, vjit=4))
ld.melody(8, leadA, vel=100, legato=0.95); ld.melody(16, leadA, vel=104, legato=0.95)
ld.melody(24, leadB, vel=106, legato=0.98); ld.melody(32, leadB, vel=110, legato=0.98)
ld.melody(48, leadA, vel=106, legato=0.95, transpose=0); ld.melody(56, leadB, vel=112, legato=0.98)
lh.melody(16, leadA, vel=92, legato=0.95, transpose=-12)
lh.melody(32, leadB, vel=96, legato=0.98, transpose=-12); lh.melody(48, leadA, vel=92, legato=0.95, transpose=-12)
lh.melody(56, leadB, vel=98, legato=0.98, transpose=-12)
# vibrato (pitch bend) en las notas largas del lider
for n in sorted(ld.notes):
    if n[1] >= 2.5:
        ld.vibrato(n[0], n[1], BPM, depth=0.28, rate=5.5, delay=0.3)
ld.cc(0, 1, 50)

# ------------------------------------------------ sintetizador sci-fi: arpegio (estribillos) y barrido de transicion
sy = song.add(Part("Arpegio sintetico", 80, gain=8, pan=96, hall=0.4, room=0.1, hp=300, jit=0.0, vjit=3))
for bar in list(range(24, 40)) + list(range(56, 64)):
    r = 64 + off(bar)
    for i in range(16):
        p = [r, r + 7, r + 12, r + 7][i % 4] + (12 if i % 8 >= 4 else 0)
        sy.n(bar * 4 + i * 0.25, 0.2, p, int(60 if i % 4 else 74))
sw = song.add(Part("Barrido", 95, gain=12, pan=64, hall=0.6, jit=0.0, vjit=0))
for bar in (7, 23, 39, 47, 55):
    sw.n(bar * 4, 4.0, 52, 70)
    sw.cc(bar * 4, 11, 40); sw.cc(bar * 4 + 3.9, 11, 127)

# ------------------------------------------------ bateria
dr = song.add(Part("Bateria (kit potente)", 16, drum=True, gain=-9, pan=64, hall=0.12, room=0.4, jit=0.0025, vjit=6))
def fill(bar, beat0=3.0, loud=1.0):
    seq = [50, 50, 48, 48, 47, 47, 45, 45] if beat0 == 3.0 else [50, 48, 47, 45] * 4
    step = 0.125 if beat0 == 3.0 else 0.25
    for i, p in enumerate(seq):
        dr.n(bar * 4 + beat0 + i * step, 0.2, p, int(min(127, (70 + i * 6) * loud)))
for bar in range(BARS):
    s = sec(bar)
    b4 = bar * 4
    if bar < 4:
        # intro tribal: toms y bombo
        for beat in (0, 2):
            dr.n(b4 + beat, 0.2, 36, 124)
        for beat, p in ((0.75, 45), (1.5, 45), (2.75, 47), (3.5, 45), (1, 47), (3, 47)):
            dr.n(b4 + beat, 0.2, p, 122)
    elif in_break(bar):
        # percusion tribal: toms + bombo, sin platos
        for beat in (0, 1.5, 2, 3.5):
            dr.n(b4 + beat, 0.2, 36, 106)
        for beat, p in ((0.5, 45), (1, 47), (2.5, 48), (3, 47), (3.25, 45), (3.75, 50)):
            dr.n(b4 + beat, 0.2, p, 90 + (bar - 40) * 2)
        dr.n(b4 + 1, 0.2, 38, 80); dr.n(b4 + 3, 0.2, 38, 84)
    elif 24 <= bar < 40 or bar >= 56:
        # estribillo: bombo doble, caja a 2 y 4, ride/hat abiertos
        for beat in (0, 0.5, 1.5, 2, 2.5, 3.5):
            dr.n(b4 + beat, 0.2, 36, int(104 * s))
        dr.n(b4 + 1, 0.2, 38, int(110 * s)); dr.n(b4 + 3, 0.2, 38, int(112 * s))
        for i in range(8):
            dr.n(b4 + i * 0.5, 0.3, 51 if i % 2 == 0 else 46, int((84 if i % 2 == 0 else 66) * s))
        if bar % 2 == 0: dr.n(b4, 2.0, 49, int(104 * s))
    else:
        # verso: doble bombo siguiendo el riff, caja a 2 y 4, hat a corcheas
        for i, ch in enumerate(riff(bar)):
            if ch != '.': dr.n(b4 + i * 0.25, 0.2, 36, int((100 if i % 4 == 0 else 80) * s))
        dr.n(b4 + 1, 0.2, 38, int(110 * s)); dr.n(b4 + 3, 0.2, 38, int(112 * s))
        for i in range(8): dr.n(b4 + i * 0.5, 0.2, 42, int((78 if i % 2 == 0 else 58) * s))
        if bar % 4 == 0: dr.n(b4, 2.0, 49, int(96 * s))
    if bar % 8 == 7: fill(bar)
for bar in (8, 24, 48, 56):
    dr.n(bar * 4, 3.0, 49, 112)

# ------------------------------------------------ percusion extra (cowbell, panderos, congas, maracas)
pe = song.add(Part("Percusion extra", 0, drum=True, gain=0, pan=80, hall=0.15, room=0.35, jit=0.003, vjit=7))
for bar in range(BARS):
    b4 = bar * 4
    if in_break(bar):
        for i in range(16):
            pe.n(b4 + i * 0.25, 0.2, 70, int(52 + (28 if i % 4 == 0 else (12 if i % 2 == 0 else 0))))   # maracas
        for beat, p in ((0, 64), (0.5, 63), (1, 63), (1.75, 64), (2.5, 63), (3, 64), (3.25, 63), (3.75, 63)):
            pe.n(b4 + beat, 0.2, p, 96)                                                                  # congas
        for beat in (0, 1, 2, 3):
            pe.n(b4 + beat, 0.2, 56, 96)                                                                 # cowbell
        for i in range(8):
            pe.n(b4 + i * 0.5 + 0.25, 0.2, 54, 64)                                                       # pandero a contratiempo
    elif bar < 4 or bar >= 4:
        for beat in (0, 1, 2, 3):
            pe.n(b4 + beat, 0.2, 56, int((82 if beat % 2 == 0 else 68) * max(sec(bar), 0.8)))            # cowbell
        if bar >= 8:
            for i in range(8):
                pe.n(b4 + i * 0.5 + 0.25, 0.2, 54, int(54 * max(sec(bar), 0.8)))                         # pandero

# ------------------------------------------------ timbales + taiko: peso grave en el tramo de percusion
ti = song.add(Part("Timbales", 47, gain=0, pan=64, hall=0.35, room=0.2, jit=0.003, vjit=4))
ta = song.add(Part("Taiko", 116, gain=-4, pan=64, hall=0.25, room=0.25, jit=0.003, vjit=4))
for bar in range(40, 48):
    k = (bar - 40) / 7.0
    for beat, p in ((0, 40), (1.5, 40), (2, 35), (3, 40), (3.5, 35)):
        ti.n(bar * 4 + beat, 0.5, p, int(70 + 36 * k))
    for beat in (0, 2):
        ta.n(bar * 4 + beat, 0.5, 40, int(96 + 24 * k))
        ta.n(bar * 4 + beat + 0.75, 0.3, 43, int(80 + 24 * k))
for bar in range(0, 4):
    for beat, p in ((0, 40), (1.5, 40), (2, 43), (3.5, 40)):
        ta.n(bar * 4 + beat, 0.5, p, 118)
    for beat in (0, 2):
        ti.n(bar * 4 + beat, 0.5, 40, 100)
for bar in range(8, BARS):
    if not in_break(bar) and bar % 4 == 0:
        ta.n(bar * 4, 0.5, 40, 90)

if __name__ == "__main__":
    out = song.render()
    os.makedirs("out", exist_ok=True)
    export(out, "out/musica_acto2")
    song.save_midi("out/musica_acto2.mid")
