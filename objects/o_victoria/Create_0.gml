// Pantalla final: usa el arte y el regreso al menu existentes.
meta_inicializar();
sfx_jingle(sfx_victoria, SFX_VOL, false);   // gran fanfarria; al terminar no vuelve la musica del acto 3
t = 0;
fase_t = 0;
fase = "victoria";
transicion = 0;
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

// Congela una copia de las estadisticas antes de desactivar el mundo.
if (!variable_instance_exists(id, "tiempo_final")) tiempo_final = 0;
if (!variable_instance_exists(id, "enemigos_final")) enemigos_final = 0;
if (!variable_instance_exists(id, "monedas_final")) monedas_final = 0;
if (!variable_instance_exists(id, "clase_final")) clase_final = 0;
if (!variable_instance_exists(id, "nuevo_record")) nuevo_record = false;
if (!variable_instance_exists(id, "record_ya_guardado")) record_ya_guardado = false;

// Ruta de respaldo para cualquier futura victoria creada sin la cinematica del jefe.
if (!record_ya_guardado && instance_exists(jugador)) {
    if (variable_instance_exists(jugador, "tiempo_run")) tiempo_final = jugador.tiempo_run;
    if (variable_instance_exists(jugador, "enemigos_derrotados")) enemigos_final = jugador.enemigos_derrotados;
    if (variable_instance_exists(jugador, "monedas")) monedas_final = jugador.monedas;
    if (variable_instance_exists(jugador, "uso_clases")) {
        var _mayor_uso = jugador.uso_clases[0];
        for (var _ci = 1; _ci < 3; _ci++) {
            if (jugador.uso_clases[_ci] > _mayor_uso) {
                _mayor_uso = jugador.uso_clases[_ci];
                clase_final = _ci;
            }
        }
    } else if (variable_instance_exists(jugador, "clase_idx")) {
        clase_final = jugador.clase_idx;
    }

    if (!jugador.victoria_registrada) {
        nuevo_record = meta_registrar_victoria(tiempo_final, enemigos_final, monedas_final, nivel_final, clase_final);
        jugador.victoria_registrada = true;
    }
}
record_guardado = global.meta_progreso.record;

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
