// ===== Proyectil enemigo =====
// Lo crea un enemigo a distancia:
//   instance_create_depth(x, y, depth - 1, o_proyectil_enemigo, { direccion: angulo, vel: 4, dano: 2, color: c_aqua });
// Si no se pasa alguno de esos valores, se usan los de aqui.
if (!variable_instance_exists(id, "direccion")) direccion = 0;
if (!variable_instance_exists(id, "vel"))       vel       = 4;
if (!variable_instance_exists(id, "dano"))      dano      = 2;
if (!variable_instance_exists(id, "color"))     color     = c_aqua;

radio     = 4;      // radio del impacto (px)
alcance   = 600;    // distancia maxima antes de desaparecer
recorrido = 0;

// _al_jugador = true si choco con el jugador; false si choco con una pared o llego al alcance.
impactar = function(_al_jugador) {
    if (_al_jugador) danar_jugador(dano);
    instance_destroy();
};
