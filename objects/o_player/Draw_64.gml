// HUD de prueba: clase activa
draw_set_color(c_black);
draw_text(17, 17, "Clase: " + nombres_clase[clase_idx] + "   (rueda del mouse para cambiar)");
draw_set_color(c_white);
draw_text(16, 16, "Clase: " + nombres_clase[clase_idx] + "   (rueda del mouse para cambiar)");

// HUD: monedas y dash
var _dn = dash_niveles[dash_nivel];
var _txt = "Monedas: " + string(monedas) + "   Dash nivel " + string(dash_nivel + 1) + "/" + string(array_length(dash_niveles)) + "   (espacio)";
draw_set_color(c_black);
draw_text(17, 41, _txt);
draw_set_color(c_white);
draw_text(16, 40, _txt);
// una barra por carga de dash; la que se esta recargando se va llenando
for (var _i = 0; _i < _dn.cargas; _i++) {
    var _bx = 16 + _i * 28;
    draw_set_color(c_black);
    draw_rectangle(_bx, 68, _bx + 24, 78, false);
    draw_set_color(make_colour_rgb(90, 220, 255));
    if (_i < dash_cargas) {
        draw_rectangle(_bx + 1, 69, _bx + 23, 77, false);
    } else if (_i == dash_cargas) {
        var _p = 1 - clamp(dash_recarga / _dn.cd, 0, 1);
        draw_rectangle(_bx + 1, 69, _bx + 1 + 22 * _p, 77, false);
    }
}
draw_set_color(c_white);
