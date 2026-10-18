fase += 6;

// salto inicial: se frena solo
x += hsp;
y += vsp;
hsp *= 0.88;
vsp *= 0.88;

if (!instance_exists(o_player) || o_player.muerto) exit;

var _d = point_distance(x, y, o_player.x, o_player.y);
if (_d < radio_iman || vel > 0) {
    // iman: una vez que empieza a volar ya no para
    vel = min(vel + acel, vel_max);
    var _a = point_direction(x, y, o_player.x, o_player.y);
    x += lengthdir_x(min(vel, _d), _a);
    y += lengthdir_y(min(vel, _d), _a);
}
if (_d <= JUGADOR_RADIO + radio) {
    o_player.ganar_xp(valor);
    instance_destroy();
}
