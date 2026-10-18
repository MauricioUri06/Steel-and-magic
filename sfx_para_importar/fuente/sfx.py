#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Steel and Magic: efectos de sonido.

Sintesis pura con numpy/scipy (sin samples ni SoundFont): osciladores aditivos,
ruido filtrado, envolventes y una reverb simple. Cada efecto es una funcion
registrada con @fx(nombre, pico_dBFS, fade_out, uso).

Uso:
    python sfx.py            # genera wav/ogg, mide todo y escribe LEEME_SFX.txt
    python sfx.py tajo dash  # solo esos efectos

Salida (junto a la carpeta fuente/): ogg/sfx_<nombre>.ogg, demo_todos.ogg y LEEME_SFX.txt
"""
import os
import sys
import zlib
import subprocess
import numpy as np
from scipy import signal
from scipy.io import wavfile

SR = 44100
AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(AQUI)
OGG_DIR = os.path.join(RAIZ, "ogg")
WAV_DIR = os.environ.get("SFX_WAV_DIR", os.path.join(RAIZ, "wav"))

R = np.random.default_rng(1)


# ---------------------------------------------------------------- utilidades
def reseed(nombre):
    global R
    R = np.random.default_rng(zlib.crc32(nombre.encode()))


def T(d):
    return np.arange(int(round(d * SR))) / SR


def noise(d):
    return R.standard_normal(int(round(d * SR)))


def P(x, a=1.0):
    """Escala la capa para que su pico sea `a`."""
    m = np.max(np.abs(x))
    return x * (a / m) if m > 0 else x


def lp(x, fc, o=4):
    return signal.sosfilt(signal.butter(o, min(fc, SR * 0.45), "low", fs=SR, output="sos"), x)


def hp(x, fc, o=4):
    return signal.sosfilt(signal.butter(o, fc, "high", fs=SR, output="sos"), x)


def bp(x, lo, hi, o=2):
    return signal.sosfilt(signal.butter(o, [lo, min(hi, SR * 0.45)], "band", fs=SR, output="sos"), x)


def svf(x, fc, q=1.0, mode="bp"):
    """Filtro de variable de estado (Chamberlin) con corte variable en el tiempo."""
    n = len(x)
    fc = np.broadcast_to(np.asarray(fc, float), (n,))
    f = np.minimum(2 * np.sin(np.pi * np.minimum(fc, 6000.0) / SR), 0.75).tolist()
    d = 1.0 / q
    xs = x.tolist()
    out = [0.0] * n
    low = band = 0.0
    for i in range(n):
        fi = f[i]
        low += fi * band
        high = xs[i] - low - d * band
        band += fi * high
        out[i] = band if mode == "bp" else (low if mode == "lp" else high)
    return np.array(out)


def ex(d, decay, attack=0.002):
    """Envolvente: subida lineal corta y caida exponencial."""
    t = T(d)
    return np.minimum(1.0, t / max(attack, 1e-4)) * np.exp(-t / decay)


def fsw(d, f0, f1, ts=None, k=1.0):
    """Curva de frecuencia exponencial de f0 a f1 en `ts` segundos; luego se queda en f1."""
    t = T(d)
    ts = ts or d
    u = np.minimum(t / ts, 1.0) ** k
    return f0 * (f1 / f0) ** u


def sine(freq):
    return np.sin(2 * np.pi * np.cumsum(freq) / SR)


def tone(freq, harm=(1,), amps=(1,)):
    freq = np.asarray(freq, float)
    ph = 2 * np.pi * np.cumsum(freq) / SR
    y = np.zeros_like(freq)
    for h, a in zip(harm, amps):
        y += a * np.sin(h * ph) * (freq * h < 18000)
    return y


BELL_R = (1, 2.0, 2.76, 4.1, 5.4)
BELL_A = (1, 0.5, 0.35, 0.2, 0.12)


def bell(f, d, decay=0.4, Rr=BELL_R, A=BELL_A):
    t = T(d)
    y = np.zeros_like(t)
    for i, (r, a) in enumerate(zip(Rr, A)):
        if f * r > 16000:
            continue
        y += a * np.sin(2 * np.pi * f * r * t) * np.exp(-t / (decay / (1 + 0.6 * i)))
    return y * np.minimum(1.0, t / 0.001)


def crackle(d, rate, lo=1500, hi=7000):
    """Chasquidos aleatorios (fuego, escombros)."""
    n = int(round(d * SR))
    x = np.zeros(n)
    idx = R.random(n) < rate / SR
    x[idx] = R.uniform(0.3, 1.0, idx.sum()) * R.choice([-1, 1], idx.sum())
    return bp(x, lo, hi)


def place(buf, x, at=0.0, gain=1.0):
    i = int(round(at * SR))
    fin = i + len(x)
    if fin > len(buf):
        buf = np.pad(buf, (0, fin - len(buf)))
    buf[i:fin] += x * gain
    return buf


def reverb(x, rt=0.8, mix=0.25, damp=4500):
    n = int(rt * SR)
    t = np.arange(n) / SR
    ir = R.standard_normal(n) * np.exp(-6.9 * t / rt)
    ir = lp(ir, damp, 2)
    a = int(0.004 * SR)
    ir[:a] *= np.linspace(0, 1, a)
    ir /= np.sqrt(np.sum(ir ** 2))
    wet = signal.fftconvolve(x, ir)
    y = np.pad(x, (0, len(wet) - len(x)))
    return y + mix * wet


def zeros(d):
    return np.zeros(int(round(d * SR)))


# ------------------------------------------------------------------ registro
FX = {}
ORDEN = []


def fx(nombre, pico, fade_out=0.015, uso=""):
    def deco(fn):
        FX[nombre] = (fn, pico, fade_out, uso)
        ORDEN.append(nombre)
        return fn
    return deco


def terminar(x, pico_db, fade_out=0.015, fade_in=0.0005, recorte_db=-55):
    x = np.asarray(x, float)
    x = x - np.mean(x)
    pk = np.max(np.abs(x))
    idx = np.where(np.abs(x) > pk * 10 ** (recorte_db / 20))[0]
    x = x[: idx[-1] + 1].copy()
    fi = max(1, int(fade_in * SR))
    fo = max(1, min(int(fade_out * SR), len(x) // 2))
    x[:fi] *= np.linspace(0, 1, fi)
    x[-fo:] *= np.cos(np.linspace(0, np.pi / 2, fo)) ** 2
    x *= 10 ** (pico_db / 20) / np.max(np.abs(x))
    return x.astype(np.float32)


# ============================================================ COMBATE: ataques
@fx("tajo", -8, 0.03, "Caballero: cada tajo (clic izquierdo). v2: mas grave y con peso, filo metalico corto")
def _():
    d = 0.24
    t = T(d)
    u = t / d
    env = np.sin(np.pi * u ** 0.55) ** 1.5
    fc = 450 * (3000 / 450) ** (u ** 0.8)
    w = P(svf(noise(d), fc, 1.8), 1) * env
    y = lp(w, 4500, 2)
    y = place(y, bell(1900, 0.2, 0.11, (1, 2.76, 5.4), (1, 0.5, 0.25)), 0.07, 0.20)
    y = place(y, sine(fsw(0.12, 190, 85, 0.06)) * ex(0.12, 0.035, 0.001), 0.065, 0.30)
    return y


@fx("disparo_soldado", -10, 0.01, "Soldado: cada bala (5 por segundo; usar volumen bajo)")
def _():
    d = 0.16
    t = T(d)
    crack = P(hp(noise(d), 2500), 1) * ex(d, 0.008, 0.0003)
    fc = 5500 * (700 / 5500) ** np.minimum(t / 0.1, 1)
    body = P(svf(noise(d), fc, 0.9, "lp"), 1) * ex(d, 0.03, 0.0005)
    thump = sine(fsw(d, 220, 65, 0.08)) * ex(d, 0.045, 0.0005)
    tail = P(lp(noise(d), 900), 1) * ex(d, 0.05, 0.004) * 0.25
    return 0.8 * crack + body + 0.9 * thump + tail


@fx("mago_carga", -10, 0.02, "Mago: mientras se mantiene el clic (dura 1.5 s = carga maxima; cortar al soltar)")
def _():
    d = 1.5
    t = T(d)
    u = t / d
    f = 170 * (950 / 170) ** (u ** 1.3)
    trem = 1 + 0.35 * np.sin(2 * np.pi * np.cumsum(5 + 14 * u) / SR)
    tn = P(tone(f, (1, 2, 3), (1, 0.4, 0.18)) * trem, 1) * (0.12 + 0.88 * u ** 1.5)
    sh = P(svf(noise(d), 900 + 4200 * u, 3.0, "bp"), 1) * u ** 2 * 0.55
    return tn + sh


@fx("mago_disparo", -8, 0.02, "Mago: al soltar la bola de fuego. v2: fwoomp grave y corto")
def _():
    d = 0.5
    t = T(d)
    fc = 300 + 1900 * np.exp(-((t - 0.09) / 0.12) ** 2)
    w = P(svf(noise(d), fc, 1.0, "lp"), 1) * ex(d, 0.14, 0.02)
    th = sine(fsw(d, 260, 70, 0.15)) * ex(d, 0.1, 0.004)
    cr = P(crackle(d, 30), 1) * ex(d, 0.15, 0.04) * (t > 0.06) * 0.25
    return w + 0.9 * th + cr


@fx("explosion", -4, 0.04, "Mago: bola de fuego grande al impactar / explosion fuerte")
def _():
    d = 1.0
    t = T(d)
    fc = 4500 * (180 / 4500) ** np.minimum(t / 0.6, 1)
    rum = P(svf(noise(d), fc, 0.8, "lp"), 1) * ex(d, 0.30, 0.001)
    sub = sine(fsw(d, 95, 32, 0.4)) * ex(d, 0.3, 0.002)
    click = P(hp(noise(d), 3000), 1) * ex(d, 0.01, 0.0002)
    deb = P(crackle(d, 90), 1) * (t > 0.1) * ex(d, 0.35, 0.05)
    y = rum + 1.1 * sub + 0.5 * click + 0.4 * deb
    return reverb(y, 0.5, 0.18)


@fx("explosion_chica", -9, 0.03, "Soldado: carta Balas explosivas (suena con cada bala que explota; volumen bajo)")
def _():
    d = 0.45
    t = T(d)
    fc = 5000 * (300 / 5000) ** np.minimum(t / 0.25, 1)
    rum = P(svf(noise(d), fc, 0.8, "lp"), 1) * ex(d, 0.1, 0.001)
    sub = sine(fsw(d, 150, 60, 0.15)) * ex(d, 0.1, 0.002)
    click = P(hp(noise(d), 3000), 1) * ex(d, 0.008, 0.0002)
    return rum + 0.9 * sub + 0.4 * click


# ======================================================= COMBATE: impactos
@fx("golpe_enemigo", -11, 0.01, "Un proyectil o tajo golpea a un enemigo (muy frecuente). v2: impacto seco y sordo")
def _():
    d = 0.1
    th = sine(fsw(d, 150, 65, 0.04)) * ex(d, 0.03, 0.0005)
    cl = P(bp(noise(d), 600, 2500), 1) * ex(d, 0.012, 0.0003)
    lo = P(lp(noise(d), 500), 1) * ex(d, 0.02, 0.0005)
    return th + 0.9 * cl + 0.5 * lo


@fx("golpe_escudo", -8, 0.03, "Golpe contra el demonio con escudo (clang metalico)")
def _():
    d = 0.38
    m = bell(620, d, 0.16, (1, 1.52, 2.31, 3.17, 4.4), (1, 0.7, 0.5, 0.35, 0.2))
    cl = P(bp(noise(d), 1500, 6000), 1) * ex(d, 0.01, 0.0002) * 0.5
    th = sine(fsw(d, 200, 90, 0.04)) * ex(d, 0.03, 0.0005) * 0.5
    return P(m, 1) + cl + th


@fx("enemigo_muere", -8, 0.03, "Un enemigo normal muere (suena a carne + un poco metalico)")
def _():
    d = 0.4
    t = T(d)
    fc = 2800 * (250 / 2800) ** np.minimum(t / 0.25, 1)
    w = P(svf(noise(d), fc, 1.0, "lp"), 1) * ex(d, 0.11, 0.002)
    th = sine(fsw(d, 420, 70, 0.25, 0.7)) * ex(d, 0.14, 0.002)
    met = bell(880, d, 0.08, (1, 2.4, 3.9), (1, 0.4, 0.2)) * 0.2
    pop = P(hp(noise(d), 2000), 1) * ex(d, 0.01, 0.0003) * 0.5
    return w + 0.8 * th + met + pop


@fx("jugador_dano", -6, 0.03, "El jugador recibe dano. v2: golpe sordo corto, sin disonancia")
def _():
    d = 0.32
    th = sine(fsw(d, 130, 45, 0.12)) * ex(d, 0.12, 0.001)
    body = P(lp(noise(d), 900), 1) * ex(d, 0.08, 0.001)
    ugh = P(lp(tone(fsw(d, 300, 150, 0.2), (1, 2, 3), (1, 0.5, 0.25)), 1200, 2), 1) * ex(d, 0.12, 0.005)
    cr = P(bp(noise(d), 1000, 3500), 1) * ex(d, 0.008, 0.0003)
    return th + 0.8 * body + 0.25 * ugh + 0.35 * cr


# ============================================================ MOVIMIENTO
@fx("dash", -8, 0.03, "Espacio: dash. v2: whoosh mas corto y opaco, sin brillo")
def _():
    d = 0.26
    t = T(d)
    u = t / d
    env = np.sin(np.pi * np.minimum(u, 1) ** 0.6) ** 1.4
    fc = 350 + 1500 * np.sin(np.pi * u)
    w = P(svf(noise(d), fc, 1.0, "bp"), 1) * env
    low = P(lp(noise(d), 700), 1) * env * 0.5
    return lp(w + low, 3800, 2)


@fx("fuego", -11, 0.03, "Llamas: quemadura de un enemigo o llamas del dash")
def _():
    d = 0.6
    t = T(d)
    ign = P(svf(noise(d), 300 + 1800 * np.minimum(t / 0.15, 1), 1.0, "lp"), 1) * ex(d, 0.22, 0.04)
    cr = P(crackle(d, 120), 1) * ex(d, 0.35, 0.01)
    return ign + 0.5 * cr


# ======================================================= ECONOMIA Y NIVELES
@fx("orbe", -16, 0.01, "Recoger un orbe de experiencia (suena muchas veces; variar el pitch en GameMaker). v2: blip suave")
def _():
    d = 0.11
    f = fsw(d, 700, 1050, 0.03)
    return tone(f, (1, 2), (1, 0.12)) * ex(d, 0.035, 0.002)


@fx("moneda", -10, 0.03, "Recoger una moneda")
def _():
    d = 0.55
    y = zeros(d)
    y = place(y, bell(1318.5, d, 0.25, (1, 2.4, 3.9), (1, 0.3, 0.15)), 0, 0.8)
    y = place(y, bell(1760, d, 0.30, (1, 2.4, 3.9), (1, 0.3, 0.15)), 0.075, 1.0)
    return y


@fx("nivel", -4, 0.05, "Subir de nivel (antes de la pantalla de cartas)")
def _():
    y = zeros(1.6)
    for i, f in enumerate([587.33, 739.99, 880.0, 1174.66]):
        y = place(y, bell(f, 0.9, 0.35), 0.085 * i, 0.7)
    for f, g in [(587.33, 0.5), (1174.66, 0.7), (1479.98, 0.5), (1760.0, 0.45)]:
        y = place(y, bell(f, 1.2, 0.7), 0.36, g)
    sh = P(svf(noise(1.2), np.linspace(2000, 5500, int(1.2 * SR)), 4, "bp"), 1) * ex(1.2, 0.4, 0.05) * 0.15
    y = place(y, sh * np.max(np.abs(y)), 0.3, 1.0)
    return reverb(y, 0.9, 0.28)


@fx("curacion", -10, 0.04, "Carta Curacion: cada vez que cura")
def _():
    d = 0.8
    y = zeros(d)
    for at, f in [(0.0, 1174.66), (0.09, 1760.0)]:
        n = tone(np.full(int(d * SR), f), (1, 2, 3), (1, 0.25, 0.1)) * ex(d, 0.3, 0.004)
        y = place(y, n, at, 1.0)
    sh = P(svf(noise(d), 4200, 5, "bp"), 1) * ex(d, 0.25, 0.04) * 0.12
    y = place(y, sh * np.max(np.abs(y)), 0.05, 1.0)
    return reverb(y, 0.5, 0.2)


@fx("compra", -8, 0.03, "Tienda de mejoras permanentes: compra con exito")
def _():
    d = 0.7
    y = zeros(d)
    y = place(y, bell(1568, d, 0.25, (1, 2.4, 3.9), (1, 0.3, 0.15)), 0, 0.8)
    y = place(y, bell(2093, d, 0.30, (1, 2.4, 3.9), (1, 0.3, 0.15)), 0.07, 1.0)
    sh = P(svf(noise(0.4), np.linspace(3000, 6000, int(0.4 * SR)), 4, "bp"), 1) * ex(0.4, 0.15, 0.02) * 0.15
    y = place(y, sh * np.max(np.abs(y)), 0.1, 1.0)
    return reverb(y, 0.4, 0.15)


@fx("error", -9, 0.02, "Tienda: no alcanzan las monedas / accion no permitida")
def _():
    d = 0.3
    n = int(d * SR)
    base = tone(np.full(n, 140.0), (1, 3, 5, 7), (1, 1 / 3, 0.2, 0.14))
    base = lp(base, 1800, 2)
    y = zeros(d)
    for at in (0.0, 0.13):
        seg = base[: int(0.1 * SR)] * ex(0.1, 0.06, 0.004)
        y = place(y, seg, at, 1.0)
    return y


# ============================================================ CARTAS
@fx("carta_aparece", -9, 0.04, "Se abre la pantalla de cartas (una vez, no por carta)")
def _():
    d = 0.5
    t = T(d)
    u = np.minimum(t / 0.3, 1.0)
    sw = P(svf(noise(d), 500 + 2200 * u, 1.2, "bp"), 1) * np.sin(np.pi * u) ** 1.5 * (t < 0.3)
    flap = P(bp(noise(0.08), 1200, 4000), 1) * ex(0.08, 0.025, 0.002)
    y = place(lp(sw, 4500, 2), lp(flap, 4500, 2), 0.28, 0.55)
    y = place(y, bell(2093, 0.4, 0.2, (1, 1.5, 2.0), (1, 0.5, 0.3)), 0.15, 0.2)
    return y


@fx("carta_elegir", -12, 0.01, "Seleccionar una carta (clic o A/D)")
def _():
    d = 0.13
    b = bell(1568, d, 0.035, (1, 2.76), (1, 0.4))
    cl = P(bp(noise(d), 2000, 6000), 1) * ex(d, 0.006, 0.0002) * 0.4
    return P(b, 1) + cl


@fx("carta_confirmar", -6, 0.05, "Confirmar la carta elegida")
def _():
    y = zeros(1.0)
    for at, f, g in [(0.0, 880.0, 0.7), (0.06, 1318.5, 0.8), (0.12, 1760.0, 1.0)]:
        y = place(y, bell(f, 0.9, 0.45), at, g)
    sh = P(svf(noise(0.5), np.linspace(2500, 6000, int(0.5 * SR)), 4, "bp"), 1) * ex(0.5, 0.18, 0.02) * 0.15
    y = place(y, sh * np.max(np.abs(y)), 0.08, 1.0)
    return reverb(y, 0.6, 0.22)


@fx("apuesta_gana", -4, 0.05, "Carta Apuesta: ganaste (2 cartas extra)")
def _():
    y = zeros(2.0)
    for i, f in enumerate([587.33, 659.25, 739.99, 880.0, 987.77, 1174.66, 1479.98]):
        y = place(y, bell(f, 0.8, 0.3), 0.07 * i, 0.6)
    for f, g in [(1174.66, 0.7), (1479.98, 0.6), (1760.0, 0.55), (2349.3, 0.4)]:
        y = place(y, bell(f, 1.3, 0.6), 0.55, g)
    for _i in range(12):
        f = float(R.uniform(1500, 2800))
        y = place(y, bell(f, 0.3, 0.1, (1, 2.4, 3.9), (1, 0.3, 0.15)), float(R.uniform(0.5, 1.2)), float(R.uniform(0.15, 0.3)))
    return reverb(y, 0.9, 0.25)


@fx("apuesta_pierde", -6, 0.05, "Carta Apuesta: perdiste (te quita vida)")
def _():
    def trombon(f0, d, f1=None, vib=0.0):
        n = int(d * SR)
        t = np.arange(n) / SR
        f = np.full(n, float(f0)) if f1 is None else f0 * (f1 / f0) ** np.minimum(t / d, 1.0)
        if vib:
            f = f * (1 + 0.012 * np.sin(2 * np.pi * 5.5 * t) * np.minimum(t / 0.3, 1))
        y = tone(f, (1, 2, 3, 4, 5, 6), (1, 0.6, 0.45, 0.3, 0.2, 0.12))
        y = lp(y, 1400, 2)
        return y * np.minimum(1, t / 0.03) * np.exp(-t / (d * 0.9))
    y = zeros(1.5)
    y = place(y, trombon(233.1, 0.28), 0.0)
    y = place(y, trombon(220.0, 0.28), 0.30)
    y = place(y, trombon(207.7, 0.28), 0.60)
    y = place(y, trombon(196.0, 0.5, 150.0, vib=1), 0.90)
    return y


# ============================================================ MENUS Y CLASES
@fx("boton_hover", -20, 0.01, "Pasar el mouse sobre un boton. v2: tic suave y bajo")
def _():
    d = 0.05
    return tone(np.full(int(d * SR), 480.0), (1, 2), (1, 0.15)) * ex(d, 0.012, 0.001)


@fx("boton_clic", -14, 0.02, "Clic en un boton. v2: thock calido, sin timbre metalico")
def _():
    d = 0.1
    th = sine(fsw(d, 380, 220, 0.03)) * ex(d, 0.03, 0.0005)
    tk = P(lp(noise(d), 2200), 1) * ex(d, 0.008, 0.0003) * 0.6
    lo = sine(np.full(int(d * SR), 190.0)) * ex(d, 0.025, 0.001) * 0.5
    return th + tk + lo


@fx("menu_abrir", -12, 0.03, "Abrir pausa (Esc) o el menu M de mejoras")
def _():
    d = 0.28
    t = T(d)
    u = t / d
    w = P(svf(noise(d), 3000 * (500 / 3000) ** u, 1.2, "bp"), 1) * np.sin(np.pi * u ** 0.6) ** 1.4
    s = sine(fsw(d, 220, 110)) * ex(d, 0.12, 0.01) * 0.4
    return lp(w, 3500, 2) + s


@fx("menu_cerrar", -12, 0.03, "Cerrar pausa o el menu M")
def _():
    d = 0.25
    t = T(d)
    u = t / d
    w = P(svf(noise(d), 500 * (2500 / 500) ** u, 1.2, "bp"), 1) * np.sin(np.pi * u ** 1.3) ** 1.4
    s = sine(fsw(d, 110, 220)) * ex(d, 0.1, 0.01) * 0.35
    return lp(w, 3500, 2) + s


@fx("clase_caballero", -9, 0.02, "Tecla 1: cambiar a Caballero")
def _():
    d = 0.3
    m = bell(420, d, 0.12, (1, 1.52, 2.31, 3.17), (1, 0.7, 0.5, 0.3))
    t = T(d)
    u = np.minimum(t / 0.12, 1)
    sh = lp(P(svf(noise(d), 1500 + 2500 * u, 1.5, "bp"), 1), 4500, 2) * ex(d, 0.07, 0.01) * 0.3
    th = sine(fsw(d, 150, 80, 0.06)) * ex(d, 0.05, 0.001) * 0.6
    return lp(P(m, 1), 6000, 2) + sh + th


@fx("clase_mago", -9, 0.04, "Tecla 2: cambiar a Mago")
def _():
    y = zeros(0.45)
    for at, f in [(0.0, 1046.5), (0.05, 1568.0), (0.10, 2093.0)]:
        y = place(y, bell(f, 0.4, 0.2, (1, 2.0, 3.0), (1, 0.4, 0.2)), at, 0.8)
    sh = P(svf(noise(0.4), np.linspace(3000, 6000, int(0.4 * SR)), 4, "bp"), 1) * ex(0.4, 0.12, 0.03) * 0.3
    y = place(y, sh * np.max(np.abs(y)), 0.0, 1.0)
    return reverb(y, 0.35, 0.18)


@fx("clase_soldado", -9, 0.02, "Tecla 3: cambiar a Soldado")
def _():
    d = 0.3
    y = zeros(d)
    for at, g in [(0.0, 1.0), (0.09, 0.8)]:
        cl = P(bp(noise(0.06), 1500, 5000), 1) * ex(0.06, 0.012, 0.0003)
        th = sine(fsw(0.06, 220, 90, 0.03)) * ex(0.06, 0.02, 0.0005)
        tk = bell(900, 0.06, 0.02, (1, 2.4), (1, 0.3)) * 0.5
        y = place(y, cl + 0.8 * th + tk, at, g)
    return y


@fx("acto", -5, 0.08, "Cartel 'ACTO I/II/III' (gong grave con reverb)")
def _():
    d = 3.4
    t = T(d)
    f0 = 98.0
    partes = [(1, 1), (1.59, 0.7), (2.14, 0.6), (2.30, 0.55), (2.65, 0.45), (2.92, 0.4), (3.5, 0.3), (4.07, 0.25)]
    y = np.zeros_like(t)
    for i, (r, a) in enumerate(partes):
        f = f0 * r
        sw = 1 - np.exp(-t / (0.02 + 0.1 * i))
        dec = np.exp(-t / (2.3 / (1 + 0.5 * i)))
        y += a * (np.sin(2 * np.pi * f * t) + 0.7 * np.sin(2 * np.pi * (f + 0.6) * t)) * sw * dec
    y = P(y, 1)
    golpe = P(lp(noise(d), 2000), 1) * ex(d, 0.08, 0.002) * 0.5
    return reverb(y + golpe, 1.3, 0.25, damp=3500)


# ===================================================================== medicion
def centroide(x):
    esp = np.abs(np.fft.rfft(x * np.hanning(len(x))))
    fr = np.fft.rfftfreq(len(x), 1 / SR)
    return float((fr * esp).sum() / max(esp.sum(), 1e-12))


def medir(x):
    n = len(x)
    pk = float(np.max(np.abs(x)))
    onset = int(np.argmax(np.abs(x) > pk * 10 ** (-40 / 20)))
    en = np.cumsum(x.astype(float) ** 2)
    t99 = float(np.searchsorted(en, 0.99 * en[-1]) / SR)
    return {
        "dur": n / SR,
        "pico": 20 * np.log10(pk),
        "rms": 20 * np.log10(np.sqrt(np.mean(x.astype(float) ** 2)) + 1e-12),
        "onset_ms": onset / SR * 1000,
        "t99": t99,
        "centroide": centroide(x),
        "hf": float(np.sum(np.abs(np.fft.rfft(x.astype(float))[np.fft.rfftfreq(len(x), 1 / SR) > 5000]) ** 2) / max(np.sum(np.abs(np.fft.rfft(x.astype(float))) ** 2), 1e-12) * 100),
        "dc": float(np.mean(x)),
        "primera": float(abs(x[0])),
        "ultima": float(abs(x[-1])),
        "clip": int(np.sum(np.abs(x) >= 0.999)),
    }


def a_ogg(wav, ogg):
    subprocess.run(
        ["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-ac", "1", "-ar", str(SR), "-c:a", "libvorbis", "-q:a", "6", ogg],
        check=True,
    )


def decodificar(ogg):
    r = subprocess.run(
        ["ffmpeg", "-loglevel", "error", "-i", ogg, "-f", "f32le", "-ac", "1", "-ar", str(SR), "-"],
        check=True, capture_output=True,
    )
    return np.frombuffer(r.stdout, dtype=np.float32)


def main(args):
    os.makedirs(OGG_DIR, exist_ok=True)
    os.makedirs(WAV_DIR, exist_ok=True)
    nombres = args or ORDEN
    filas = []
    terminados = {}
    for nombre in nombres:
        fn, pico, fo, uso = FX[nombre]
        reseed(nombre)
        x = terminar(fn(), pico, fo)
        terminados[nombre] = x
        wav = os.path.join(WAV_DIR, f"sfx_{nombre}.wav")
        ogg = os.path.join(OGG_DIR, f"sfx_{nombre}.ogg")
        wavfile.write(wav, SR, (np.clip(x, -1, 1) * 32767).astype(np.int16))
        a_ogg(wav, ogg)
        m = medir(x)
        dec = decodificar(ogg)
        m["pico_ogg"] = 20 * np.log10(float(np.max(np.abs(dec))) + 1e-12)
        m["dur_ogg"] = len(dec) / SR
        m["kb"] = os.path.getsize(ogg) / 1024
        filas.append((nombre, uso, m))
        print(
            f"{nombre:18s} {m['dur']:5.2f}s  pico {m['pico']:6.1f}  rms {m['rms']:6.1f}  "
            f"onset {m['onset_ms']:5.1f}ms  t99 {m['t99']:5.2f}s  cent {m['centroide']:6.0f}Hz hf {m['hf']:4.1f}%  "
            f"ogg pico {m['pico_ogg']:6.1f}  dur_ogg {m['dur_ogg']:5.2f}  {m['kb']:5.1f}KB  "
            f"ini {m['primera']:.4f} fin {m['ultima']:.4f} clip {m['clip']}"
        )

    if not args:
        # demo con todos en orden, separados por 0.4 s
        gap = np.zeros(int(0.4 * SR), dtype=np.float32)
        demo = np.concatenate([np.concatenate([terminados[n], gap]) for n in ORDEN])
        wav = os.path.join(WAV_DIR, "demo_todos.wav")
        wavfile.write(wav, SR, (np.clip(demo, -1, 1) * 32767).astype(np.int16))
        a_ogg(wav, os.path.join(RAIZ, "demo_todos.ogg"))

        with open(os.path.join(RAIZ, "LEEME_SFX.txt"), "w", encoding="utf-8") as f:
            f.write("Steel and Magic: efectos de sonido (sfx_*.ogg)\n")
            f.write("Sintesis propia con numpy/scipy (fuente/sfx.py): no usa samples ni SoundFont, sin licencias.\n")
            f.write("demo_todos.ogg tiene todos en este orden, separados por 0.4 s.\n\n")
            f.write(f"{'nombre':20s}{'dur':>6s}{'pico':>7s}{'rms':>7s}  uso previsto\n")
            for nombre, uso, m in filas:
                f.write(f"sfx_{nombre:16s}{m['dur']:5.2f}s{m['pico']:7.1f}{m['rms']:7.1f}  {uso}\n")
        print("listo:", len(filas), "efectos")


if __name__ == "__main__":
    main(sys.argv[1:])
