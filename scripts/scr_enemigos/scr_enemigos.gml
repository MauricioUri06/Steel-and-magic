// Funciones compartidas por los enemigos y sus proyectiles.

// ===== Dificultad (subida un 50% el 18 oct) =====
// Tomar el mismo dano para limpiar a los mismos enemigos cuesta DIF_VIDA * DIF_DANO = 1.225 * 1.225 = ~1.5 veces mas.
// DIF_VIDA multiplica la vida de todos los enemigos y jefes al aparecer (o_spawner_oleadas.aparecer); DIF_DANO multiplica
// todo el dano que reciben el jugador (danar_jugador). Poner los dos en 1 deja el juego como antes.
#macro DIF_VIDA 1.225
#macro DIF_DANO 1.225

#macro JUGADOR_RADIO 12   // radio aproximado del cuerpo del jugador (px), para los golpes por distancia

/// Le hace dano al jugador si no esta en dash. Devuelve true si lo golpeo.
/// Pasa por o_player.recibir_dano, asi aplica la mejora de Armadura.
function danar_jugador(_dano) {
    if (!instance_exists(o_player) || o_player.inmune || o_player.muerto) return false;
    o_player.recibir_dano(_dano * DIF_DANO);
    return true;
}

/// true si el jugador esta dentro de un circulo de radio _r alrededor de (_x, _y).
function jugador_cerca(_x, _y, _r) {
    return instance_exists(o_player) && point_distance(_x, _y, o_player.x, o_player.y) <= _r + JUGADOR_RADIO;
}

/// Dispara una bala enemiga (o_proyectil_enemigo). _estilo: "orbe" | "llama".
function disparar_bala(_x, _y, _dir, _vel, _dano, _color, _radio = 4, _estilo = "orbe") {
    // sonido (sfx_play ya limita cuantas veces suena por segundo, asi que un anillo de balas suena una sola vez)
    if (_estilo == "llama") sfx_play(sfx_enemigo_llama, 0.8, 1, 0.1, 140);
    else sfx_play(sfx_enemigo_disparo, 0.8, 1, 0.08, 50);
    return instance_create_depth(_x, _y, -10, o_proyectil_enemigo,
                                 { direccion: _dir, vel: _vel, dano: _dano, color: _color, radio: _radio, estilo: _estilo });
}

/// Dispara _n balas repartidas en circulo, empezando en el angulo _offset.
function disparar_anillo(_x, _y, _n, _offset, _vel, _dano, _color, _radio = 4, _estilo = "orbe") {
    for (var _i = 0; _i < _n; _i++) disparar_bala(_x, _y, _offset + _i * 360 / _n, _vel, _dano, _color, _radio, _estilo);
}

/// Crea una zona de peligro en el suelo (ver o_zona_peligro).
/// _estilo: "sombra" (algo cae del cielo) | "fuego" (deja fuego que quema un rato)
function crear_zona(_x, _y, _estilo, _radio, _aviso, _dano, _persistir = 0) {
    return instance_create_depth(_x, _y, 50, o_zona_peligro,
                                 { estilo: _estilo, radio: _radio, aviso: _aviso, dano: _dano, persistir: _persistir });
}

/// Grietas en estrella en el suelo, solo estetica (ver o_grieta_suelo). Se dibujan debajo de todo.
function crear_grietas(_x, _y, _radio) {
    sfx_play(sfx_impacto_pesado, 0.9, 1, 0.06, 150);   // las grietas siempre acompanan a un golpe fuerte en el suelo
    return instance_create_depth(_x, _y, 60, o_grieta_suelo, { radio: _radio });
}

/// Crea una onda de choque: un anillo que se expande desde (_x, _y). Se esquiva con el dash.
function crear_onda(_x, _y, _radio_max, _vel, _dano, _color) {
    // con dano = onda de choque de un jefe; sin dano = el portal con el que aparece un enemigo (lo usa el spawner)
    if (_dano > 0) sfx_play(sfx_onda_choque, 0.9, 1, 0.05, 200);
    else sfx_play(sfx_portal, 0.6, 1, 0.1, 90);
    return instance_create_depth(_x, _y, 40, o_onda_choque, { radio_max: _radio_max, vel: _vel, dano: _dano, color: _color });
}
