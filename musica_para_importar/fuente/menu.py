"""Tema del menu: la calma antes de la tormenta. Re menor, 66 bpm, 32 compases (~1:56), piano solo que va sumando cuerdas."""
import numpy as np
from mus import *

BPM = 66
BARS = 32
song = Song("Steel and Magic - Menu", BPM, BARS, target_rms=-23.0, seed=11)

# progresion de 8 compases (se repite 4 veces)
roots  = [38, 34, 41, 36, 38, 34, 43, 45]          # raiz grave (D2 Bb1 F2 C2 D2 Bb1 G2 A2)
thirds = [3, 4, 4, 4, 3, 4, 3, 4]                  # tercera menor/mayor del acorde
strings_v = [[57, 62, 65], [58, 62, 65], [57, 60, 65], [55, 60, 64], [57, 62, 65], [58, 62, 65], [58, 62, 67], [57, 61, 64]]
harp_v    = [[62, 65, 69, 74], [62, 65, 70, 74], [60, 65, 69, 72], [60, 64, 67, 72], [62, 65, 69, 74], [62, 65, 70, 74], [62, 67, 70, 74], [61, 64, 69, 73]]
cel_v     = [[81, 86], [82, 86], [81, 84], [79, 84], [81, 86], [82, 86], [82, 86], [85, 88]]
cello_r   = [38, 46, 41, 36, 38, 46, 43, 45]

phraseA = ["A4/1.5 D5/.5 F5/2", "F5/1 E5/1 D5/2", "C5/1.5 F5/.5 A5/2", "G5/1 E5/1 G5/2",
           "D5/1 F5/1 A5/1.5 G5/.5", "F5/1.5 D5/.5 Bb4/2", "Bb4/1 D5/1 G5/1.5 F5/.5", "E5/2 C#5/1 A4/1"]
phraseB = ["D5/.5 E5/.5 F5/1 A5/1.5 G5/.5", "F5/1 D5/.5 F5/.5 Bb5/1 A5/1", "A5/1.5 G5/.5 F5/1 E5/1", "G5/1.5 E5/.5 C5/1 E5/1",
           "D5/1 F5/.5 A5/.5 D6/2", "D6/1 C6/1 Bb5/1 A5/1", "G5/1 Bb5/1 A5/1 G5/1", "F5/1 E5/1 C#5/1 E5/1"]


def fade(bar):
    """factor de dinamica: el final se apaga para que el loop vuelva a empezar en calma"""
    if bar >= 31:
        return 0.72
    if bar >= 30:
        return 0.85
    return 1.0


# ---------------------------------------------------------------- piano mano izquierda (arpegios de corcheas)
lh = song.add(Part("Piano mano izq.", 0, gain=-3, pan=54, hall=0.55, room=0.10, jit=0.006, vjit=5))
for bar in range(BARS):
    c = bar % 8
    r, t = roots[c], thirds[c]
    pitches = [r, r + 7, r + 12, r + 12 + t, r + 19, r + 12 + t, r + 12, r + 7]
    cyc = bar // 8
    base = [50, 54, 58, 60][cyc]
    for i, p in enumerate(pitches):
        v = base + (5 if i == 0 else (2 if i % 2 == 0 else 0))
        lh.n(bar * 4 + i * 0.5, 0.62, p, int(v * fade(bar)))
lh.pedal(0, BARS)

# ---------------------------------------------------------------- piano melodia
rh = song.add(Part("Piano melodia", 0, gain=0, pan=72, hall=0.6, room=0.10, jit=0.008, vjit=5))
for cyc in range(4):
    ph = phraseA if cyc < 2 else phraseB
    v = [60, 64, 68, 72][cyc]
    rh.melody(cyc * 8, ph, vel=v, legato=0.98)
# la ultima frase se apaga
for nt in rh.notes:
    nt[3] = int(nt[3] * fade(int(nt[0] // 4)))
rh.pedal(0, BARS)

# ---------------------------------------------------------------- octava grave del piano (compases 16-31)
oc = song.add(Part("Piano octava grave", 0, gain=-3, pan=60, hall=0.55, room=0.08, jit=0.008, vjit=4))
oc.melody(16, phraseB, vel=56, transpose=-12, legato=0.98)
oc.melody(24, phraseB, vel=60, transpose=-12, legato=0.98)
for nt in oc.notes:
    nt[3] = int(nt[3] * fade(int(nt[0] // 4)))
oc.pedal(16, 16)

# ---------------------------------------------------------------- celesta: destellos (compases 8-31)
ce = song.add(Part("Celesta", 8, gain=6, pan=88, hall=0.7, jit=0.01, vjit=6))
for bar in range(8, BARS):
    c = bar % 8
    a, b = cel_v[c]
    ce.n(bar * 4 + 1.5, 0.9, a, int(38 * fade(bar)))
    ce.n(bar * 4 + 3.25, 0.9, b, int(34 * fade(bar)))

# ---------------------------------------------------------------- cuerdas lentas (pad) con swell
st = song.add(Part("Cuerdas lentas", 49, gain=4, pan=64, hall=0.65, room=0.05, jit=0.0, vjit=2))
for bar in range(8, BARS):
    c = bar % 8
    for p in strings_v[c]:
        st.n(bar * 4, 3.98, p, int((42 + 4 * ((bar - 8) // 8)) * fade(bar)))
for cyc_start in (8, 16, 24):
    for k in range(32):                         # crescendo dentro de cada ciclo de 8 compases
        st.cc(cyc_start * 4 + k, 11, int(70 + 40 * (k / 31.0)))
st.cc(30 * 4, 11, 80)
st.cc(31 * 4, 11, 55)

# ---------------------------------------------------------------- violonchelo (raices largas, compases 16-31)
ve = song.add(Part("Violonchelo", 42, gain=-3, pan=50, hall=0.5, room=0.05, jit=0.0, vjit=2))
for bar in range(16, BARS):
    ve.n(bar * 4, 3.9, cello_r[bar % 8], int(52 * fade(bar)))

# ---------------------------------------------------------------- arpa (compases 24-31)
ha = song.add(Part("Arpa", 46, gain=-2, pan=96, hall=0.65, jit=0.008, vjit=5))
for bar in range(24, BARS):
    v = harp_v[bar % 8]
    for i, k in enumerate([0, 1, 2, 3, 2, 3, 2, 1]):
        ha.n(bar * 4 + i * 0.5, 0.8, v[k], int((46 + (4 if i % 4 == 0 else 0)) * fade(bar)))

# ---------------------------------------------------------------- pad calido (compases 24-31)
pa = song.add(Part("Pad calido", 89, gain=-3, pan=64, hall=0.7, jit=0.0, vjit=0))
for bar in range(24, BARS):
    for p in strings_v[bar % 8]:
        pa.n(bar * 4, 3.98, p - 12, int(36 * fade(bar)))

# ---------------------------------------------------------------- timbal: latido que sube (compases 24-29)
ti = song.add(Part("Timbal (latido)", 47, gain=-4, pan=64, hall=0.5, room=0.1, jit=0.003, vjit=3))
for bar in range(24, 30):
    k = (bar - 24) / 5.0
    for beat in (0, 2):
        ti.n(bar * 4 + beat, 0.5, 38, int(34 + 26 * k))
        ti.n(bar * 4 + beat + 0.72, 0.5, 38, int(26 + 22 * k))

if __name__ == "__main__":
    import sys
    out = song.render()
    os.makedirs("out", exist_ok=True)
    export(out, "out/musica_menu")
    song.save_midi("out/musica_menu.mid")
