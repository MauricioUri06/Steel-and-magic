x += lengthdir_x(vel, direccion);
y += lengthdir_y(vel, direccion);
recorrido += vel;

// el dash del jugador lo atraviesa (inmune)
if (jugador_cerca(x, y, radio) && !o_player.inmune) {
    impactar(true);
    exit;
}
if (position_meeting(x, y, o_solid) || recorrido >= alcance
    || x < 0 || y < 0 || x > room_width || y > room_height) {
    impactar(false);
}
