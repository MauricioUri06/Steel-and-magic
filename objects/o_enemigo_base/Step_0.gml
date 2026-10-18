// ===== Muerte: cae, queda en el suelo y se desvanece =====
if (!es_enemigo) {
    timer -= 1;
    if (estado == "cayendo" && timer <= 0) {
        estado = "muerto";
        timer  = dur_muerto;
    } else if (estado == "muerto" && timer <= 0) {
        instance_destroy();
    }
    exit;
}

// Algunos ataques restan hp directamente, asi que se revisa aqui en vez de solo en recibir_dano.
if (hp <= 0) {
    morir();
    exit;
}

if (flash > 0) flash -= 1;

// Estados de las cartas del jugador: lentitud, quemadura y empuje (ver o_enemigo_base/Create_0)
if (lento_t > 0) {
    lento_t -= 1;
    if (lento_t <= 0) lento_f = 1;
}
if (quemadura_t > 0) {
    quemadura_t -= 1;
    quemadura_tick -= 1;
    if (quemadura_tick <= 0) {
        quemadura_tick = 30;
        recibir_dano(quemadura_dano);   // pasa por recibir_dano: escudos y jefes aplican lo suyo
    }
}
if (emp_f > 0.3) {
    mover_crudo(emp_dir, emp_f);
    emp_f *= 0.78;
} else {
    emp_f = 0;
}

// la mascara mide 24 px (radio 12): se escala para que coincida con el tamano dibujado
image_xscale = radio / 12;
image_yscale = image_xscale;

comportamiento();

// voltear el sprite solo cuando mira claramente a un lado (evita que tiemble al ir en vertical)
var _hx = lengthdir_x(1, dir_mira);
if (abs(_hx) > 0.2) lado = sign(_hx);

// Separacion: si se encima con otro enemigo, se empuja un poco para que no se apilen.
if (!pesado) {
    var _otro = instance_place(x, y, o_enemigo_base);
    if (_otro != noone) mover(point_direction(_otro.x, _otro.y, x, y), 0.6);
}
