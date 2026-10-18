if (es_enemigo) {
    event_inherited();
    exit;
}

// Draw GUI captura primero el escenario sin el cuerpo del jefe.
if (!muerte_final_congelado) exit;
muerte_final_t = min(muerte_final_fin, muerte_final_t + 1 / game_get_speed(gamespeed_fps));
if (muerte_final_t >= muerte_final_fin) {
    // La victoria toma el control del mundo congelado, sin reactivar el combate entre pantallas.
    muerte_final_congelado = false;
    instance_create_depth(0, 0, -12000, o_victoria, {
        jugador: muerte_final_jugador,
        nivel_final: muerte_final_nivel
    });
    instance_destroy();
}
