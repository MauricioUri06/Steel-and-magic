timer -= 1;
switch (fase) {
    case "aviso":
        if (timer <= 0) {
            if (jugador_cerca(x, y, radio)) danar_jugador(dano);
            fase  = "impacto";
            timer = dur_impacto;
            if (estilo == "fuego") sfx_play(sfx_enemigo_llama, 1, 0.8, 0.08, 80);   // llamarada
            else sfx_play(sfx_explosion_chica, 1, 0.9, 0.08, 80);                    // algo cae del cielo y explota
        }
        break;

    case "impacto":
        if (timer <= 0) {
            if (persistir > 0) { fase = "ardiendo"; timer = persistir; tick = 0; }
            else instance_destroy();
        }
        break;

    case "ardiendo":
        tick -= 1;
        if (tick <= 0 && jugador_cerca(x, y, radio * 0.8)) {
            if (danar_jugador(dano_tick)) tick = cada_tick;
        }
        if (timer <= 0) instance_destroy();
        break;
}
