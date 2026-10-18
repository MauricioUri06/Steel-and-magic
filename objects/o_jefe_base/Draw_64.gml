// Barra de vida grande arriba de la pantalla, con el nombre y marcas donde cambia de fase.
if (!es_enemigo) exit;

var _gw = display_get_gui_width(), _gh = display_get_gui_height();
var _bw = _gw * 0.5, _bx = (_gw - _bw) / 2, _by = 64;   // arriba, debajo del texto de oleadas (abajo esta la barra de XP)

draw_set_halign(fa_center);
draw_set_color(c_black);
draw_text(_gw / 2 + 1, _by - 21, nombre);
draw_set_color(c_white);
draw_text(_gw / 2, _by - 22, nombre);
draw_set_halign(fa_left);

draw_set_color(c_black);
draw_rectangle(_bx - 2, _by - 2, _bx + _bw + 2, _by + 13, false);
draw_set_color((estado == "transicion") ? c_white : make_colour_rgb(200, 30, 30));
draw_rectangle(_bx, _by, _bx + _bw * max(hp, 0) / hp_max, _by + 11, false);
draw_set_color(c_white);
for (var _i = 1; _i < array_length(fases); _i++) {
    var _mx = _bx + _bw * fases[_i].hp;
    draw_line(_mx, _by, _mx, _by + 11);
}
