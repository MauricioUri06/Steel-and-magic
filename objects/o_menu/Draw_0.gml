gpu_set_texfilter(false);   // sin suavizado: pixel art nitido
draw_set_alpha(1);
draw_set_color(c_white);

// ===== Fondo: cielo fijo + 3 capas que se desplazan a distinta velocidad =====
draw_sprite_ext(s_menu_cielo, 0, 0, 0, fondo_esc, fondo_esc, 0, c_white, 1);
for (var _i = 0; _i < array_length(capas); _i++) {
    var _c = capas[_i];
    var _w = sprite_get_width(_c.spr) * fondo_esc;
    var _off = (fondo_t * _c.vel) mod _w;
    draw_sprite_ext(_c.spr, 0, -_off,      0, fondo_esc, fondo_esc, 0, c_white, 1);
    draw_sprite_ext(_c.spr, 0, _w - _off,  0, fondo_esc, fondo_esc, 0, c_white, 1);
}

if (pantalla == "principal") {
    // ----- titulo -----
    var _bob = sin(fondo_t * 0.03) * 4;
    if (spr_titulo != -1) {
        var _ts = min(2, 210 / sprite_get_height(spr_titulo), 1100 / sprite_get_width(spr_titulo));
        var _tw = sprite_get_width(spr_titulo), _th = sprite_get_height(spr_titulo);
        draw_sprite_ext(spr_titulo, 0,
            room_width / 2 + (sprite_get_xoffset(spr_titulo) - _tw / 2) * _ts,
            125 + _bob + (sprite_get_yoffset(spr_titulo) - _th / 2) * _ts, _ts, _ts, 0, c_white, 1);
    } else {
        draw_set_font(fuente_titulo);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        var _a = "STEEL", _b2 = " & ", _c2 = "MAGIC";
        var _wa = string_width(_a), _wb = string_width(_b2), _wc = string_width(_c2);
        var _x0 = room_width / 2 - (_wa + _wb + _wc) / 2;
        var _ty = 125 + _bob;
        var _acero1 = make_colour_rgb(225, 242, 252), _acero2 = make_colour_rgb(100, 135, 165);
        var _oro1 = make_colour_rgb(255, 236, 150);
        draw_text_colour(_x0 + 4, _ty + 4, _a + _b2 + _c2, c_black, c_black, c_black, c_black, 0.7);
        draw_text_colour(_x0, _ty, _a, _acero1, _acero1, _acero2, _acero2, 1);
        draw_text_colour(_x0 + _wa, _ty, _b2, c_white, c_white, col_cian, col_cian, 1);
        draw_text_colour(_x0 + _wa + _wb, _ty, _c2, _oro1, _oro1, col_oro_osc, col_oro_osc, 1);
    }

    // ----- botones -----
    for (var _j = 0; _j < array_length(botones); _j++) {
        var _bt = botones[_j];
        var _cy = boton_y0 + _j * (boton_h + boton_sep) + boton_h / 2;
        dibujar_boton(room_width / 2, _cy, _bt.frame, _bt.spr_texto);
    }

    // Resumen compacto del mejor final conseguido. Se mantiene en una esquina
    // para no competir con el titulo ni con los botones del menu.
    var _record = global.meta_progreso.record;
    if (_record.tiene_record) {
        var _ru = min(room_width / 1280, room_height / 720);
        var _rx = room_width - 350 * _ru;
        var _ry = room_height - 180 * _ru;
        draw_sprite_ext(spr_record_corner_panel, 0, _rx, _ry, _ru, _ru, 0, c_white, 1);

        draw_set_font(fuente_pix);
        draw_set_valign(fa_middle);
        draw_set_halign(fa_center);
        draw_set_color(col_oro);
        draw_text_transformed(_rx + 170 * _ru, _ry + 25 * _ru, "RÉCORD PERSONAL", 1.0 * _ru, 1.0 * _ru, 0);

        var _ri = [ico_record_time, ico_record_victories, meta_sprite_clase(_record.clase)];
        var _rl = ["MEJOR TIEMPO", "VICTORIAS", "ARMA DEL RÉCORD"];
        var _rv = [meta_formatear_tiempo(_record.mejor_tiempo), string(_record.victorias), meta_nombre_clase(_record.clase)];
        for (var _rf = 0; _rf < 3; _rf++) {
            var _rry = _ry + (65 + _rf * 40) * _ru;
            var _iesc = (_rf == 2) ? 0.50 * _ru : 0.66 * _ru;
            draw_sprite_ext(_ri[_rf], 0, _rx + 12 * _ru, _rry - 16 * _ru, _iesc, _iesc, 0, c_white, 1);
            draw_set_halign(fa_left);
            draw_set_color(col_texto);
            draw_text_transformed(_rx + 62 * _ru, _rry, _rl[_rf], 0.75 * _ru, 0.75 * _ru, 0);
            draw_set_halign(fa_right);
            draw_set_color(col_cian);
            draw_text_transformed(_rx + 322 * _ru, _rry, _rv[_rf], 0.82 * _ru, 0.82 * _ru, 0);
        }
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}
else if (pantalla == "tutorial") {
    dibujar_panel("Tutorial");
    // El contenido se recorta entre el titulo y el boton Volver y se desplaza con tut_scroll
    var _ar_top = 142, _ar_bot = 560;
    var _sc = gpu_get_scissor();
    gpu_set_scissor(140, _ar_top, room_width - 280, _ar_bot - _ar_top);
    var _off = -round(tut_scroll);
    var _filas = [
        ["W A S D / Flechas", "Moverte"],
        ["Mouse",             "Apuntar"],
        ["Clic izquierdo",    "Atacar (mantenlo para seguir atacando)"],
        ["1 / 2 / 3",         "Cambiar de clase: 1 Caballero, 2 Mago, 3 Soldado"],
        ["Espacio",           "Dash: eres invulnerable y haces daño a quien atraviesas"],
        ["M",                 "Ver las cartas (mejoras) que llevas en la partida"],
        ["Esc",               "Pausar el juego"]
    ];
    draw_set_font(fuente_texto);
    draw_set_valign(fa_middle);
    for (var _r = 0; _r < array_length(_filas); _r++) {
        var _y = 160 + _r * 32 + _off;
        draw_set_halign(fa_left);
        draw_text_colour(200, _y, _filas[_r][0], col_cian, col_cian, col_cian, col_cian, 1);
        draw_text_colour(470, _y, _filas[_r][1], col_texto, col_texto, col_texto, col_texto, 1);
    }
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    // Parrafos apilados: cada uno empieza justo debajo del anterior, asi no se pisan aunque cambie cuantas lineas ocupan
    var _par = [
        { txt: "Mago: mantén el clic para cargar la bola: más grande, más daño y más fuego en el suelo.", col: col_oro },
        { txt: "Derrota enemigos y recoge su experiencia: al subir de nivel eliges 1 de 3 cartas (clic o A / D, y Confirmar).", col: col_texto },
        { txt: "Las cartas raras y épicas salen menos. Al morir ganas monedas para las mejoras permanentes del menú.", col: col_texto }
    ];
    var _py = 380 + _off;
    for (var _p = 0; _p < array_length(_par); _p++) {
        draw_text_ext_colour(room_width / 2, _py, _par[_p].txt, 28, 900, _par[_p].col, _par[_p].col, _par[_p].col, _par[_p].col, 1);
        _py += string_height_ext(_par[_p].txt, 28, 900) + 6;
    }
    gpu_set_scissor(_sc);
    // cuanto contenido queda fuera del area visible (lo usa Step_0 para limitar el scroll)
    tut_max = max(0, (_py - _off) - _ar_bot);
    // barra de scroll, solo si hace falta
    if (tut_max > 0) {
        var _bx = room_width - 140 - 22, _bt = _ar_top + 6, _bh = _ar_bot - _ar_top - 12;
        var _th = max(30, _bh * (_ar_bot - _ar_top) / (_ar_bot - _ar_top + tut_max));
        var _ty2 = _bt + (_bh - _th) * (tut_scroll / tut_max);
        draw_set_alpha(0.35);
        draw_set_color(col_cian);
        draw_rectangle(_bx, _bt, _bx + 5, _bt + _bh, false);
        draw_set_alpha(1);
        draw_set_color(col_oro);
        draw_rectangle(_bx, _ty2, _bx + 5, _ty2 + _th, false);
        draw_set_color(c_white);
    }
    dibujar_boton(room_width / 2, volver_cy, volver_frame, volver_spr);
}
else if (pantalla == "mejoras") {
    // El menu principal dibuja directamente las mejoras. No se crean ni se
    // desactivan instancias, por lo que el fondo parallax continua funcionando.
    var _mu = min(room_width / 1280, room_height / 720);
    var _mpx = (room_width - 960 * _mu) * 0.5;
    var _mpy = (room_height - 480 * _mu) * 0.5;
    var _mfx = _mpx + 110 * _mu;
    var _mfy = _mpy + 88 * _mu;

    draw_set_alpha(0.72);
    draw_set_color(make_colour_rgb(3, 7, 12));
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);

    draw_sprite_part_ext(spr_meta_ui_atlas, 0, 192, 24, 640, 320, _mpx, _mpy, 1.5 * _mu, 1.5 * _mu, c_white, 1);
    draw_sprite_part_ext(spr_meta_ui_atlas, 0, 432, 672, 96, 96, _mpx + 88 * _mu, _mpy + 10 * _mu, 0.70 * _mu, 0.70 * _mu, c_white, 1);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
    draw_set_color(c_black);
    draw_text_transformed(_mpx + 174 * _mu + 2, _mpy + 18 * _mu + 2, "MEJORAS PERMANENTES", 2.0 * _mu, 2.0 * _mu, 0);
    draw_set_color(make_colour_rgb(225, 184, 76));
    draw_text_transformed(_mpx + 174 * _mu, _mpy + 18 * _mu, "MEJORAS PERMANENTES", 2.0 * _mu, 2.0 * _mu, 0);
    draw_set_color(make_colour_rgb(80, 220, 235));
    draw_text_transformed(_mpx + 176 * _mu, _mpy + 52 * _mu, "FORTALECE TU LEGADO", 0.9 * _mu, 0.9 * _mu, 0);

    draw_sprite_part_ext(spr_meta_ui_atlas, 0, 160, 704, 32, 32, _mpx + 700 * _mu, _mpy + 26 * _mu, 1.0 * _mu, 1.0 * _mu, c_white, 1);
    draw_set_color(make_colour_rgb(241, 211, 106));
    draw_text_transformed(_mpx + 740 * _mu, _mpy + 27 * _mu, string(global.meta_progreso.monedas_banco), 1.15 * _mu, 1.15 * _mu, 0);

    draw_set_color(make_colour_rgb(137, 170, 178));
    draw_text_transformed(_mfx + 48 * _mu, _mpy + 72 * _mu, "MEJORA", 0.72 * _mu, 0.72 * _mu, 0);
    draw_text_transformed(_mfx + 247 * _mu, _mpy + 72 * _mu, "EFECTO", 0.72 * _mu, 0.72 * _mu, 0);
    draw_text_transformed(_mfx + 410 * _mu, _mpy + 72 * _mu, "NIVEL", 0.72 * _mu, 0.72 * _mu, 0);
    draw_text_transformed(_mfx + 548 * _mu, _mpy + 72 * _mu, "COSTO", 0.72 * _mu, 0.72 * _mu, 0);

    var _meta = global.meta_progreso;
    for (var _mi = 0; _mi < array_length(_meta.mejoras); _mi++) {
        var _mejora = _meta.mejoras[_mi];
        var _mry = _mfy + _mi * 40 * _mu;

        draw_sprite_part_ext(spr_meta_ui_atlas, 0, 224, 384, 528, 40, _mfx, _mry, 1.40 * _mu, 1.0 * _mu, c_white, 1);
        draw_sprite_part_ext(spr_meta_ui_atlas, 0, _mejora.icon_x, _mejora.icon_y, 48, 48, _mfx + 8 * _mu, _mry + 4 * _mu, 0.66 * _mu, 0.66 * _mu, c_white, 1);

        draw_set_color(make_colour_rgb(221, 229, 226));
        draw_text_transformed(_mfx + 48 * _mu, _mry + 10 * _mu, _mejora.nombre, 0.80 * _mu, 0.80 * _mu, 0);
        draw_set_color(make_colour_rgb(86, 215, 229));
        draw_text_transformed(_mfx + 247 * _mu, _mry + 11 * _mu, _mejora.efecto, 0.72 * _mu, 0.72 * _mu, 0);

        var _paso = (_mejora.max_nivel > 5) ? 10 : 16;
        var _esc_nivel = (_mejora.max_nivel > 5) ? 0.50 : 0.70;
        for (var _mn = 0; _mn < _mejora.max_nivel; _mn++) {
            var _mnx = (_mn < _mejora.nivel) ? 336 : 272;
            draw_sprite_part_ext(spr_meta_ui_atlas, 0, _mnx, 704, 16, 16, _mfx + (410 + _mn * _paso) * _mu, _mry + 12 * _mu, _esc_nivel * _mu, _esc_nivel * _mu, c_white, 1);
        }

        var _maximo = (_mejora.nivel >= _mejora.max_nivel);
        var _costo = meta_costo_mejora(_mi);
        if (_maximo) {
            draw_set_color(make_colour_rgb(225, 184, 76));
            draw_text_transformed(_mfx + 548 * _mu, _mry + 11 * _mu, "MAX", 0.80 * _mu, 0.80 * _mu, 0);
        } else {
            draw_sprite_part_ext(spr_meta_ui_atlas, 0, 160, 704, 32, 32, _mfx + 542 * _mu, _mry + 11 * _mu, 0.50 * _mu, 0.50 * _mu, c_white, 1);
            draw_set_color(make_colour_rgb(241, 211, 106));
            draw_text_transformed(_mfx + 562 * _mu, _mry + 11 * _mu, string(_costo), 0.80 * _mu, 0.80 * _mu, 0);
        }

        var _habilitado = !_maximo && (_meta.monedas_banco >= _costo);
        var _estado_x = 184;
        if (!_habilitado) _estado_x = 712;
        else if (meta_fila_hover == _mi && mouse_check_button(mb_left)) _estado_x = 536;
        else if (meta_fila_hover == _mi) _estado_x = 360;
        draw_sprite_part_ext(spr_meta_ui_atlas, 0, _estado_x, 472, 128, 40, _mfx + 625 * _mu, _mry + 4 * _mu, 0.80 * _mu, 0.80 * _mu, c_white, 1);

        draw_set_halign(fa_center);
        draw_set_color(_habilitado ? make_colour_rgb(224, 240, 237) : make_colour_rgb(105, 116, 120));
        draw_text_transformed(_mfx + 676 * _mu, _mry + 12 * _mu, _maximo ? "MAXIMO" : "MEJORAR", 0.72 * _mu, 0.72 * _mu, 0);
        draw_set_halign(fa_left);
    }

    var _mvx = room_width * 0.5 - 116 * _mu;
    var _mvy = _mpy + 432 * _mu;
    var _mestado = meta_volver_hover ? (mouse_check_button(mb_left) ? 536 : 360) : 184;
    draw_sprite_part_ext(spr_meta_ui_atlas, 0, _mestado, 472, 128, 40, _mvx, _mvy, 1.81 * _mu, 0.90 * _mu, c_white, 1);
    draw_set_halign(fa_center);
    draw_set_color(make_colour_rgb(232, 239, 235));
    draw_text_transformed(room_width * 0.5, _mvy + 10 * _mu, "VOLVER AL MENU", 0.82 * _mu, 0.82 * _mu, 0);
}

// ===== Fundido =====
if (fade > 0) {
    draw_set_color(c_black);
    draw_set_alpha(fade);
    draw_rectangle(0, 0, room_width, room_height, false);
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
