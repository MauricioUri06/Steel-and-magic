// Arriba al centro: oleada actual y cuanto falta para la proxima (o aviso de jefe / victoria).
var _txt;
if (sala_destino != -1)       _txt = "JEFE VENCIDO!";
else if (victoria)            _txt = "VICTORIA!  Sobreviviste las " + string(total_oleadas) + " oleadas";
else if (jefe_vivo())         _txt = "Oleada " + string(oleada) + "/" + string(total_oleadas) + "   JEFE!";
else if (oleada == 0)         _txt = "Preparate...  " + string(ceil(timer / game_get_speed(gamespeed_fps))) + " s";
else if (oleada >= total_oleadas) _txt = "Oleada " + string(oleada) + "/" + string(total_oleadas);
else {
    var _sig = ((oleada + 1) mod 10 == 0) ? "jefe en " : "proxima en ";
    _txt = "Oleada " + string(oleada) + "/" + string(total_oleadas) + "   " + _sig + string(ceil(timer / game_get_speed(gamespeed_fps))) + " s";
}

var _gx = display_get_gui_width() / 2;
draw_set_halign(fa_center);
draw_set_color(c_black);
draw_text(_gx + 1, 17, _txt);
draw_set_color((jefe_vivo() || victoria || sala_destino != -1) ? make_colour_rgb(255, 200, 80) : c_white);
draw_text(_gx, 16, _txt);
if (debug || debug_matar) {
    draw_set_color(c_white);
    draw_text(_gx, 36, (debug ? "N = siguiente oleada   " : "") + (debug_matar ? "U = matar oleada y pasar a la siguiente" : ""));
}
draw_set_halign(fa_left);

// fundido a negro al cambiar de acto (la room nueva aparece con el fundido de entrada del jugador)
if (sala_destino != -1 && trans_t > trans_espera) {
    draw_set_color(c_black);
    draw_set_alpha(clamp((trans_t - trans_espera) / trans_fundido, 0, 1));
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
