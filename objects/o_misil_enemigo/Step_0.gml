if (explotando > 0) {
    explotando -= 1;
    if (explotando <= 0) instance_destroy();
    exit;
}

// teledirigido: gira un poco hacia el jugador cada paso
if (instance_exists(o_player)) {
    var _d = angle_difference(point_direction(x, y, o_player.x, o_player.y), direccion);
    direccion += clamp(_d, -giro, giro);
}

event_inherited();
