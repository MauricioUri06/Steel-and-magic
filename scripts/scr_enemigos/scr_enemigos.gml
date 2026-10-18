// Funciones compartidas por los enemigos y sus proyectiles.

#macro JUGADOR_RADIO 12   // radio aproximado del cuerpo del jugador (px), para los golpes por distancia

/// Le hace dano al jugador si no esta en dash. Devuelve true si lo golpeo.
function danar_jugador(_dano) {
    if (!instance_exists(o_player) || o_player.inmune) return false;
    o_player.hp -= _dano;
    return true;
}

/// true si el jugador esta dentro de un circulo de radio _r alrededor de (_x, _y).
function jugador_cerca(_x, _y, _r) {
    return instance_exists(o_player) && point_distance(_x, _y, o_player.x, o_player.y) <= _r + JUGADOR_RADIO;
}
