"""Tres sonidos de una sola vez para Steel and Magic:
 1) sfx_muerte      violin triste (Si menor)
 2) sfx_jefe        fanfarria corta de victoria sobre un jefe (Re mayor)
 3) sfx_victoria    gran fanfarria de la ultima oleada (Re mayor, cita el tema del menu en mayor)"""
import sys, os
import numpy as np
from mus import *


def ramp(part, b0, v0, b1, v1, step=0.0625):
    """cambio de volumen (CC11) en rampa, con muchos pasos chicos: sin saltos que se oigan como cortes"""
    n = max(1, int(round((b1 - b0) / step)))
    for i in range(n + 1):
        part.cc(b0 + (b1 - b0) * i / n, 11, int(round(v0 + (v1 - v0) * i / n)))


def chord(part, beat, dur, pitches, vel):
    for p in pitches:
        part.n(beat, dur, p, vel)


# ============================================================================ 1) MUERTE DEL JUGADOR
def muerte():
    BPM = 80
    s = Song("SFX muerte del jugador", BPM, 4, target_rms=-20.0, tail=4.0, seed=31)

    # violin solista: un suspiro que sube y cae, y se apaga en la tonica (Si menor)
    vn = s.add(Part("Violin solista", 40, gain=7, pan=66, hall=0.85, room=0.08, jit=0.0, vjit=2))
    linea = [  # (compas, tiempo, duracion, nota, velocidad)
        (1.0, 1.0, "F#5", 58),   # la frase arranca despues de un tiempo de silencio
        (2.0, 2.0, "D6", 74),    # salto hacia arriba...
        (4.0, 1.0, "C#6", 66),   # ...y empieza a caer
        (5.0, 1.5, "B5", 64),
        (6.5, 0.5, "A5", 58),
        (7.0, 2.0, "G5", 66),
        (9.0, 1.5, "E5", 56),    # caida sobre el acorde de Fa# (dominante)
        (10.5, 0.5, "D5", 50),
        (11.0, 2.0, "C#5", 54),
        (13.0, 4.0, "B4", 60),   # reposo final, largo, se apaga
    ]
    for i, (b, d, nm, v) in enumerate(linea):
        ligada = 0.06 if i < len(linea) - 1 else 0.0     # la nota se solapa un poco con la siguiente: sin huecos entre notas
        vn.n(b, d + ligada, nm, v)
    for b, d, nm, v in linea:
        if d >= 2:
            vn.vibrato(b, d, BPM, depth=0.20, rate=5.0, delay=0.6)
    # el violin respira: el volumen sube y baja en rampas suaves (nunca por debajo de 82, para que no se corte)
    for i, (b, d, nm, v) in enumerate(linea):
        pico = b + d * 0.45
        ramp(vn, b, 88, pico, 112)
        fin = b + d if i < len(linea) - 1 else b + d + 2.0
        ramp(vn, pico, 112, fin, 88 if i < len(linea) - 1 else 40, step=0.125)

    # violonchelo grave: raiz de cada acorde
    ce = s.add(Part("Violonchelo", 42, gain=-4, pan=44, hall=0.7, room=0.05, jit=0.0, vjit=2))
    for beat, nm, d in [(0, "B2", 4), (4, "G2", 4), (8, "F#2", 4), (12, "B2", 6)]:
        ce.n(beat, d, nm, 46)
        ce.n(beat, d, N(nm) + 7, 40)   # quinta

    # cuerdas lentas: acordes pianissimo (Bm | G | F# con la sensible | Bm)
    st = s.add(Part("Cuerdas lentas", 49, gain=4, pan=64, hall=0.8, room=0.05, jit=0.0, vjit=2))
    acordes = [(0, ["B3", "D4", "F#4"]), (4, ["B3", "D4", "G4"]), (8, ["A#3", "C#4", "F#4"]), (12, ["B3", "D4", "F#4"])]
    for beat, ps in acordes:
        d = 4 if beat < 12 else 6
        for p in ps:
            st.n(beat, d, p, 58)
        ramp(st, beat, 90, beat + d * 0.5, 118, step=0.125)
        ramp(st, beat + d * 0.5, 118, beat + d, 95, step=0.125)

    # un toque grave de timbal al inicio y otro al final (como una campanada)
    ti = s.add(Part("Timbal grave", 47, gain=-6, pan=64, hall=0.7, room=0.2, jit=0.0, vjit=0))
    ti.n(0, 1.5, "B1", 54)
    ti.n(12, 2.0, "B1", 46)
    return s


# ============================================================================ 2) JEFE DERROTADO
def jefe():
    BPM = 108
    s = Song("SFX jefe derrotado", BPM, 4, target_rms=-16.5, tail=3.5, seed=41)

    tp = s.add(Part("Trompetas", 56, gain=6, pan=92, hall=0.45, room=0.1, jit=0.003, vjit=3))
    tp.melody(0, ["A4/.5 A4/.5 D5/1 F#5/1 A5/1",
                  "G5/1.5 F#5/.5 E5/1 F#5/1",
                  "G5/.5 F#5/.5 G5/.5 A5/.5 B5/1 C#6/1",
                  "D6/4"], vel=96, legato=0.92)

    hn = s.add(Part("Trompas", 60, gain=2, pan=44, hall=0.5, room=0.1, jit=0.004, vjit=3))
    for beat, d, ps in [(0, 4, ["A3", "D4", "F#4"]), (4, 2, ["B3", "D4", "G4"]), (6, 2, ["C#4", "E4", "A4"]),
                        (8, 2, ["B3", "D4", "F#4"]), (10, 2, ["C#4", "E4", "A4"]), (12, 5, ["A3", "D4", "F#4"])]:
        chord(hn, beat, d * 0.96, ps, 80)

    st = s.add(Part("Cuerdas", 48, gain=-1, pan=64, hall=0.55, room=0.08, jit=0.002, vjit=3))
    for beat, d, ps in [(0, 4, ["D4", "F#4", "A4", "D5"]), (4, 2, ["D4", "G4", "B4"]), (6, 2, ["E4", "A4", "C#5"]),
                        (8, 2, ["D4", "F#4", "B4"]), (10, 2, ["E4", "A4", "C#5"]), (12, 5, ["D4", "F#4", "A4", "D5", "F#5"])]:
        chord(st, beat, d * 0.97, ps, 72)

    ba = s.add(Part("Bajo (violonchelos y contrabajos)", 43, gain=-1, pan=64, hall=0.3, room=0.1, jit=0.002, vjit=3))
    for beat, d, nm in [(0, 4, "D2"), (4, 2, "G2"), (6, 2, "A2"), (8, 2, "B2"), (10, 2, "A2"), (12, 5, "D2")]:
        ba.n(beat, d * 0.95, nm, 92)

    ti = s.add(Part("Timbales", 47, gain=-5, pan=64, hall=0.4, room=0.25, jit=0.002, vjit=4))
    for beat in (0, 4, 8):
        ti.n(beat, 0.5, "D3", 100)
    for k in range(12):            # redoble que sube hacia el final (tiempos 13 a 16)
        ti.n(12 + k * 0.25, 0.25, "D3", 60 + int(k * 3.5))
    ti.n(15.5, 1.0, "D3", 118)

    dr = s.add(Part("Platillo y bombo", 16, drum=True, gain=-8, pan=64, hall=0.2, room=0.4, jit=0.0, vjit=3))
    dr.n(0, 0.5, 49, 90)           # crash al inicio
    dr.n(0, 0.5, 36, 100)
    dr.n(12, 0.5, 36, 100)
    dr.n(16, 1.0, 49, 118)         # crash final
    dr.n(16, 1.0, 36, 112)
    return s


# ============================================================================ 3) ULTIMA OLEADA
def victoria():
    BPM = 112
    s = Song("SFX victoria final", BPM, 5, target_rms=-15.5, tail=2.5, seed=51)

    # --- compases 1-2: el tema del menu convertido a Re mayor (cuerdas con trompas y coro)
    vn = s.add(Part("Cuerdas (tema del menu)", 48, gain=7, pan=64, hall=0.6, room=0.08, jit=0.002, vjit=3))
    vn.melody(0, ["A4/1.5 D5/.5 F#5/2",
                  "F#5/1 E5/1 D5/2"], vel=80, legato=1.0)
    for beat, d, ps in [(8, 4, ["D5", "F#5", "A5", "D6"]), (12, 2, ["D5", "G5", "B5"]), (14, 2, ["E5", "A5", "C#6"]),
                        (16, 7, ["D5", "F#5", "A5", "D6", "F#6"])]:
        chord(vn, beat, d * 0.97, ps, 78)

    hn = s.add(Part("Trompas", 60, gain=3, pan=40, hall=0.5, room=0.1, jit=0.004, vjit=3))
    for beat, d, ps, v in [(0, 4, ["A3", "D4", "F#4"], 66), (4, 4, ["B3", "D4", "F#4"], 70), (8, 4, ["A3", "D4", "F#4", "A4"], 88),
                           (12, 2, ["B3", "D4", "G4"], 88), (14, 2, ["C#4", "E4", "A4"], 88), (16, 7, ["A3", "D4", "F#4", "A4", "D5"], 92)]:
        chord(hn, beat, d * 0.97, ps, v)

    co = s.add(Part("Coro", 52, gain=7, pan=64, hall=0.75, room=0.05, jit=0.0, vjit=3))
    for beat, d, ps in [(4, 4, ["D5", "F#5", "B5"]), (8, 4, ["D5", "F#5", "A5"]), (12, 2, ["D5", "G5", "B5"]),
                        (14, 2, ["E5", "A5", "C#6"]), (16, 7, ["D5", "F#5", "A5", "D6"])]:
        chord(co, beat, d * 0.98, ps, 74)
        ramp(co, beat, 85, beat + d * 0.6, 118, step=0.125)

    # --- compases 3-5: fanfarria de trompetas
    tp = s.add(Part("Trompetas", 56, gain=3, pan=94, hall=0.45, room=0.1, jit=0.003, vjit=3))
    tp.melody(2, ["D5/.5 F#5/.5 A5/1 D6/2",
                  "B5/1 A5/1 G5/1 A5/1"], vel=100, legato=0.95)
    tp.n(16, 1, "D6", 104)
    tp.n(17, 1, "F#6", 106)
    tp.n(18, 5, "A6", 108)

    tb = s.add(Part("Trombones y tuba", 57, gain=-2, pan=56, hall=0.4, room=0.1, jit=0.003, vjit=3))
    for beat, d, ps in [(8, 4, ["D3", "A3", "D4"]), (12, 2, ["G3", "D4", "B3"]), (14, 2, ["A3", "E4", "C#4"]),
                        (16, 7, ["D3", "A3", "D4", "F#4"])]:
        chord(tb, beat, d * 0.96, ps, 90)

    ba = s.add(Part("Bajos", 43, gain=3, pan=64, hall=0.3, room=0.1, jit=0.002, vjit=3))
    for beat, d, nm in [(0, 4, "D2"), (4, 4, "B1"), (8, 4, "D2"), (12, 2, "G2"), (14, 2, "A2"), (16, 7, "D2")]:
        ba.n(beat, d * 0.95, nm, 88)

    # --- brillos: arpa que sube, glissando y celesta al final
    ha = s.add(Part("Arpa", 46, gain=3, pan=100, hall=0.65, room=0.05, jit=0.003, vjit=4))
    for i, nm in enumerate(["D4", "A4", "D5", "F#5", "A5", "D6", "F#6", "A6"]):
        ha.n(8 + i * 0.5, 1.2, nm, 62 + i * 2)
    for i, nm in enumerate(["D4", "A4", "D5", "F#5", "A5", "D6", "F#6", "A6", "D7"]):
        ha.n(16 + i * 0.22, 3.0, nm, 70 + i * 2)
    ce = s.add(Part("Celesta", 8, gain=8, pan=82, hall=0.7, room=0.05, jit=0.003, vjit=4))
    for i, nm in enumerate(["D6", "F#6", "A6", "D7", "A6", "F#6", "D7", "F#7"]):
        ce.n(16.5 + i * 0.5, 1.5, nm, 58 + i * 2)
    bl = s.add(Part("Campana tubular", 14, gain=6, pan=64, hall=0.75, room=0.1, jit=0.0, vjit=0))
    bl.n(16, 7, "D5", 80)
    bl.n(16, 7, "A4", 70)

    # --- percusion
    ti = s.add(Part("Timbales", 47, gain=-4, pan=64, hall=0.4, room=0.25, jit=0.002, vjit=4))
    for beat in (0, 8):
        ti.n(beat, 0.5, "D3", 98)
    for k in range(12):            # redoble que sube hacia el final (tiempos 13 a 16)
        ti.n(13 + k * 0.25, 0.25, "A2" if k % 2 else "D3", 58 + int(k * 4))
    ti.n(16, 2.0, "D3", 120)
    dr = s.add(Part("Platillos, bombo y caja", 16, drum=True, gain=-8, pan=64, hall=0.25, room=0.4, jit=0.0, vjit=3))
    for beat in (8, 16):
        dr.n(beat, 1.0, 49, 112)
        dr.n(beat, 1.0, 36, 110)
    for k in range(6):             # caja que acelera antes del final
        dr.n(14 + k * 0.33, 0.2, 38, 62 + k * 10)
    return s


if __name__ == "__main__":
    out = "out/sonidos"
    os.makedirs(out, exist_ok=True)
    for nombre, fn in (("sfx_muerte", muerte), ("sfx_jefe", jefe), ("sfx_victoria", victoria)):
        song = fn()
        audio = song.render(loop=False)
        export(audio, os.path.join(out, nombre))
        song.save_midi(os.path.join(out, nombre + ".mid"))
