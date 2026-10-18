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
