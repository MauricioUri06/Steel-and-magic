var _gw = display_get_gui_width(), _gh = display_get_gui_height();
var _u = min(_gw / 1280, _gh / 720);
var _cx = _gw / 2, _y0 = (_gh - 720 * _u) / 2;
var _oro = make_colour_rgb(255, 214, 102);
var _bronce = make_colour_rgb(145, 103, 52);
var _cian = make_colour_rgb(110, 235, 255);
var _acero = make_colour_rgb(205, 224, 235);
gpu_set_texfilter(false);
draw_set_alpha(1);
draw_set_color(c_white);

// Fondo comun: la pantalla de victoria y el resumen son dos fases separadas.
draw_sprite_stretched(s_menu_cielo, 0, 0, 0, _gw, _gh);
var _capas = [s_menu_lejano, s_menu_medio, s_menu_cercano];
for (var _i = 0; _i < 3; _i++) {
    var _off = (t * (5 + 7 * _i) * _u) mod _gw;
    draw_sprite_stretched(_capas[_i], 0, -_off, 0, _gw, _gh);
    draw_sprite_stretched(_capas[_i], 0, _gw - _off, 0, _gw, _gh);
}
draw_set_color(make_colour_rgb(4, 8, 18));
draw_set_alpha(0.68);
draw_rectangle(0, 0, _gw, _gh, false);
for (var _m = 0; _m < 24; _m++) {
    var _mx = (_m * 173 + sin(t + _m) * 14) mod _gw;
    var _my = _gh - ((_m * 79 + t * (12 + _m mod 5)) mod _gh);
    draw_set_color((_m mod 3 == 0) ? _cian : _oro);
    draw_set_alpha(0.2 + 0.25 * (0.5 + 0.5 * sin(t * 2 + _m)));
    draw_rectangle(_mx, _my, _mx + 2 * _u, _my + 2 * _u, false);
}
draw_set_alpha(1);

if (fase == "victoria" || fase == "cambio") {
    // Primera fase: celebracion ya existente.
    var _left = _cx - 400 * _u, _right = _cx + 400 * _u;
    var _top = _y0 + 58 * _u, _bottom = _y0 + 660 * _u;
    draw_set_alpha(0.94);
    draw_set_color(make_colour_rgb(10, 17, 27));
    draw_rectangle(_left, _top, _right, _bottom, false);
    draw_set_alpha(1);
    draw_set_color(_bronce);
    draw_rectangle(_left, _top, _right, _bottom, true);
    draw_rectangle(_left + 5 * _u, _top + 5 * _u, _right - 5 * _u, _bottom - 5 * _u, true);
    draw_set_color(_cian);
    for (var _corner = 0; _corner < 4; _corner++) {
        var _sx = (_corner mod 2 == 0) ? 1 : -1;
        var _sy = (_corner < 2) ? 1 : -1;
        var _px = (_sx == 1) ? _left : _right;
        var _py = (_sy == 1) ? _top : _bottom;
        draw_line_width(_px, _py, _px + _sx * 42 * _u, _py, 2 * _u);
        draw_line_width(_px, _py, _px, _py + _sy * 42 * _u, 2 * _u);
    }

    var _logo_s = min(360 / sprite_get_width(s_menu_titulo), 74 / sprite_get_height(s_menu_titulo)) * _u;
    draw_sprite_ext(s_menu_titulo, 0,
        _cx + (sprite_get_xoffset(s_menu_titulo) - sprite_get_width(s_menu_titulo) / 2) * _logo_s,
        _y0 + 120 * _u + (sprite_get_yoffset(s_menu_titulo) - sprite_get_height(s_menu_titulo) / 2) * _logo_s,
        _logo_s, _logo_s, 0, c_white, 1);

    var _ey = _y0 + 217 * _u;
    draw_set_color(_bronce);
    draw_circle(_cx, _ey, 47 * _u, true);
    draw_set_color(_oro);
    draw_circle(_cx, _ey, 40 * _u, true);
    for (var _n = 0; _n < 8; _n++) {
        var _ang = _n * 45;
        var _nx = _cx + lengthdir_x(47 * _u, _ang);
        var _ny = _ey + lengthdir_y(47 * _u, _ang);
        draw_set_color((_n mod 2 == 0) ? _cian : _oro);
        draw_rectangle(_nx - 2 * _u, _ny - 2 * _u, _nx + 2 * _u, _ny + 2 * _u, false);
    }
    draw_set_color(_acero);
    draw_triangle(_cx, _ey - 32 * _u, _cx - 8 * _u, _ey + 9 * _u, _cx + 8 * _u, _ey + 9 * _u, false);
    draw_set_color(_cian);
    draw_line_width(_cx, _ey - 24 * _u, _cx, _ey + 8 * _u, 2 * _u);
    draw_set_color(_oro);
    draw_rectangle(_cx - 19 * _u, _ey + 9 * _u, _cx + 19 * _u, _ey + 14 * _u, false);
    draw_rectangle(_cx - 3 * _u, _ey + 14 * _u, _cx + 3 * _u, _ey + 29 * _u, false);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fuente_titulo);
    draw_set_color(c_black);
    draw_text_transformed(_cx + 3 * _u, _y0 + 317 * _u, "VICTORIA", 1.25 * _u, 1.25 * _u, 0);
    draw_set_color(_oro);
    draw_text_transformed(_cx, _y0 + 314 * _u, "VICTORIA", 1.25 * _u, 1.25 * _u, 0);
    draw_set_font(fuente_texto);
    draw_set_color(_acero);
    draw_text_transformed(_cx, _y0 + 369 * _u, "El General Demonio ha caído.", 1.3 * _u, 1.3 * _u, 0);
    draw_set_color(_bronce);
    draw_line_width(_cx - 240 * _u, _y0 + 411 * _u, _cx + 240 * _u, _y0 + 411 * _u, _u);
    draw_set_color(_cian);
    draw_text_transformed(_cx - 142 * _u, _y0 + 447 * _u, string(oleadas) + " OLEADAS", 1.5 * _u, 1.5 * _u, 0);
    draw_set_color(_oro);
    draw_text_transformed(_cx + 142 * _u, _y0 + 447 * _u, "NIVEL " + string(nivel_final), 1.5 * _u, 1.5 * _u, 0);
    draw_set_color(_acero);
    draw_text_transformed(_cx, _y0 + 481 * _u, "El acero resistió. La magia prevaleció.", _u, _u, 0);

    var _r_v = boton_rect();
    draw_sprite_stretched(s_boton_menu, floor(boton_frame), _r_v[0], _r_v[1], _r_v[2] - _r_v[0], _r_v[3] - _r_v[1]);
    var _mezcla_v = boton_frame / max(1, sprite_get_number(s_boton_menu) - 1);
    draw_set_font(fuente_boton);
    draw_set_color(merge_colour(make_colour_rgb(255, 224, 130), make_colour_rgb(4, 18, 28), _mezcla_v));
    draw_text_transformed(_cx, _y0 + 560 * _u, "VER RESUMEN", 1.5 * _u, 1.5 * _u, 0);
    draw_set_color(merge_colour(make_colour_rgb(70, 38, 8), _cian, _mezcla_v));
    draw_text_transformed(_cx, _y0 + 558 * _u, "VER RESUMEN", 1.5 * _u, 1.5 * _u, 0);
    draw_set_font(fuente_texto);
    draw_set_color(_acero);
    draw_text_transformed(_cx, _y0 + 628 * _u, "ENTER / CLIC PARA CONTINUAR", 0.85 * _u, 0.85 * _u, 0);
}
else {
    // Segunda fase: resumen de la partida frente al record personal guardado.
    var _fx = _cx - 480 * _u;
    var _fy = _y0 + 90 * _u;
    draw_sprite_ext(spr_record_frame, 0, _fx, _fy, _u, _u, 0, c_white, 1);
    draw_sprite_ext(spr_record_trophy, 0, _fx + 76 * _u, _fy + 20 * _u, 0.72 * _u, 0.72 * _u, 0, c_white, 1);
    draw_sprite_ext(spr_record_badge, 0, _cx - 128 * _u, _fy + 18 * _u, _u, _u, 0, c_white, 1);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fuente_boton);
    draw_set_color(nuevo_record ? _oro : _acero);
    draw_text_transformed(_cx, _fy + 54 * _u, nuevo_record ? "NUEVO RÉCORD" : "RESUMEN DE PARTIDA", 1.0 * _u, 1.0 * _u, 0);

    draw_set_font(fuente_texto);
    draw_set_color(_oro);
    draw_text_transformed(_fx + 240 * _u, _fy + 137 * _u, "ESTA PARTIDA", 1.05 * _u, 1.05 * _u, 0);
    draw_set_color(_cian);
    draw_text_transformed(_fx + 720 * _u, _fy + 137 * _u, "RÉCORD PERSONAL", 1.05 * _u, 1.05 * _u, 0);

    var _iconos = [ico_record_time, ico_record_enemies, ico_record_gold, ico_record_level];
    var _etiquetas = ["TIEMPO", "ENEMIGOS", "MONEDAS", "NIVEL"];
    var _actual = [meta_formatear_tiempo(tiempo_final), string(enemigos_final), string(monedas_final), string(nivel_final)];
    var _mejor = [meta_formatear_tiempo(record_guardado.mejor_tiempo), string(record_guardado.enemigos), string(record_guardado.monedas), string(record_guardado.nivel)];
    for (var _fila = 0; _fila < 4; _fila++) {
        var _ry = _fy + (190 + _fila * 50) * _u;
        draw_sprite_ext(_iconos[_fila], 0, _fx + 78 * _u, _ry - 20 * _u, 0.82 * _u, 0.82 * _u, 0, c_white, 1);
        draw_sprite_ext(_iconos[_fila], 0, _fx + 558 * _u, _ry - 20 * _u, 0.82 * _u, 0.82 * _u, 0, c_white, 1);
        draw_set_halign(fa_left);
        draw_set_color(_acero);
        draw_text_transformed(_fx + 130 * _u, _ry, _etiquetas[_fila], 0.82 * _u, 0.82 * _u, 0);
        draw_text_transformed(_fx + 610 * _u, _ry, _etiquetas[_fila], 0.82 * _u, 0.82 * _u, 0);
        draw_set_halign(fa_right);
        draw_set_color(_oro);
        draw_text_transformed(_fx + 402 * _u, _ry, _actual[_fila], 1.0 * _u, 1.0 * _u, 0);
        draw_set_color(_cian);
        draw_text_transformed(_fx + 882 * _u, _ry, _mejor[_fila], 1.0 * _u, 1.0 * _u, 0);
    }

    var _arma_y = _fy + 390 * _u;
    draw_sprite_ext(meta_sprite_clase(clase_final), 0, _fx + 82 * _u, _arma_y - 28 * _u, 0.78 * _u, 0.78 * _u, 0, c_white, 1);
    draw_sprite_ext(meta_sprite_clase(record_guardado.clase), 0, _fx + 562 * _u, _arma_y - 28 * _u, 0.78 * _u, 0.78 * _u, 0, c_white, 1);
    draw_set_halign(fa_left);
    draw_set_color(_acero);
    draw_text_transformed(_fx + 142 * _u, _arma_y - 8 * _u, "ARMA MÁS USADA", 0.72 * _u, 0.72 * _u, 0);
    draw_set_color(_oro);
    draw_text_transformed(_fx + 142 * _u, _arma_y + 12 * _u, meta_nombre_clase(clase_final), 0.82 * _u, 0.82 * _u, 0);
    draw_set_color(_acero);
    draw_text_transformed(_fx + 622 * _u, _arma_y - 8 * _u, "ARMA DEL RÉCORD", 0.72 * _u, 0.72 * _u, 0);
    draw_set_color(_cian);
    draw_text_transformed(_fx + 622 * _u, _arma_y + 12 * _u, meta_nombre_clase(record_guardado.clase), 0.82 * _u, 0.82 * _u, 0);

    draw_sprite_ext(ico_record_victories, 0, _fx + 790 * _u, _fy + 83 * _u, 0.68 * _u, 0.68 * _u, 0, c_white, 1);
    draw_set_halign(fa_left);
    draw_set_color(_oro);
    draw_text_transformed(_fx + 830 * _u, _fy + 99 * _u, "x " + string(record_guardado.victorias), 0.82 * _u, 0.82 * _u, 0);

    var _r_r = boton_rect();
    draw_sprite_stretched(s_boton_menu, floor(boton_frame), _r_r[0], _r_r[1], _r_r[2] - _r_r[0], _r_r[3] - _r_r[1]);
    var _mezcla_r = boton_frame / max(1, sprite_get_number(s_boton_menu) - 1);
    draw_set_halign(fa_center);
    draw_set_font(fuente_boton);
    draw_set_color(merge_colour(make_colour_rgb(255, 224, 130), make_colour_rgb(4, 18, 28), _mezcla_r));
    draw_text_transformed(_cx, _y0 + 560 * _u, "VOLVER AL MENÚ", 1.35 * _u, 1.35 * _u, 0);
    draw_set_color(merge_colour(make_colour_rgb(70, 38, 8), _cian, _mezcla_r));
    draw_text_transformed(_cx, _y0 + 558 * _u, "VOLVER AL MENÚ", 1.35 * _u, 1.35 * _u, 0);
}

// Transicion negra completa: nunca se ven las dos pantallas superpuestas.
if (fase == "cambio") {
    draw_set_alpha(transicion);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
}

var _fade = max(0, 1 - t / 0.65);
if (saliendo && instance_exists(jugador)) _fade = jugador.p_alpha_salida;
draw_set_alpha(_fade);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
gpu_set_texfilter(false);
