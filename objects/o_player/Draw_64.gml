pausa_dibujar_fondo();

// Panel compacto, centrado y apoyado en el borde inferior.
var _gw = display_get_gui_width(), _gh = display_get_gui_height();
var _u = min(_gw / 1280, _gh / 720);
var _x = (_gw - 1000 * _u) / 2, _y = _gh - 92 * _u;
var _arma = hud_estadisticas_arma();
var _vida = clamp(hp / hp_max, 0, 1);
var _max_nivel = nivel >= nivel_max;
var _xp = _max_nivel ? 1 : clamp(xp / xp_sig, 0, 1);
var _texto = make_colour_rgb(205, 221, 230);
var _cian = make_colour_rgb(104, 222, 242);
var _oro = make_colour_rgb(225, 189, 108);
var _borde = [[0,92],[0,32],[13,23],[9,9],[33,13],[48,5],[65,11],
              [935,11],[952,5],[967,13],[991,9],[987,23],[1000,32],[1000,92]];
var _n = array_length(_borde);
gpu_set_texfilter(false);
draw_set_font(hud_fuente);

// La sombra sigue la silueta; los pequenos picos no invaden el espacio de juego.
draw_set_color(c_black);
for (var _s = 3; _s >= 1; _s--) {
    draw_set_alpha(0.1);
    draw_primitive_begin(pr_trianglefan);
    draw_vertex(_x + 500 * _u, _y + (55 - _s * 3) * _u);
    for (var _i = 0; _i <= _n; _i++) {
        var _p = _borde[_i mod _n];
        draw_vertex(_x + _p[0] * _u, _y + (_p[1] - _s * 3) * _u);
    }
    draw_primitive_end();
}
draw_set_alpha(1);
for (var _capa = 0; _capa < 2; _capa++) {
    draw_set_color((_capa == 0) ? make_colour_rgb(72, 88, 97) : make_colour_rgb(10, 19, 28));
    draw_primitive_begin(pr_trianglefan);
    draw_vertex(_x + 500 * _u, _y + 55 * _u);
    for (var _j = 0; _j <= _n; _j++) {
        var _v = _borde[_j mod _n];
        var _vx = (_capa == 0) ? _v[0] : lerp(_v[0], 500, 0.008);
        var _vy = (_capa == 0) ? _v[1] : min(92, _v[1] + 4);
        draw_vertex(_x + _vx * _u, _y + _vy * _u);
    }
    draw_primitive_end();
}

// Bisel y pequenas marcas de metal cepillado en el marco.
draw_set_color(make_colour_rgb(125, 142, 149));
for (var _edge = 1; _edge < _n - 1; _edge++) {
    var _a = _borde[_edge], _b = _borde[_edge + 1];
    draw_line_width(_x + _a[0] * _u, _y + _a[1] * _u, _x + _b[0] * _u, _y + _b[1] * _u, _u);
}
for (var _marca = 86; _marca < 930; _marca += 24) {
    draw_set_color(make_colour_rgb(42, 58, 68));
    draw_line_width(_x + _marca * _u, _y + 12 * _u, _x + (_marca + 6) * _u, _y + 15 * _u, _u);
}
draw_set_color(make_colour_rgb(113, 143, 151));
for (var _ranura = 0; _ranura < 3; _ranura++) {
    var _ry = _y + (43 + _ranura * 8) * _u;
    draw_line_width(_x + 9 * _u, _ry, _x + 17 * _u, _ry - 3 * _u, _u);
    draw_line_width(_x + 983 * _u, _ry - 3 * _u, _x + 991 * _u, _ry, _u);
}
draw_set_color(make_colour_rgb(37, 54, 66));
for (var _sep = 0; _sep < 3; _sep++) {
    var _dx = [_x + 98 * _u, _x + 215 * _u, _x + 760 * _u][_sep];
    draw_line_width(_dx, _y + 28 * _u, _dx, _gh - 13 * _u, _u);
}

// Barras y valores: vida arriba, experiencia debajo.
var _bx = _x + 234 * _u, _bw = 500 * _u;
draw_set_color(make_colour_rgb(34, 49, 58));
draw_rectangle(_bx, _y + 27 * _u, _bx + _bw, _y + 49 * _u, false);
draw_set_color((_vida <= 0.25) ? make_colour_rgb(195, 62, 68) : make_colour_rgb(47, 137, 101));
if (_vida > 0) draw_rectangle(_bx, _y + 27 * _u, _bx + _bw * _vida, _y + 49 * _u, false);
draw_set_color(make_colour_rgb(25, 42, 55));
draw_rectangle(_bx, _y + 61 * _u, _bx + _bw, _y + 75 * _u, false);
draw_set_color(make_colour_rgb(42, 112, 149));
if (_xp > 0) draw_rectangle(_bx, _y + 61 * _u, _bx + _bw * _xp, _y + 75 * _u, false);
var _hp_texto = "VIDA  " + string(ceil(max(0, hp))) + " / " + string(hp_max);
var _xp_texto = _max_nivel ? "XP  MAX" : "XP  " + string(xp) + " / " + string(xp_sig);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_text_transformed(_bx + _bw / 2, _y + 40 * _u, _hp_texto, _u, _u, 0);
draw_text_transformed(_bx + _bw / 2, _y + 70 * _u, _xp_texto, 0.85 * _u, 0.85 * _u, 0);
draw_set_color(c_white);
draw_text_transformed(_bx + _bw / 2, _y + 38 * _u, _hp_texto, _u, _u, 0);
draw_text_transformed(_bx + _bw / 2, _y + 68 * _u, _xp_texto, 0.85 * _u, 0.85 * _u, 0);

// Oro de esta partida: el mismo contador al que entregan monedas los enemigos.
draw_set_color(_texto);
draw_text_transformed(_x + 54 * _u, _y + 35 * _u, "NIVEL", 0.85 * _u, 0.85 * _u, 0);
draw_text_transformed(_x + 817 * _u, _y + 35 * _u, "DAÑO", 0.85 * _u, 0.85 * _u, 0);
draw_text_transformed(_x + 930 * _u, _y + 35 * _u, "ATQ/S", 0.85 * _u, 0.85 * _u, 0);
draw_set_color(_oro);
draw_text_transformed(_x + 156 * _u, _y + 35 * _u, "ORO", 0.85 * _u, 0.85 * _u, 0);
draw_text_transformed(_x + 156 * _u, _y + 64 * _u, string(monedas), 1.3 * _u, 1.3 * _u, 0);
draw_text_transformed(_x + 817 * _u, _y + 64 * _u, string(_arma.dano), 1.3 * _u, 1.3 * _u, 0);
draw_set_color(c_white);
draw_text_transformed(_x + 54 * _u, _y + 64 * _u, string(nivel), 1.5 * _u, 1.5 * _u, 0);
draw_set_color(_cian);
draw_text_transformed(_x + 930 * _u, _y + 64 * _u,
    string_format(_arma.ataques_segundo, 0, 2), 1.3 * _u, 1.3 * _u, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);
draw_set_alpha(1);

acto_dibujar();
cartas_dibujar_ui();
mejoras_dibujar_ui();
pausa_dibujar_ui();
muerte_dibujar_ui();
