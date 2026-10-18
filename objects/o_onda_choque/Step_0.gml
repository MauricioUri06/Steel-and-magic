radio += vel;

if (!golpeo && instance_exists(o_player)
    && abs(point_distance(x, y, o_player.x, o_player.y) - radio) <= grosor / 2 + JUGADOR_RADIO) {
    golpeo = danar_jugador(dano);
}

if (radio >= radio_max) instance_destroy();
