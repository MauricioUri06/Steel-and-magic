if (instance_number(o_meta_manager) > 1) {
    instance_destroy();
    exit;
}

persistent = true;
meta_inicializar();

menu_abierto = false;
captura_lista = false;
mundo_pausado = false;
fondo_surface = -1;
compra_realizada = false;
fila_hover = -1;
boton_salida_hover = false;

// Controles temporales para probar sin tocar o_player:
// N = sumar 100 monedas permanentes, M = simular muerte con 25 monedas de run.
debug_meta = true;

cerrar_menu = function() {
    if (mundo_pausado) {
        instance_activate_all();
        mundo_pausado = false;
    }

    menu_abierto = false;
    captura_lista = false;
    global.meta_progreso.monedas_run = 0;

    if (surface_exists(fondo_surface)) surface_free(fondo_surface);
    fondo_surface = -1;

    var _destino = global.meta_progreso.room_inicio;
    if (_destino != -1) room_goto(_destino);
    else room_restart();
};
