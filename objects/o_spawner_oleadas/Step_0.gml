if (victoria) exit;

// ===== Prueba: U mata a toda la oleada (vivos, jefe incluido, y los que faltaban salir) y lanza la siguiente =====
if (debug_matar && keyboard_check_pressed(ord("U"))) {
    cola = [];
    with (o_enemigo_base) if (es_enemigo) morir();   // muerte normal: sueltan xp y se cuentan las bajas
    if (oleada < total_oleadas) lanzar_oleada();
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
    if (array_length(cola) == 0 && !_jefe) victoria = true;
    exit;
}

// ===== Reloj de la proxima oleada (parado mientras haya un jefe vivo) =====
if (_jefe || (array_length(cola) > 0 && oleada mod 10 == 0)) exit;   // tambien mientras sale el jefe
// si ya no queda ningun enemigo vivo, la siguiente llega enseguida
if (oleada > 0 && array_length(cola) == 0 && _vivos == 0) timer = min(timer, tras_limpiar);
timer -= 1;
if (timer <= 0 || (debug && keyboard_check_pressed(ord("N")))) lanzar_oleada();
