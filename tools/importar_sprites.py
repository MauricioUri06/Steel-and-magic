"""Convierte una hoja de sprites generada por IA (fondo transparente, fotogramas separados por espacio)
en sprites de GameMaker con celdas de tamano fijo, y los registra en el proyecto.

Uso (desde la raiz del repo, requiere pillow):
    python tools/importar_sprites.py HOJA CELDA PREFIJO NOMBRE=FRAMES [NOMBRE=FRAMES ...]

    python tools/importar_sprites.py art/enemies/orco/orco_sheet.webp 48 spr_orco \
        caminar=0-3 aviso=4-5 embestida=6 recuperar=7 caida=8 muerto=9

Los fotogramas se numeran de izquierda a derecha y de arriba a abajo, empezando en 0.
Todos se reducen con el MISMO factor (el mayor fotograma entra en la celda), con los pies en la misma
linea y centrados en horizontal. El origen queda en el centro de la celda. Volver a correrlo
reemplaza los PNG pero conserva los ids del .yy, asi GameMaker no ve recursos nuevos.
"""
import os, re, sys, uuid, json
from PIL import Image

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


def paleta(im):
    """Paleta comun de la hoja (solo pixeles opacos), para que todos los fotogramas usen los mismos colores."""
    b = im.tobytes()
    opacos = [tuple(b[i:i + 3]) for i in range(0, len(b), 4) if b[i + 3] > 128]
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
    m = celda // 2
    for k, v in {'length': '%d.0' % len(frames), 'width': celda, 'height': celda, 'xorigin': m, 'yorigin': m,
                 'bbox_left': 0, 'bbox_top': 0, 'bbox_right': celda - 1, 'bbox_bottom': celda - 1}.items():
        t, n = re.subn(r'"%s":[0-9.]+,' % k, '"%s":%s,' % (k, v), t)
        assert n == 1, k
    return t


def main():
    hoja, celda, prefijo, specs = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4:]
    im = Image.open(hoja).convert('RGBA')
    bs = cajas(im)
    print(len(bs), 'fotogramas encontrados')
    factor = max(max(b[2] - b[0], b[3] - b[1]) for b in bs) / (celda - 2 * MARGEN)
    pal = paleta(im)
    chicos = [reducir(im.crop(b), factor, pal) for b in bs]

    celdas = []
    for c in chicos:
        cell = Image.new('RGBA', (celda, celda))
        bb = c.getbbox()
        c = c.crop(bb)
        cell.paste(c, ((celda - c.width) // 2, celda - MARGEN - c.height))   # pies en la misma fila
        celdas.append(cell)

    # vista previa ampliada de todos los fotogramas
    prev = Image.new('RGBA', (celda * len(celdas), celda), (40, 40, 48, 255))
    for i, c in enumerate(celdas): prev.alpha_composite(c, (i * celda, 0))
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
