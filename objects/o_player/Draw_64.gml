// En pausa: foto del juego oscurecida (el HUD de abajo queda encima)
pausa_dibujar_fondo();

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
for (var _i = 0; _i < dash_cargas_max; _i++) {
    var _bx = 16 + _i * 28;
    draw_set_color(c_black);
    draw_rectangle(_bx, 68, _bx + 24, 78, false);
    draw_set_color(make_colour_rgb(90, 220, 255));
    if (_i < dash_cargas) {
        draw_rectangle(_bx + 1, 69, _bx + 23, 77, false);
    } else if (_i == dash_cargas) {
        var _p = 1 - clamp(dash_recarga / dash_cd, 0, 1);
        draw_rectangle(_bx + 1, 69, _bx + 1 + 22 * _p, 77, false);
    }
}
draw_set_color(c_white);

// HUD: vida (debajo de las barras del dash)
var _hbx = 16, _hby = 86, _hbw = 200, _hbh = 14;
draw_set_color(c_black);
draw_rectangle(_hbx - 1, _hby - 1, _hbx + _hbw + 1, _hby + _hbh + 1, false);
draw_set_color(make_colour_rgb(70, 20, 20));
draw_rectangle(_hbx, _hby, _hbx + _hbw, _hby + _hbh, false);
draw_set_color(make_colour_rgb(220, 50, 50));
draw_rectangle(_hbx, _hby, _hbx + _hbw * clamp(hp / hp_max, 0, 1), _hby + _hbh, false);
var _txt_hp = "HP " + string(ceil(max(0, hp))) + "/" + string(hp_max);
draw_set_color(c_black);
draw_text(_hbx + _hbw + 9, _hby, _txt_hp);
draw_set_color(c_white);
draw_text(_hbx + _hbw + 8, _hby - 1, _txt_hp);

// HUD: experiencia y nivel (barra abajo, al centro)
var _xgw = display_get_gui_width();
var _xgh = display_get_gui_height();
var _xw = _xgw * 0.5, _xh = 14;
var _xx = (_xgw - _xw) / 2, _xy = _xgh - 34;
draw_set_color(c_black);
draw_rectangle(_xx - 2, _xy - 2, _xx + _xw + 2, _xy + _xh + 2, false);
draw_set_color(make_colour_rgb(40, 34, 14));
draw_rectangle(_xx, _xy, _xx + _xw, _xy + _xh, false);
draw_set_color(make_colour_rgb(255, 214, 102));
var _max = (nivel >= nivel_max);
draw_rectangle(_xx, _xy, _xx + _xw * (_max ? 1 : clamp(xp / xp_sig, 0, 1)), _xy + _xh, false);
var _txt_xp = _max ? "Nivel " + string(nivel) + "   MAX" : "Nivel " + string(nivel) + "   " + string(xp) + " / " + string(xp_sig) + " XP";
draw_set_halign(fa_center);
draw_set_color(c_black);
draw_text(_xgw / 2 + 1, _xy - 21, _txt_xp);
draw_set_color(c_white);
draw_text(_xgw / 2, _xy - 22, _txt_xp);
draw_set_halign(fa_left);

// Cartel de acto ("ACTO I", "ACTO II", "ACTO III") en dorado, arriba
acto_dibujar();

// Pantalla de subida de nivel: las cartas al centro y el boton Confirmar
cartas_dibujar_ui();

// Menu de mejoras (tecla M)
mejoras_dibujar_ui();

// Menu de pausa y fundidos (siempre al final para quedar por encima de todo)
pausa_dibujar_ui();

// Pantalla de muerte: "HAS FALLADO" y botones (encima del fundido a negro)
muerte_dibujar_ui();
