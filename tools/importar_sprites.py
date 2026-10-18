"""Convierte una hoja de sprites generada por IA (fondo transparente, fotogramas separados por espacio)
en sprites de GameMaker con celdas de tamano fijo, y los registra en el proyecto.

Uso (desde la raiz del repo, requiere pillow):
    python tools/importar_sprites.py HOJA CELDA PREFIJO NOMBRE=FRAMES [NOMBRE=FRAMES ...]
    (CELDA: 32 para 32x32, o ANCHOxALTO como 96x80)

    python tools/importar_sprites.py art/enemies/orco/orco_sheet.png 48 spr_orco \
        caminar=0-3 aviso=4-5 embestida=6 recuperar=7 caida=8 muerto=9

    # hoja que ya es pixel art en celdas exactas de 32x32: se corta tal cual
    python tools/importar_sprites.py art/enemies/elite_misiles/elite_misiles_sheet.png 32 spr_elite --grilla \
        caminar=0-3 apuntar=4-5 disparo=6 recuperar=7 caida=8 muerto=9

    # fotogramas que se tocan (efectos que invaden al vecino): dividir en 4 columnas x 4 filas
    python tools/importar_sprites.py art/enemies/dragon/dragon_sheet.png 64 spr_dragon --cuadricula 4x4 ...

--borrar INDICE=x0,y0,x1,y1 vacia una zona dentro de ese recorte (se puede repetir).
--recorte INDICE=x0,y0,x1,y1 corta ese fotograma a mano (en pixeles de la hoja original), para cuando la
deteccion automatica lo corta mal. Si la hoja no tiene transparencia, se borra el fondo (del color de las esquinas) conectado con los bordes.
Los fotogramas se numeran de izquierda a derecha y de arriba a abajo, empezando en 0.
Hoja de IA: todos se reducen con el MISMO factor (el mayor fotograma entra en la celda), con los pies
en la misma linea y centrados en horizontal. El origen queda en el centro de la celda. Volver a correrlo
reemplaza los PNG pero conserva los ids del .yy, asi GameMaker no ve recursos nuevos.
"""
import os, re, sys, uuid, json
from PIL import Image, ImageChops, ImageDraw, ImageFilter

TEMPLATE = 'sprites/s_caminata_cab_derecha/s_caminata_cab_derecha.yy'   # sprite del proyecto que GameMaker ya abre
YYP = 'Steel & Magic.yyp'
COLORES = 32      # colores de la paleta comun de la hoja
MARGEN = 1        # pixeles libres alrededor del fotograma mas grande


def cajas(im):
    """Cajas (x0, y0, x1, y1) de cada fotograma, en orden de lectura."""
    a = im.getchannel('A').point(lambda v: 255 if v > 128 else 0)
    px, (W, H) = a.load(), a.size

    def tramos(perfil, hueco=15):
        out, ini, vacio = [], None, 0
        for i, v in enumerate(perfil):
            if v:
                if ini is None: ini = i
                vacio = 0
            elif ini is not None:
                vacio += 1
                if vacio > hueco:
                    out.append((ini, i - vacio)); ini = None
        if ini is not None: out.append((ini, len(perfil) - 1))
        return out

    res = []
    for y0, y1 in tramos([any(px[x, y] for x in range(W)) for y in range(H)]):
        for x0, x1 in tramos([any(px[x, y] for y in range(y0, y1 + 1)) for x in range(W)]):
            # ajustar la altura a este fotograma (las filas pueden tener alturas distintas)
            sub = a.crop((x0, y0, x1 + 1, y1 + 1)).getbbox()
            res.append((x0, y0 + sub[1], x1 + 1, y0 + sub[3]))
    return res


def paleta(recortes):
    """Paleta comun de la hoja (solo pixeles opacos), para que todos los fotogramas usen los mismos colores."""
    opacos = []
    for r in recortes:
        b = r.tobytes()
        opacos += [tuple(b[i:i + 3]) for i in range(0, len(b), 4) if b[i + 3] > 128]
    muestra = Image.new('RGB', (len(opacos), 1))
    muestra.putdata(opacos)
    return muestra.quantize(colors=COLORES, method=Image.Quantize.MEDIANCUT)


def reducir(frame, factor, pal):
    """Cada pixel nuevo toma el color MAS FRECUENTE de su bloque (promediar mezcla contorno y relleno
    y deja los colores barrosos). Es transparente si menos de la mitad del bloque es opaco."""
    w, h = max(1, round(frame.width / factor)), max(1, round(frame.height / factor))
    idx = frame.convert('RGB').quantize(palette=pal, dither=Image.Dither.NONE)
    ip, ap = idx.load(), frame.getchannel('A').load()
    colores = pal.getpalette()
    out = Image.new('RGBA', (w, h))
    op = out.load()
    for y in range(h):
        for x in range(w):
            x0, x1 = int(x * frame.width / w), max(int(x * frame.width / w) + 1, int((x + 1) * frame.width / w))
            y0, y1 = int(y * frame.height / h), max(int(y * frame.height / h) + 1, int((y + 1) * frame.height / h))
            cuenta, total = {}, 0
            for yy in range(y0, y1):
                for xx in range(x0, x1):
                    total += 1
                    if ap[xx, yy] > 128:
                        k = ip[xx, yy]
                        cuenta[k] = cuenta.get(k, 0) + 1
            if sum(cuenta.values()) * 2 >= total:
                k = max(cuenta, key=cuenta.get)
                op[x, y] = tuple(colores[k * 3:k * 3 + 3]) + (255,)
    return out


def yy_sprite(nombre, frames, layer, celda, kf_ids):
    t = open(TEMPLATE, encoding='utf-8').read()
    viejo = re.search(r'"%Name":"(s_[^"]+)"', t).group(1)
    t = t.replace(viejo, nombre)
    fr = ''.join('    {"$GMSpriteFrame":"v1","%%Name":"%s","name":"%s","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},\n' % (f, f) for f in frames)
    t = re.sub(r'(  "frames":\[\n)(.*?)(  \],)', lambda m: m.group(1) + fr + m.group(3), t, count=1, flags=re.S)
    t = re.sub(r'"\$GMImageLayer":"","%Name":"[^"]+"(.*?)"name":"[^"]+"',
               lambda m: '"$GMImageLayer":"","%%Name":"%s"%s"name":"%s"' % (layer, m.group(1), layer), t, count=1)
    kfs = ''.join(
        '            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{\n'
        '                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"%s","path":"sprites/%s/%s.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},\n'
        '              },"Disabled":false,"id":"%s","IsCreationKey":false,"Key":%d.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},\n'
        % (f, nombre, nombre, kf_ids[i], i) for i, f in enumerate(frames))
    t = re.sub(r'("Keyframes":\[\n)(            \{"\$Keyframe<SpriteFrameKeyframe>".*?)(          \],)',
               lambda m: m.group(1) + kfs + m.group(3), t, count=1, flags=re.S)
    t = re.sub(r'(  "parent":\{\n    "name":")[^"]+(",\n    "path":")[^"]+(")',
               lambda m: m.group(1) + 'enemies' + m.group(2) + 'folders/sprites/enemies.yy' + m.group(3), t, count=1)
    cw, ch = celda
    for k, v in {'length': '%d.0' % len(frames), 'width': cw, 'height': ch, 'xorigin': cw // 2, 'yorigin': ch // 2,
                 'bbox_left': 0, 'bbox_top': 0, 'bbox_right': cw - 1, 'bbox_bottom': ch - 1}.items():
        t, n = re.subn(r'"%s":[0-9.]+,' % k, '"%s":%s,' % (k, v), t)
        assert n == 1, k
    return t


def celdas_grilla(im, celda):
    """Hoja que ya es pixel art en celdas exactas (ej. 128x96 con celdas de 32): se corta tal cual, sin reducir.
    Las celdas vacias se saltan."""
    out = []
    cw, ch = celda
    for y in range(0, im.height, ch):
        for x in range(0, im.width, cw):
            c = im.crop((x, y, x + cw, y + ch))
            if c.getbbox(): out.append(c)
    return out


def manchas(alfa):
    """Grupos de pixeles opacos conectados (8 vecinos) de una imagen 'L'. Devuelve listas de (x, y)."""
    w, h = alfa.size
    a = alfa.load()
    visto = bytearray(w * h)
    out = []
    for y0 in range(h):
        for x0 in range(w):
            if visto[y0 * w + x0] or a[x0, y0] <= 128: continue
            pila, comp = [(x0, y0)], []
            visto[y0 * w + x0] = 1
            while pila:
                x, y = pila.pop()
                comp.append((x, y))
                for nx in (x - 1, x, x + 1):
                    for ny in (y - 1, y, y + 1):
                        if 0 <= nx < w and 0 <= ny < h and not visto[ny * w + nx] and a[nx, ny] > 128:
                            visto[ny * w + nx] = 1
                            pila.append((nx, ny))
            out.append(comp)
    return out


def recorte_limpio(im, caja, borrar=()):
    """Corte manual: se queda con la mancha mas grande (el personaje) y las que no tocan el borde de la caja;
    asi los restos de fotogramas vecinos que entran por el borde no aparecen. 'borrar' son zonas (en
    coordenadas de la hoja) que se vacian antes, para cuando el vecino entra pegado al efecto."""
    r = im.crop(caja)
    for bx0, by0, bx1, by1 in borrar:
        ImageDraw.Draw(r).rectangle((bx0 - caja[0], by0 - caja[1], bx1 - caja[0], by1 - caja[1]), fill=(0, 0, 0, 0))
    comps = manchas(r.getchannel('A'))
    mayor = max(comps, key=len)
    m = Image.new('L', r.size)
    mp = m.load()
    for comp in comps:
        toca = any(x == 0 or y == 0 or x == r.width - 1 or y == r.height - 1 for x, y in comp)
        # restos chicos pegados a los costados (ej. el borde del efecto del fotograma vecino)
        costado = len(comp) < len(mayor) * 0.03 and all(x < r.width * 0.12 or x > r.width * 0.88 for x, y in comp)
        if comp is mayor or not (toca or costado):
            for x, y in comp: mp[x, y] = 255
    r.putalpha(ImageChops.multiply(r.getchannel('A'), m))
    return r.crop(r.getbbox())


ADELGAZAR = 3     # pixeles (a media resolucion) que se adelgaza una mancha para cortar puentes finos de brillo


def _semillas(pts, cols, filas, w, h, celda_de):
    """Reparte pixeles entre celdas: cada celda con buena parte de ellos pone una semilla en el pixel mas
    cercano a su centro y una busqueda en anchura desde todas a la vez asigna cada pixel a la que llega primero."""
    cuenta = {}
    for x, y in pts: cuenta[celda_de(x, y)] = cuenta.get(celda_de(x, y), 0) + 1
    tope = max(cuenta.values())
    inicio = {}
    for (f, c), n in cuenta.items():
        if n < tope * 0.2: continue   # solo una punta del efecto del vecino: no es un fotograma propio
        cx, cy = (c + 0.5) * w / cols, (f + 0.6) * h / filas   # un poco abajo del centro: el cuerpo, no el efecto
        inicio[min(((x, y) for x, y in pts if celda_de(x, y) == (f, c)),
                   key=lambda p: (p[0] - cx) ** 2 + (p[1] - cy) ** 2)] = (f, c)
    return expandir(inicio, set(pts))


def expandir(dueno, puntos):
    """Busqueda en anchura desde los pixeles que ya tienen dueno: cada pixel de 'puntos' toma el del vecino
    que llega primero."""
    dueno = dict(dueno)
    frente = list(dueno)
    while frente:
        sig = []
        for x, y in frente:
            for nx in (x - 1, x, x + 1):
                for ny in (y - 1, y, y + 1):
                    if (nx, ny) in puntos and (nx, ny) not in dueno:
                        dueno[(nx, ny)] = dueno[(x, y)]
                        sig.append((nx, ny))
        frente = sig
    return dueno


def repartir_mancha(comp, cols, filas, w, h):
    """Reparte una mancha que une varios fotogramas. Primero la adelgaza: los puentes finos de brillo entre
    fotogramas se cortan, pero un chorro o un orbe (gruesos) siguen pegados a quien los lanza. Cada parte
    gruesa va a la celda de su centro y despues cada pixel vuelve a la parte gruesa mas cercana."""
    celda_de = lambda x, y: (min(filas - 1, y * filas // h), min(cols - 1, x * cols // w))
    m = Image.new('L', (w, h))
    mp = m.load()
    for x, y in comp: mp[x, y] = 255
    dueno = {}
    sueltas = []   # (parte, celda de su centro)
    for parte in manchas(m.filter(ImageFilter.MinFilter(2 * ADELGAZAR + 1))):
        xs, ys = [p[0] for p in parte], [p[1] for p in parte]
        if max(xs) - min(xs) > 1.5 * w / cols or max(ys) - min(ys) > 1.5 * h / filas:
            dueno.update(_semillas(parte, cols, filas, w, h, celda_de))   # sigue unida: por semillas
        else:
            sueltas.append((parte, celda_de(int(sum(xs) / len(parte)), int(sum(ys) / len(parte)))))
    mayor = {}
    for parte, celda in sueltas: mayor[celda] = max(mayor.get(celda, 0), len(parte))
    for parte, (f, c) in sueltas:
        # los personajes miran a la derecha: una parte chica en el borde izquierdo de una celda es el efecto
        # (chorro, orbe) que lanzo el fotograma de la izquierda
        cx = sum(p[0] for p in parte) / len(parte)
        if c > 0 and len(parte) < 0.35 * mayor[(f, c)] and cx - c * w / cols < 0.35 * w / cols:
            c -= 1
        for p in parte: dueno[p] = (f, c)
    if not dueno: dueno = _semillas(comp, cols, filas, w, h, celda_de)   # toda fina: no queda nada al adelgazar
    out = {}
    for p, celda in expandir(dueno, set(comp)).items(): out.setdefault(celda, []).append(p)
    return out


def recortes_cuadricula(im, cols, filas):
    """Para hojas donde los fotogramas se tocan (efectos que invaden la celda de al lado): divide la hoja en
    cols x filas celdas iguales y asigna cada mancha de pixeles conectados a la celda donde cae su centro
    (las manchas que unen fotogramas se reparten con repartir_mancha)."""
    W, H = im.size
    w, h = W // 2, H // 2   # a media resolucion, para que sea rapido
    por_celda = {}
    for comp in manchas(im.getchannel('A').resize((w, h), Image.NEAREST)):
        xs, ys = [p[0] for p in comp], [p[1] for p in comp]
        if max(xs) - min(xs) > 1.5 * w / cols or max(ys) - min(ys) > 1.5 * h / filas:
            # mancha que une dos fotogramas (ej. un chorro que toca al vecino): cada pixel va al fotograma cuyo
            # cuerpo esta mas cerca recorriendo la mancha por dentro (asi el chorro sigue pegado a su boca)
            for celda, pts in repartir_mancha(comp, cols, filas, w, h).items():
                por_celda.setdefault(celda, []).extend(pts)
        else:
            cx, cy = sum(xs) / len(comp), sum(ys) / len(comp)
            celda = (min(filas - 1, int(cy * filas / h)), min(cols - 1, int(cx * cols / w)))
            por_celda.setdefault(celda, []).extend(comp)
    out = []
    for celda in sorted(por_celda):   # orden de lectura: fila y despues columna
        m = Image.new('L', (w, h))
        mp = m.load()
        for x, y in por_celda[celda]: mp[x, y] = 255
        m = m.resize((W, H), Image.NEAREST)
        frame = im.copy()
        frame.putalpha(ImageChops.multiply(im.getchannel('A'), m))
        out.append(frame.crop(frame.getbbox()))
    return out


def quitar_fondo(im, tolerancia=3):
    """Hoja sin transparencia: borra el fondo (del color de las esquinas) conectado con los bordes."""
    im = im.convert('RGBA')
    for p in [(0, 0), (im.width - 1, 0), (0, im.height - 1), (im.width - 1, im.height - 1)]:
        if im.getpixel(p)[3]: ImageDraw.floodfill(im, p, (0, 0, 0, 0), thresh=tolerancia)
    return im


def celdas_ia(recortes, celda):
    """Fotogramas de una hoja generada por IA (grandes, sin grilla exacta): se reducen y se alinean."""
    cw, ch = celda
    factor = max(max(r.width / (cw - 2 * MARGEN), r.height / (ch - 2 * MARGEN)) for r in recortes)
    pal = paleta(recortes)
    out = []
    for r in recortes:
        c = reducir(r, factor, pal)
        c = c.crop(c.getbbox())
        cell = Image.new('RGBA', (cw, ch))
        # centrado por los pies (el cuarto de abajo), asi un arma o un efecto a un costado no mueve el cuerpo;
        # sin salirse de la celda
        pies = c.crop((0, c.height * 3 // 4, c.width, c.height)).getbbox() or (0, 0, c.width, 0)
        px = cw // 2 - (pies[0] + pies[2]) // 2
        px = max(MARGEN, min(px, cw - MARGEN - c.width)) if c.width <= cw - 2 * MARGEN else (cw - c.width) // 2
        cell.paste(c, (px, ch - MARGEN - c.height))   # pies en la misma fila
        out.append(cell)
    return out


def main():
    args = sys.argv[1:]
    cuadricula = None
    if '--cuadricula' in args:
        i = args.index('--cuadricula')
        cuadricula = tuple(int(v) for v in args[i + 1].lower().split('x'))
        del args[i:i + 2]
    recortes_manual = {}   # --recorte INDICE=x0,y0,x1,y1 : ese fotograma se corta a mano de la hoja original
    borrados = {}          # --borrar INDICE=x0,y0,x1,y1 : zona que se vacia dentro de ese recorte manual
    for opcion, destino in (('--recorte', recortes_manual), ('--borrar', borrados)):
        while opcion in args:
            i = args.index(opcion)
            k, _, v = args[i + 1].partition('=')
            caja = tuple(int(n) for n in v.split(','))
            if opcion == '--recorte': destino[int(k)] = caja
            else: destino.setdefault(int(k), []).append(caja)
            del args[i:i + 2]
    grilla = '--grilla' in args
    args = [a for a in args if a != '--grilla']
    hoja, celda, prefijo, specs = args[0], args[1], args[2], args[3:]
    celda = tuple(int(n) for n in celda.lower().split('x')) if 'x' in celda.lower() else (int(celda), int(celda))
    im = Image.open(hoja)
    im = im.convert('RGBA') if 'A' in im.getbands() else quitar_fondo(im)
    if grilla:
        celdas = celdas_grilla(im, celda)
    else:
        recortes = recortes_cuadricula(im, *cuadricula) if cuadricula else [im.crop(b) for b in cajas(im)]
        for i, caja in recortes_manual.items():
            recortes[i] = recorte_limpio(im, caja, borrados.get(i, ()))
        celdas = celdas_ia(recortes, celda)
    print(len(celdas), 'fotogramas encontrados')

    # vista previa ampliada de todos los fotogramas
    cw, ch = celda
    prev = Image.new('RGBA', (cw * len(celdas), ch), (40, 40, 48, 255))
    for i, c in enumerate(celdas): prev.alpha_composite(c, (i * cw, 0))
    prev.resize((prev.width * 6, prev.height * 6), Image.NEAREST).save(os.path.splitext(hoja)[0] + '_preview_x6.png')

    yyp = open(YYP, newline='').read()
    for spec in specs:
        sufijo, rango = spec.split('=')
        a, _, b = rango.partition('-')
        idx = list(range(int(a), int(b or a) + 1))
        nombre = f'{prefijo}_{sufijo}'
        base = f'sprites/{nombre}'
        ruta = f'{base}/{nombre}.yy'
        # reutilizar ids si el sprite ya existe y tiene la misma cantidad de fotogramas
        viejo = open(ruta, encoding='utf-8').read() if os.path.exists(ruta) else ''
        frames = re.findall(r'"\$GMSpriteFrame":"v1","%Name":"([^"]+)"', viejo)
        if len(frames) != len(idx): frames = [str(uuid.uuid4()) for _ in idx]
        lm = re.search(r'"\$GMImageLayer":"","%Name":"([^"]+)"', viejo)
        layer = lm.group(1) if lm and len(frames) == len(idx) else str(uuid.uuid4())
        kf_ids = re.findall(r'"Disabled":false,"id":"([^"]+)"', viejo)
        if len(kf_ids) != len(idx): kf_ids = [str(uuid.uuid4()) for _ in idx]
        for f, i in zip(frames, idx):
            os.makedirs(f'{base}/layers/{f}', exist_ok=True)
            celdas[i].save(f'{base}/{f}.png')
            celdas[i].save(f'{base}/layers/{f}/{layer}.png')
        open(ruta, 'w', newline='', encoding='utf-8').write(yy_sprite(nombre, frames, layer, celda, kf_ids))
        # validar que es JSON (GameMaker acepta comas finales)
        json.loads(re.sub(r',(\s*[}\]])', r'\1', open(ruta, encoding='utf-8').read()))
        if f'"name":"{nombre}"' not in yyp:
            ancla = '  "resources":[\n'
            yyp = yyp.replace(ancla, ancla + '    {"id":{"name":"%s","path":"%s",},},\n' % (nombre, ruta), 1)
        print(nombre, idx)
    open(YYP, 'w', newline='').write(yyp)


if __name__ == '__main__':
    main()
