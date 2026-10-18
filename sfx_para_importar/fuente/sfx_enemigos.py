#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Steel and Magic: efectos de sonido de ENEMIGOS Y JEFES (18 oct, segunda tanda).
Usa las utilidades de sfx.py (misma sintesis propia con numpy/scipy, sin samples).

    python sfx_enemigos.py          # genera los 18 sonidos nuevos en ../ogg y mide todo
"""
import sys
import numpy as np
import sfx
from sfx import (T, noise, P, lp, hp, bp, svf, ex, fsw, sine, tone, bell, crackle,
                 place, reverb, zeros, fx)

NUEVOS = []


def nuevo(nombre, pico, fade_out, uso):
    NUEVOS.append(nombre)
    return fx(nombre, pico, fade_out, uso)


# ---------------------------------------------------------------- enemigos normales
@nuevo("enemigo_ataque", -12, 0.02, "Enemigo normal: golpe cuerpo a cuerpo (goblin, demonio, orco); varios a la vez, volumen bajo")
def _():
    d = 0.24
    t = T(d)
    u = np.minimum(t / 0.14, 1)
    sw = P(svf(noise(d), 700 + 2200 * u, 1.6, "bp"), 1) * ex(d, 0.06, 0.012)
    th = sine(fsw(d, 190, 70, 0.07)) * ex(d, 0.05, 0.001) * 0.7
    return lp(sw, 5000, 2) + th


@nuevo("enemigo_embestida", -10, 0.05, "Enemigo: empieza una embestida (orco exo, goblin): gruñido que sube")
def _():
    d = 0.55
    t = T(d)
    f = fsw(d, 85, 150, 0.4)
    gr = tone(f, tuple(range(1, 10)), tuple(1 / h for h in range(1, 10))) * (1 + 0.5 * np.sin(2 * np.pi * 24 * t))
    gr = P(svf(gr, np.linspace(380, 800, len(t)), 2.5, "bp"), 1) * np.minimum(1, t / 0.05) * np.exp(-np.maximum(t - 0.25, 0) / 0.18)
    wh = P(lp(noise(d), 1800, 2), 1) * np.minimum(1, t / 0.25) * np.exp(-np.maximum(t - 0.3, 0) / 0.12) * 0.45
    return gr + wh


@nuevo("enemigo_disparo", -14, 0.015, "Enemigo: dispara una bala (diablillo, elfo, jefes); muy seguido, volumen bajo")
def _():
    d = 0.2
    zap = tone(fsw(d, 1100, 330, 0.12), (1, 2, 3), (1, 0.3, 0.15)) * ex(d, 0.05, 0.0005)
    ck = P(bp(noise(0.02), 1500, 6000), 1)
    y = zap * 0.8
    y[: len(ck)] += ck * 0.5 * np.exp(-T(0.02) / 0.006)
    return lp(y, 7000, 2)


@nuevo("enemigo_llama", -14, 0.03, "Enemigo/jefe: bola o soplo de fuego (balas de estilo llama); rafagas, volumen bajo")
def _():
    d = 0.34
    t = T(d)
    n = P(svf(noise(d), np.linspace(500, 2200, len(t)), 1.2, "bp"), 1) * np.minimum(1, t / 0.04) * np.exp(-t / 0.13)
    lo = P(lp(noise(d), 260, 2), 1) * ex(d, 0.1, 0.01) * 0.7
    cr = crackle(d, 160, 1500, 6000) * ex(d, 0.12) * 0.35
    return lp(n + lo + cr, 3600, 2)


@nuevo("misil_lanzar", -10, 0.05, "Jefe orco mecha y elite de misiles: lanza un misil")
def _():
    d = 0.6
    t = T(d)
    hiss = P(svf(noise(d), np.linspace(900, 3200, len(t)), 1.5, "bp"), 1) * np.minimum(1, t / 0.06) * np.exp(-np.maximum(t - 0.12, 0) / 0.25)
    rum = P(lp(noise(d), 220, 3), 1) * np.minimum(1, t / 0.03) * np.exp(-t / 0.3) * 0.9
    ch = sine(fsw(d, 260, 90, 0.12)) * ex(d, 0.06, 0.001) * 0.6
    return lp(hiss + rum + ch, 3800, 2)


@nuevo("portal", -17, 0.02, "Un enemigo aparece (portal morado del spawner); muy seguido, volumen muy bajo")
def _():
    d = 0.32
    t = T(d)
    y = tone(fsw(d, 260, 740, 0.2), (1, 2), (1, 0.35)) * ex(d, 0.12, 0.02)
    sh = P(svf(noise(d), np.linspace(1500, 4500, len(t)), 5, "bp"), 1) * ex(d, 0.1, 0.03) * 0.5
    return lp(y + sh, 6000, 2)


# ---------------------------------------------------------------- impactos y ondas
@nuevo("onda_choque", -8, 0.06, "Onda de choque de un jefe (el anillo que se esquiva con el dash)")
def _():
    d = 0.8
    boom = sine(fsw(d, 130, 38, 0.35)) * ex(d, 0.28, 0.002)
    nz = P(lp(noise(d), 700, 3), 1) * ex(d, 0.12, 0.001) * 0.7
    ring = P(svf(noise(d), np.linspace(900, 250, int(d * sfx.SR)), 3, "bp"), 1) * ex(d, 0.3, 0.02) * 0.45
    return reverb(boom + nz + ring, 0.35, 0.15)


@nuevo("impacto_pesado", -5, 0.06, "Caida fuerte: aterrizaje del orco mecha, sismo, objetos que caen (grietas en el suelo)")
def _():
    d = 0.75
    boom = sine(fsw(d, 100, 32, 0.22)) * ex(d, 0.22, 0.001)
    nz = P(lp(noise(d), 1100, 3), 1) * ex(d, 0.08, 0.0005) * 0.9
    deb = crackle(d, 70, 600, 4500) * ex(d, 0.25) * 0.45
    return reverb(boom + nz + deb, 0.3, 0.12)


# ---------------------------------------------------------------- jefes
@nuevo("jefe_aviso", -12, 0.03, "Jefe: empieza a preparar un ataque (aviso corto que sube)")
def _():
    d = 0.36
    y = zeros(d)
    for at, f in [(0.0, 330), (0.11, 440), (0.22, 560)]:
        n = int(0.12 * sfx.SR)
        y = place(y, tone(np.full(n, f), (1, 2, 3), (1, 0.4, 0.2)) * ex(0.12, 0.06, 0.004), at, 1.0)
    return lp(y, 4500, 2)


@nuevo("rugido_dragon", -6, 0.12, "Presentacion del Dragon cibernetico (oleada 10): rugido agudo y rasposo")
def _():
    d = 1.8
    t = T(d)
    f = 95 + 75 * np.sin(np.pi * np.minimum(t / d, 1)) ** 0.8
    src = tone(f, tuple(range(1, 18)), tuple(1 / h for h in range(1, 18))) * (1 + 0.55 * np.sin(2 * np.pi * 33 * t))
    src += 0.5 * noise(d)
    f1 = 450 + 450 * np.sin(np.pi * np.minimum(t / d, 1))
    y = P(svf(src, f1, 3, "bp"), 1) * 0.8 + P(svf(src, f1 * 2.3, 3, "bp"), 1) * 0.45
    y *= np.minimum(1, t / 0.18) * np.exp(-np.maximum(t - 1.0, 0) / 0.4)
    sc = P(svf(noise(d), 3200, 2, "bp"), 1) * np.minimum(1, t / 0.3) * np.exp(-np.maximum(t - 0.9, 0) / 0.3) * 0.25
    return lp(reverb(np.tanh(1.6 * (y + sc)), 0.7, 0.2), 3800, 2)


@nuevo("rugido_orco", -6, 0.1, "Presentacion del Orco Mecha (oleada 20): gruñido grave con metal")
def _():
    d = 1.6
    t = T(d)
    f = 55 + 25 * np.sin(np.pi * np.minimum(t / d, 1))
    src = tone(f, tuple(range(1, 14)), tuple(1 / h for h in range(1, 14))) * (1 + 0.5 * np.sin(2 * np.pi * 19 * t))
    src = np.tanh(2.5 * src)
    y = P(svf(src, 300 + 250 * np.sin(np.pi * np.minimum(t / d, 1)), 3, "bp"), 1)
    ring = y * np.sign(np.sin(2 * np.pi * 140 * t))      # modulacion en anillo: voz metalica
    y = 0.7 * y + 0.35 * ring
    cl = zeros(d)
    for at in (0.05, 0.55):
        cl = place(cl, bell(210, 0.7, 0.25, (1, 1.47, 2.09, 2.91), (1, 0.6, 0.4, 0.3)), at, 0.35)
    y = y * np.minimum(1, t / 0.12) * np.exp(-np.maximum(t - 0.9, 0) / 0.4)
    return reverb(y + cl, 0.6, 0.2)


@nuevo("rugido_general", -6, 0.12, "Presentacion del General Demonio (oleada 30): voz profunda y larga")
def _():
    d = 2.0
    t = T(d)
    vib = 1 + 0.015 * np.sin(2 * np.pi * 5.5 * t)
    f = (48 + 18 * np.sin(np.pi * np.minimum(t / d, 1)) ** 1.2) * vib
    src = tone(f, tuple(range(1, 22)), tuple(1 / h ** 0.9 for h in range(1, 22))) * (1 + 0.3 * np.sin(2 * np.pi * 11 * t))
    src += 0.25 * noise(d)
    f1 = 280 + 160 * np.sin(np.pi * np.minimum(t / d, 1))
    y = P(svf(src, f1, 4, "bp"), 1) * 0.9 + P(svf(src, 760, 4, "bp"), 1) * 0.4 + 0.5 * P(lp(src, 160, 2), 1)
    y *= np.minimum(1, t / 0.3) * np.exp(-np.maximum(t - 1.1, 0) / 0.45)
    return reverb(np.tanh(1.3 * y), 1.1, 0.28)


@nuevo("aliento", -8, 0.08, "Dragon: aliento de plasma (barrido en abanico)")
def _():
    d = 1.4
    t = T(d)
    env = np.minimum(1, t / 0.18) * np.exp(-np.maximum(t - 0.9, 0) / 0.2)
    f = 500 + 1900 * np.sin(np.pi * np.minimum(t / 1.0, 1)) ** 1.5
    n = P(svf(noise(d), f, 1.3, "bp"), 1) * env
    rum = sine(fsw(d, 75, 60, 1.0)) * env * 0.5
    cr = crackle(d, 110, 1200, 6000) * env * 0.5
    return lp(reverb(n + rum + cr, 0.4, 0.12), 3600, 2)


@nuevo("picada", -9, 0.04, "Dragon: se lanza en picada / orco mecha salta (rafaga de aire que baja y sube)")
def _():
    d = 0.6
    t = T(d)
    env = np.sin(np.pi * np.minimum(t / d, 1)) ** 1.5
    n = P(svf(noise(d), 2600 - 1900 * np.minimum(t / 0.45, 1), 1.6, "bp"), 1) * env
    dp = tone(fsw(d, 760, 190, 0.5), (1, 2), (1, 0.25)) * env * 0.35
    return lp(n + dp, 6000, 2)


@nuevo("tajo_jefe", -8, 0.03, "General Demonio: tajo pesado de espada")
def _():
    d = 0.4
    t = T(d)
    u = np.minimum(t / 0.2, 1)
    sw = P(svf(noise(d), 350 + 2600 * u, 1.8, "bp"), 1) * ex(d, 0.1, 0.02)
    body = sine(fsw(d, 150, 55, 0.12)) * ex(d, 0.1, 0.001) * 0.8
    ring = bell(520, d, 0.14, (1, 2.4, 3.9), (1, 0.4, 0.2)) * 0.25
    return lp(sw + body + ring, 7000, 2)


@nuevo("invocar", -10, 0.06, "General Demonio: invoca enemigos (destello magico oscuro)")
def _():
    d = 1.1
    y = zeros(d)
    for at, f in [(0.0, 392.0), (0.1, 466.2), (0.2, 587.3), (0.32, 784.0)]:
        y = place(y, bell(f, 0.7, 0.3, (1, 2.0, 3.0), (1, 0.4, 0.2)), at, 0.8)
    t = T(d)
    sh = P(svf(noise(d), np.linspace(1200, 5000, len(t)), 5, "bp"), 1) * ex(d, 0.3, 0.1) * 0.4
    lo = sine(fsw(d, 90, 60, 0.6)) * ex(d, 0.35, 0.05) * 0.5
    return reverb(y * 0.5 + sh + lo, 0.7, 0.22)


@nuevo("jefe_muere", -3, 0.2, "Muerte de un jefe (dragon, orco mecha, general): gran explosion que se derrumba")
def _():
    d = 2.8
    t = T(d)
    boom = sine(fsw(d, 95, 22, 0.9)) * ex(d, 0.7, 0.003)
    nz = P(svf(noise(d), np.linspace(2500, 180, len(t)), 0.9, "lp"), 1) * ex(d, 0.45, 0.002) * 0.9
    rum = P(lp(noise(d), 110, 3), 1) * ex(d, 1.1, 0.08) * 0.8
    deb = crackle(d, 45, 500, 5000) * ex(d, 1.0, 0.1) * 0.35
    met = place(zeros(d), bell(160, 1.6, 0.6, (1, 1.5, 2.3, 3.4), (1, 0.5, 0.3, 0.2)), 0, 0.2)
    return reverb(np.tanh(1.2 * (boom + nz + rum + deb + met)), 1.3, 0.25)


if __name__ == "__main__":
    sfx.main(NUEVOS if not sys.argv[1:] else sys.argv[1:])
