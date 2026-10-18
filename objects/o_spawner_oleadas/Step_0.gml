if (victoria) exit;

// ===== Cambiando de acto: esperar, juntar los orbes, fundido a negro y pasar a la room nueva =====
if (sala_destino != -1) {
    trans_t += 1;
    if (trans_t == trans_espera) {
        // los orbes que quedaron en el suelo se suman solos (se perderian al cambiar de room)
        with (o_orbe_xp) {
            if (instance_exists(o_player)) o_player.ganar_xp(valor);
            instance_destroy();
        }
    }
    if (trans_t >= trans_espera + trans_fundido) {
        var _sala = sala_destino;
        sala_destino = -1;
        trans_t = 0;
        cola = [];
        timer = pausa_acto;
        if (instance_exists(o_player)) o_player.alpha_entrada = 1;   // la room nueva aparece desde negro (fundido del jugador)
        room_goto(_sala);
    }
    exit;
}

// ===== Se vencio al jefe: si lleva a otra room, empieza el cambio de acto =====
if (jefe_actual != noone && (!instance_exists(jefe_actual) || !jefe_actual.es_enemigo)) {
    jefe_actual = noone;
    if (jefe_sala != -1) {
        sfx_jingle(sfx_jefe);   // fanfarria de jefe vencido (el jefe final no: ese activa la victoria de mas abajo)
        sala_destino = jefe_sala;
        jefe_sala = -1;
        trans_t = 0;
        exit;
    }
}

// ===== Prueba: U mata a toda la oleada (vivos, jefe incluido, y los que faltaban salir) y lanza la siguiente =====
if (debug_matar && keyboard_check_pressed(ord("U"))) {
    cola = [];
    with (o_enemigo_base) if (es_enemigo) morir();   // muerte normal: sueltan xp y se cuentan las bajas
    // si murio un jefe que lleva a otro acto, no se lanza nada: el cambio de acto empieza en el proximo paso
    if (oleada < total_oleadas && jefe_sala == -1) lanzar_oleada();
}

var _vivos = 0;
with (o_enemigo_base) if (es_enemigo) _vivos += 1;

// ===== Ir sacando de a uno los enemigos de la oleada actual =====
if (array_length(cola) > 0) {
    timer_cola -= 1;
    if (timer_cola <= 0 && _vivos < max_vivos) {
        aparecer(cola[0]);
        array_delete(cola, 0, 1);
        timer_cola = pausa_spawn;
    }
}

var _jefe = jefe_vivo();

// ===== Victoria: se lanzo la ultima oleada (el jefe final) y ya no queda jefe =====
if (oleada >= total_oleadas) {
    if (array_length(cola) == 0 && !_jefe && !instance_exists(o_jefe_general)) {
        victoria = true;
        instance_create_depth(0, 0, -12000, o_victoria);   // la fanfarria sfx_victoria suena en o_victoria
    }
    exit;
}

// ===== Reloj de la proxima oleada (parado mientras haya un jefe vivo) =====
if (_jefe || (array_length(cola) > 0 && oleada mod 10 == 0)) exit;   // tambien mientras sale el jefe
// si ya no queda ningun enemigo vivo, la siguiente llega enseguida
if (oleada > 0 && array_length(cola) == 0 && _vivos == 0) timer = min(timer, tras_limpiar);
timer -= 1;
if (timer <= 0 || (debug && keyboard_check_pressed(ord("N")))) lanzar_oleada();
