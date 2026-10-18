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

    // ----- boton Options (arriba a la izquierda) -----
    var _ofr = clamp(floor(opt_frame), 0, frames_boton - 1);
    draw_sprite_ext(s_boton_menu, _ofr, opt_x, opt_y, 1, 1, 0, c_white, 1);
    var _ot = opt_frame / (frames_boton - 1);
    var _ocol = merge_colour(make_colour_rgb(70, 38, 8), col_cian, _ot);
    var _osom = merge_colour(make_colour_rgb(255, 224, 130), make_colour_rgb(4, 18, 28), _ot);
    draw_sprite_ext(opt_spr, 0, opt_x + opt_w / 2, opt_y + opt_h / 2 + 1, 1, 1, 0, _osom, 1);
    draw_sprite_ext(opt_spr, 0, opt_x + opt_w / 2, opt_y + opt_h / 2,     1, 1, 0, _ocol, 1);

    // ----- creditos: esquina de abajo a la izquierda (el record ocupa la de la derecha) -----
    // Sin escalar: con las fuentes a su tamano real el texto se ve completo y nitido
    var _crx = 40;
    var _cr_bajo = room_height - 26;
    draw_set_halign(fa_left);
    draw_set_valign(fa_bottom);
    draw_set_font(fuente_boton);
    var _cr_alto2 = string_height("Gaira");
    draw_text_colour(_crx + 2, _cr_bajo + 2, "Gaira", c_black, c_black, c_black, c_black, 0.7);
    draw_text_colour(_crx, _cr_bajo, "Gaira", col_oro, col_oro, col_oro, col_oro, 1);
    draw_set_font(fuente_texto);
    draw_text_colour(_crx + 2, _cr_bajo - _cr_alto2 + 6, "Desarrollado por:", c_black, c_black, c_black, c_black, 0.7);
    draw_text_colour(_crx, _cr_bajo - _cr_alto2 + 4, "Desarrollado por:", col_texto, col_texto, col_texto, col_texto, 1);
    draw_set_valign(fa_top);
}
else if (pantalla == "tutorial") {
    dibujar_panel("Cómo jugar");
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

    var _mvy = _mpy + 432 * _mu;
    var _mrx = room_width * 0.5 - 250 * _mu;
    var _mvx = room_width * 0.5 + 30 * _mu;
    var _mreset_estado = meta_reset_hover ? (mouse_check_button(mb_left) ? 536 : 360) : 184;
    var _mvolver_estado = meta_volver_hover ? (mouse_check_button(mb_left) ? 536 : 360) : 184;
    draw_sprite_part_ext(spr_meta_ui_atlas, 0, _mreset_estado, 472, 128, 40, _mrx, _mvy, 1.72 * _mu, 0.90 * _mu, c_white, 1);
    draw_sprite_part_ext(spr_meta_ui_atlas, 0, _mvolver_estado, 472, 128, 40, _mvx, _mvy, 1.72 * _mu, 0.90 * _mu, c_white, 1);
    draw_set_halign(fa_center);
    draw_set_color(meta_reset_hover ? make_colour_rgb(255, 201, 112) : make_colour_rgb(219, 151, 94));
    draw_text_transformed(_mrx + 110 * _mu, _mvy + 10 * _mu, "REINICIAR MEJORAS", 0.68 * _mu, 0.68 * _mu, 0);
    draw_set_color(make_colour_rgb(232, 239, 235));
    draw_text_transformed(_mvx + 110 * _mu, _mvy + 10 * _mu, "VOLVER AL MENU", 0.76 * _mu, 0.76 * _mu, 0);

    if (meta_confirmacion_abierta) {
        // Advertencia modal con la misma paleta de acero, oro y energia cian.
        draw_set_alpha(0.82);
        draw_set_color(c_black);
        draw_rectangle(0, 0, room_width, room_height, false);
        draw_set_alpha(1);

        var _mcx = room_width * 0.5, _mcy = room_height * 0.5;
        var _mx1 = _mcx - 340 * _mu, _my1 = _mcy - 165 * _mu;
        var _mx2 = _mcx + 340 * _mu, _my2 = _mcy + 155 * _mu;
        draw_set_color(make_colour_rgb(8, 14, 23));
        draw_rectangle(_mx1, _my1, _mx2, _my2, false);
        draw_set_color(make_colour_rgb(159, 102, 33));
        draw_rectangle(_mx1, _my1, _mx2, _my2, true);
        draw_rectangle(_mx1 + 4 * _mu, _my1 + 4 * _mu, _mx2 - 4 * _mu, _my2 - 4 * _mu, true);
        draw_set_color(make_colour_rgb(75, 215, 231));
        draw_line_width(_mx1 + 18 * _mu, _my1 + 12 * _mu, _mx2 - 18 * _mu, _my1 + 12 * _mu, 2 * _mu);

        draw_set_font(fuente_texto);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(make_colour_rgb(255, 205, 91));
        draw_text_transformed(_mcx, _mcy - 105 * _mu, "REINICIAR MEJORAS", 1.25 * _mu, 1.25 * _mu, 0);
        draw_set_color(make_colour_rgb(236, 238, 236));
        draw_text_transformed(_mcx, _mcy - 52 * _mu, "¿ESTÁS SEGURO?", 0.95 * _mu, 0.95 * _mu, 0);
        draw_set_color(make_colour_rgb(206, 216, 220));
        draw_text_transformed(_mcx, _mcy - 15 * _mu, "Perderás todos los niveles de tus mejoras permanentes.", 0.68 * _mu, 0.68 * _mu, 0);
        draw_set_color(make_colour_rgb(92, 211, 225));
        draw_text_transformed(_mcx, _mcy + 14 * _mu, "Tus monedas y récords se conservarán.", 0.68 * _mu, 0.68 * _mu, 0);

        var _ccx = _mcx - 145 * _mu, _crx = _mcx + 145 * _mu;
        var _cby = _mcy + 92 * _mu, _cbw = 240 * _mu, _cbh = 64 * _mu;
        var _cf_cancel = (meta_confirmacion_sel == 0 || meta_confirm_cancel_hover) ? sprite_get_number(s_boton_menu) - 1 : 0;
        var _cf_reset = (meta_confirmacion_sel == 1 || meta_confirm_reset_hover) ? sprite_get_number(s_boton_menu) - 1 : 0;
        draw_sprite_stretched(s_boton_menu, _cf_cancel, _ccx - _cbw * 0.5, _cby - _cbh * 0.5, _cbw, _cbh);
        draw_sprite_stretched(s_boton_menu, _cf_reset, _crx - _cbw * 0.5, _cby - _cbh * 0.5, _cbw, _cbh);
        draw_set_font(fuente_pix);
        draw_set_color(meta_confirmacion_sel == 0 ? col_cian : col_texto);
        draw_text_transformed(_ccx, _cby, "CANCELAR", 1.1 * _mu, 1.1 * _mu, 0);
        draw_set_color(meta_confirmacion_sel == 1 ? make_colour_rgb(255, 187, 96) : col_texto);
        draw_text_transformed(_crx, _cby, "REINICIAR", 1.1 * _mu, 1.1 * _mu, 0);
    }
}
else if (pantalla == "opciones") {
    dibujar_panel("Options");
    draw_set_valign(fa_middle);
    for (var _oi = 0; _oi < array_length(opt_sliders); _oi++) {
        var _ov = opt_get(_oi);
        var _ocy = opt_fila_y0 + _oi * opt_fila_sep;
        var _osel = (opt_sel == _oi);
        var _ox0 = opt_pista_x, _ow = opt_pista_w;
        draw_set_font(fuente_texto);
        draw_set_halign(fa_left);
        var _otc = _osel ? col_oro : col_texto;
        draw_text_colour(220, _ocy, opt_sliders[_oi].nombre, _otc, _otc, _otc, _otc, 1);
        // barra: fondo, parte llena y borde
        draw_set_color(make_colour_rgb(30, 40, 58));
        draw_rectangle(_ox0, _ocy - 6, _ox0 + _ow, _ocy + 6, false);
        draw_set_color(col_oro_osc);
        draw_rectangle(_ox0, _ocy - 6, _ox0 + _ow * _ov, _ocy + 6, false);
        draw_set_color(_osel ? col_oro : col_cian);
        draw_rectangle(_ox0 - 1, _ocy - 7, _ox0 + _ow + 1, _ocy + 7, true);
        // perilla
        var _okx = _ox0 + _ow * _ov;
        draw_set_color(col_oro);
        draw_rectangle(_okx - 8, _ocy - 16, _okx + 8, _ocy + 16, false);
        draw_set_color(col_oro_osc);
        draw_rectangle(_okx - 8, _ocy - 16, _okx + 8, _ocy + 16, true);
        draw_set_color(c_white);
        // porcentaje
        draw_text_colour(_ox0 + _ow + 40, _ocy, string(round(_ov * 100)) + "%", col_cian, col_cian, col_cian, col_cian, 1);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    dibujar_boton(room_width / 2, volver_cy, volver_frame, volver_spr);
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
