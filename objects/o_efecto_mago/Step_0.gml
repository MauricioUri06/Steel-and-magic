if (fase == "activo") {
    // ===== Ardiendo: aparece (cuadros 0-3) y despues parpadea entre los cuadros 2 y 3 =====
    if (image_index < frame_ultimo_activo) {
        image_index = min(image_index + anim_vel, frame_ultimo_activo);
    } else {
        image_index += anim_vel_bucle;
        if (image_index >= frame_ultimo_activo + 1) image_index -= (frame_ultimo_activo + 1 - frame_bucle_ini);
    }

    // ===== Dano a los enemigos que estan encima (un pulso cada "pulso_seg") =====
    pulso -= 1;
    if (pulso <= 0) {
        pulso = round(pulso_seg * game_get_speed(gamespeed_fps));
        var _lista = ds_list_create();
        var _nhit = instance_place_list(x, y, all, _lista, false);
        for (var _k = 0; _k < _nhit; _k++) {
            var _en = _lista[| _k];
            if (!variable_instance_exists(_en, "es_enemigo") || !_en.es_enemigo) continue;
            if (variable_instance_exists(_en, "recibir_dano")) _en.recibir_dano(dano, false);   // false = sin sonido de golpe en cada pulso del fuego
            else if (variable_instance_exists(_en, "hp")) _en.hp -= dano;
            // carta Quemadura ralentizante: el fuego tambien frena a los enemigos que lo pisan (se renueva en cada pulso)
            if (instance_exists(o_player) && o_player.mejoras.quemadura_lenta > 0 && variable_instance_exists(_en, "ralentizar")) _en.ralentizar(o_player.lento_factor, 75);
        }
        ds_list_destroy(_lista);
    }

    // ===== Pasaron los 3 segundos: ahora si empieza la animacion de destruccion =====
    vida -= 1;
    if (vida <= 0) {
        fase = "muriendo";
        image_index = frame_ultimo_activo + 1;
    }
} else {
    // ===== Muriendo: cuadros 4-5, ya sin hacer dano; al terminar desaparece =====
    image_index += anim_vel;
    if (image_index >= image_number) instance_destroy();
}
