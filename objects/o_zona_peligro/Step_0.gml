timer -= 1;
switch (fase) {
    case "aviso":
        if (timer <= 0) {
            if (jugador_cerca(x, y, radio)) danar_jugador(dano);
            fase  = "impacto";
            timer = dur_impacto;
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
