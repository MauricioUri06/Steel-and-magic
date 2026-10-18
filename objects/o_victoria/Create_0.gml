// Pantalla final: usa el arte y el regreso al menu existentes.
t = 0;
hover = false;
boton_frame = 0;
saliendo = false;
congelado = false;
if (!variable_instance_exists(id, "jugador")) jugador = instance_find(o_player, 0);
oleadas = 30;
if (!variable_instance_exists(id, "nivel_final")) {
    nivel_final = 1;
    if (instance_exists(jugador)) nivel_final = jugador.nivel;
}
if (instance_exists(o_spawner_oleadas)) oleadas = o_spawner_oleadas.total_oleadas;

fuente_titulo = font_add("Georgia", 54, true, false, 32, 255);
fuente_texto = font_add("Verdana", 14, false, false, 32, 255);
fuente_boton = font_add("Verdana", 14, true, false, 32, 255);

boton_rect = function() {
    var _u = min(display_get_gui_width() / 1280, display_get_gui_height() / 720);
    var _cx = display_get_gui_width() / 2;
    var _cy = display_get_gui_height() / 2 + 198 * _u;
    return [_cx - 192 * _u, _cy - 48 * _u, _cx + 192 * _u, _cy + 48 * _u];
};

instance_deactivate_all(true);
congelado = true;
