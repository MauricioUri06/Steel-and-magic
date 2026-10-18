// ===== Enemigo base (padre de TODOS los enemigos) =====
// Arbol:  o_enemigo_base -> o_enemigo_melee / o_enemigo_rango -> cada enemigo.
// Los hijos, en su Create, llaman event_inherited() y cambian estos valores.
// Contrato con el jugador y sus proyectiles: es_enemigo = true, hp, y el metodo recibir_dano(_cantidad).

es_enemigo   = true;
hp_max       = 10;
hp           = hp_max;
vel          = 1.5;     // px por paso (nombre propio: "speed" es una variable reservada de GameMaker)
radio        = 12;      // tamano del dibujo (la colision usa la mascara spr_enemigo_mask, 24x24)
color        = c_red;
volador      = false;   // true = ignora las paredes (o_solid)
monedas_drop = 1;       // monedas que suma al jugador al morir
xp_drop      = 1;       // experiencia que suelta al morir (en orbes que el jugador junta)

mask_index = spr_enemigo_mask;   // los hijos no heredan la mascara del .yy; en el Step se escala segun el radio

estado   = "perseguir"; // cada padre define sus estados; la muerte usa "cayendo" y "muerto"
timer    = 0;           // contador de uso libre para el estado actual
dir_mira = 0;           // hacia donde mira (grados)
flash    = 0;           // pasos que se dibuja en blanco despues de recibir dano

pesado       = false;   // true = los demas enemigos no lo empujan (jefes)
barra_vida   = true;    // barra chica sobre la cabeza (los jefes usan la barra grande del HUD)
alpha_cuerpo = 1;       // transparencia del cuerpo (ej. un jefe que desaparece o vuela fuera de pantalla)

// ===== Sprites (opcional) =====
// Si un hijo llena este struct, se dibuja con sprites en vez de con formas: { estado: sprite }.
// Ejemplo: spr_por_estado = { perseguir: spr_orco_caminar, cayendo: spr_orco_caida, muerto: spr_orco_muerto };
// Se busca primero "estado_variante" (ej. "aviso_misiles" para el ataque de un jefe), despues "estado"
// y por ultimo "perseguir". Los sprites miran a la DERECHA; se voltean solos.
spr_por_estado = {};
variante       = "";    // sub-estado para elegir sprite (ej. el ataque actual de un jefe)
escala_sprite  = 1.4;   // igual que escala_jugador, para que los pixeles midan lo mismo
anim_vel       = 0.15;  // cuadros por paso (0.15 = 9 cuadros por segundo)
anim           = 0;     // cuadro actual
spr_actual     = -1;
lado           = 1;     // 1 = mira a la derecha, -1 = a la izquierda

// Claves que se prueban en spr_por_estado, en orden. Un hijo la puede reemplazar (ej. fases de un jefe).
claves_sprite = function() {
    return [estado + "_" + variante, estado, "perseguir"];
};
buscar_sprite = function() {
    var _c = claves_sprite();
    for (var _i = 0; _i < array_length(_c); _i++) {
        if (variable_struct_exists(spr_por_estado, _c[_i])) return spr_por_estado[$ _c[_i]];
    }
    return -1;
};

// ===== Muerte =====
dur_caida  = 24;        // pasos con el sprite de caida
dur_muerto = 60;        // pasos que el cadaver tarda en desvanecerse

// Lo llaman el dash, los proyectiles y los efectos del jugador.
recibir_dano = function(_cantidad) {
    hp -= _cantidad;
    flash = 6;
};

// Deja de ser enemigo (no recibe golpes, no estorba) y empieza la animacion de muerte.
morir = function() {
    if (instance_exists(o_player)) {
        o_player.monedas += monedas_drop;
        o_player.enemigo_derrotado(0);   // cuenta la baja (carta de Curacion); la xp va en los orbes
    }
    soltar_xp(xp_drop);
    es_enemigo = false;
    mask_index = -1;    // sin sprite_index = sin colision
    flash      = 0;
    alpha_cuerpo = 1;
    variante   = "";
    estado     = "cayendo";
    timer      = dur_caida;
};

// Suelta la experiencia en orbes (como mucho 6; si hay mucha, cada orbe vale mas).
soltar_xp = function(_xp) {
    var _n = min(_xp, 6);
    for (var _i = 0; _i < _n; _i++) {
        var _valor = (_xp div _n) + (_i < _xp mod _n ? 1 : 0);
        instance_create_depth(x, y, depth + 1, o_orbe_xp, { valor: _valor });
    }
};

// Mueve en un angulo; si no vuela, se desliza contra las paredes (cada eje por separado).
// mover_crudo no se ve afectado por la lentitud (lo usa el empuje); mover si.
mover_crudo = function(_dir, _vel) {
    var _dx = lengthdir_x(_vel, _dir);
    var _dy = lengthdir_y(_vel, _dir);
    if (volador || !place_meeting(x + _dx, y, o_solid)) x += _dx;
    if (volador || !place_meeting(x, y + _dy, o_solid)) y += _dy;
    x = clamp(x, radio, room_width - radio);
    y = clamp(y, radio, room_height - radio);
};
mover = function(_dir, _vel) {
    if (lento_t > 0) _vel *= lento_f;
    mover_crudo(_dir, _vel);
};

// ===== Estados que ponen las cartas del jugador (quemadura, lentitud, empuje) =====
// Se actualizan en el Step de este objeto. Los jefes (pesado = true) no se empujan y se frenan la mitad.
quemadura_t    = 0;    // pasos que le quedan ardiendo
quemadura_dano = 1;    // dano de cada golpe de quemadura
quemadura_tick = 0;    // pasos para el proximo golpe
lento_t        = 0;    // pasos que le quedan ralentizado
lento_f        = 1;    // multiplicador de velocidad mientras esta ralentizado (0.5 = la mitad)
emp_dir        = 0;    // empuje: direccion y fuerza actual (px por paso, se apaga solo)
emp_f          = 0;

quemar = function(_pasos, _dano) {
    quemadura_t    = max(quemadura_t, _pasos);
    quemadura_dano = _dano;
    if (quemadura_tick <= 0) quemadura_tick = 30;
};
ralentizar = function(_factor, _pasos) {
    if (pesado) _factor = lerp(_factor, 1, 0.5);
    lento_f = (lento_t > 0) ? min(lento_f, _factor) : _factor;
    lento_t = max(lento_t, _pasos);
};
empujar = function(_dir, _fuerza) {
    if (pesado) return;
    emp_dir = _dir;
    emp_f   = max(emp_f, _fuerza);
};

// IA del enemigo: cada padre la reemplaza. Por defecto solo persigue.
comportamiento = function() {
    if (!instance_exists(o_player)) return;
    dir_mira = point_direction(x, y, o_player.x, o_player.y);
    mover(dir_mira, vel);
};

// Dibujo extra encima del cuerpo (avisos de ataque, escudos...). Cada padre o hijo la reemplaza.
dibujar_extra = function() {};
// Dibujo en el suelo, DEBAJO del cuerpo (grietas, sombras...). Cada padre o hijo la reemplaza.
dibujar_suelo = function() {};

// Distancia en y desde el origen hasta los pies (para dibujar cosas en el suelo).
pies_dy = function() {
    if (spr_actual == -1) return radio;
    return (sprite_get_height(spr_actual) - sprite_get_yoffset(spr_actual) - 2) * escala_sprite;
};

// ===== Grieta en el suelo (aviso de embestidas) =====
// crear_grieta(largo) al empezar el aviso, y dibujar_grieta(0..1) desde dibujar_suelo mientras dura.
grieta_color = make_colour_rgb(25, 18, 14);
grieta_luz   = make_colour_rgb(110, 95, 80);   // borde claro, da sensacion de profundidad
grieta       = [];     // puntos del trazo principal: { d: distancia a lo largo, o: desvio lateral }
grieta_ramas = [];     // ramitas: { d, o, ang, largo }
grieta_x     = 0;      // desde donde sale (los pies al empezar el aviso)
grieta_y     = 0;
grieta_dir   = 0;

// Se genera una vez por ataque (si se generara en cada Draw, temblaria). Sale de los pies hacia dir_mira.
crear_grieta = function(_largo) {
    grieta = []; grieta_ramas = [];
    grieta_x = x;
    grieta_y = y + pies_dy();
    grieta_dir = dir_mira;
    var _o = 0;
    for (var _d = 0; _d <= _largo; _d += 7) {
        _o = clamp(_o + irandom_range(-3, 3), -5, 5);
        array_push(grieta, { d: _d, o: (_d == 0) ? 0 : _o });
        if (_d > 10 && random(1) < 0.3) {
            array_push(grieta_ramas, { d: _d, o: _o, ang: choose(-1, 1) * irandom_range(30, 60), largo: irandom_range(5, 10) });
        }
    }
};

// punto de la grieta en coordenadas del room
grieta_px = function(_d, _o) { return grieta_x + lengthdir_x(_d, grieta_dir) + lengthdir_x(_o, grieta_dir + 90); };
grieta_py = function(_d, _o) { return grieta_y + lengthdir_y(_d, grieta_dir) + lengthdir_y(_o, grieta_dir + 90); };

// _hasta: 0..1, cuanto de la grieta se ve (para que crezca durante el aviso)
dibujar_grieta = function(_hasta) {
    if (array_length(grieta) == 0) return;
    var _max = _hasta * grieta[array_length(grieta) - 1].d;
    draw_set_alpha(0.85);
    for (var _i = 1; _i < array_length(grieta); _i++) {
        var _a = grieta[_i - 1], _b = grieta[_i];
        if (_b.d > _max) break;
        var _w = lerp(3, 1, _b.d / max(1, _max + 7));   // mas ancha cerca del enemigo
        draw_set_color(grieta_luz);
        draw_line_width(grieta_px(_a.d, _a.o), grieta_py(_a.d, _a.o) + 1, grieta_px(_b.d, _b.o), grieta_py(_b.d, _b.o) + 1, 1);
        draw_set_color(grieta_color);
        draw_line_width(grieta_px(_a.d, _a.o), grieta_py(_a.d, _a.o), grieta_px(_b.d, _b.o), grieta_py(_b.d, _b.o), _w);
    }
    draw_set_color(grieta_color);
    for (var _j = 0; _j < array_length(grieta_ramas); _j++) {
        var _r = grieta_ramas[_j];
        if (_r.d > _max) continue;
        var _x0 = grieta_px(_r.d, _r.o), _y0 = grieta_py(_r.d, _r.o);
        draw_line_width(_x0, _y0, _x0 + lengthdir_x(_r.largo, grieta_dir + _r.ang), _y0 + lengthdir_y(_r.largo, grieta_dir + _r.ang), 1);
    }
    draw_set_alpha(1);
};
