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

// El mismo paisaje del menu, con parallax lento y brasas ascendiendo.
draw_sprite_stretched(s_menu_cielo, 0, 0, 0, _gw, _gh);
var _capas = [s_menu_lejano, s_menu_medio, s_menu_cercano];
for (var _i = 0; _i < 3; _i++) {
    var _off = (t * (5 + 7 * _i) * _u) mod _gw;
    draw_sprite_stretched(_capas[_i], 0, -_off, 0, _gw, _gh);
    draw_sprite_stretched(_capas[_i], 0, _gw - _off, 0, _gw, _gh);
}
draw_set_color(make_colour_rgb(4, 8, 18));
draw_set_alpha(0.65);
draw_rectangle(0, 0, _gw, _gh, false);
for (var _m = 0; _m < 24; _m++) {
    var _mx = (_m * 173 + sin(t + _m) * 14) mod _gw;
    var _my = _gh - ((_m * 79 + t * (12 + _m mod 5)) mod _gh);
    draw_set_color((_m mod 3 == 0) ? _cian : _oro);
    draw_set_alpha(0.2 + 0.25 * (0.5 + 0.5 * sin(t * 2 + _m)));
    draw_rectangle(_mx, _my, _mx + 2 * _u, _my + 2 * _u, false);
}

// Panel de acero oscuro, marco de bronce y esquinas de circuito.
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

// Espada ceremonial dentro de un anillo mecanico con nodos de energia.
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

var _r = boton_rect();
draw_sprite_stretched(s_boton_menu, floor(boton_frame), _r[0], _r[1], _r[2] - _r[0], _r[3] - _r[1]);
var _mezcla = boton_frame / max(1, sprite_get_number(s_boton_menu) - 1);
draw_set_font(fuente_boton);
draw_set_color(merge_colour(make_colour_rgb(255, 224, 130), make_colour_rgb(4, 18, 28), _mezcla));
draw_text_transformed(_cx, _y0 + 560 * _u, "VOLVER AL MENÚ", 1.5 * _u, 1.5 * _u, 0);
draw_set_color(merge_colour(make_colour_rgb(70, 38, 8), _cian, _mezcla));
draw_text_transformed(_cx, _y0 + 558 * _u, "VOLVER AL MENÚ", 1.5 * _u, 1.5 * _u, 0);
draw_set_font(fuente_texto);
draw_set_color(_acero);
draw_text_transformed(_cx, _y0 + 628 * _u, "ENTER / CLIC PARA VOLVER", 0.85 * _u, 0.85 * _u, 0);

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
