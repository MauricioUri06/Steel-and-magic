gpu_set_texfilter(false);   // pixel art nitido, aunque el juego arranque directo en un acto (el menu es quien lo apaga normalmente)
explosiones_dibujar();      // anillos de las balas explosivas
// Espejismos del dash (detras del jugador): se van desvaneciendo
for (var _i = 0; _i < array_length(espejismos); _i++) {
    var _e = espejismos[_i];
    var _t = _e.vida / espejismo_vida;   // 1 -> 0
    draw_sprite_ext(_e.spr, _e.img, _e.x, _e.y, _e.esc, _e.esc, 0, espejismo_color, espejismo_alpha * _t);
}

if (muerto) exit;   // muerto: el jugador, la bola del mago y la flecha ya no se dibujan (la animacion de muerte se dibuja en el Draw GUI)

// Dibuja el sprite escalado y anclado a los pies (los pies estan en y_local = 30, origen en 16)
var _s = escala[$ clase][$ anim][$ facing] * escala_jugador;
draw_sprite_ext(sprite_index, image_index, x, y + 14 * (1 - _s), _s, _s, 0, c_white, 1);

// Bola de fuego que sostiene el mago mientras carga: crece con el tiempo y apunta al cursor
if (state == "charge") {
    var _cd = point_direction(x, y, mouse_x, mouse_y);
    draw_sprite_ext(s_proyectil_mago, (current_time div 100) mod 4, x + lengthdir_x(carga_dist, _cd), y + lengthdir_y(carga_dist, _cd), carga_esc, carga_esc, _cd, c_white, 1);
}

// Flecha orbitando al jugador, apuntando al cursor (el sprite apunta hacia arriba = 90 grados, de ahi el -90)
var _ang = point_direction(x, y, mouse_x, mouse_y);
var _fx = x + lengthdir_x(flecha_dist, _ang);
var _fy = y + lengthdir_y(flecha_dist, _ang);
draw_sprite_ext(s_Flecha, 0, _fx, _fy, flecha_escala, flecha_escala, _ang - 90, c_white, 1);
