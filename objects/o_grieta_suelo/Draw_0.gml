// se desvanece en los ultimos 40 pasos
var _alpha = 0.85 * min(1, vida / 40);

// crater oscuro en el centro
draw_set_alpha(_alpha * 0.5);
draw_set_color(color);
draw_ellipse(x - radio * 0.25, y - radio * 0.15, x + radio * 0.25, y + radio * 0.15, false);

draw_set_alpha(_alpha);
for (var _i = 0; _i < array_length(ramas); _i++) {
    var _r = ramas[_i];
    var _n = array_length(_r);
    for (var _j = 1; _j < _n; _j++) {
        var _a = _r[_j - 1], _b = _r[_j];
        var _w = lerp(3, 1, _j / _n);   // mas ancha cerca del golpe
        draw_set_color(color_luz);
        draw_line_width(x + _a.x, y + _a.y + 1, x + _b.x, y + _b.y + 1, 1);
        draw_set_color(color);
        draw_line_width(x + _a.x, y + _a.y, x + _b.x, y + _b.y, _w);
    }
}
draw_set_alpha(1);
draw_set_color(c_white);
