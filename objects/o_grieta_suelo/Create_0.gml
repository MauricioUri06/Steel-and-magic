// ===== Grietas en el suelo (solo estetica, no hacen dano) =====
// Aparecen donde un jefe golpea el suelo y se desvanecen. Se crean con crear_grietas(x, y, radio) (scr_enemigos).
if (!variable_instance_exists(id, "radio")) radio = 70;

vida      = 120;    // pasos que duran (60 = 1 s)
vida_max  = vida;
color     = make_colour_rgb(25, 18, 14);
color_luz = make_colour_rgb(110, 95, 80);   // borde claro, como la grieta de la embestida

// Ramas en estrella: cada una es una lista de puntos {x, y} relativos al centro.
// El eje y se achata (0.6) para que parezca el suelo visto en perspectiva.
ramas = [];
var _n = irandom_range(7, 9);
for (var _i = 0; _i < _n; _i++) {
    var _ang = _i * 360 / _n + random_range(-15, 15);
    var _largo = radio * random_range(0.6, 1);
    var _rama = [{ x: 0, y: 0 }];
    for (var _d = 8; _d <= _largo; _d += 8) {
        var _a = _ang + random_range(-20, 20);
        array_push(_rama, { x: lengthdir_x(_d, _a), y: lengthdir_y(_d, _a) * 0.6 });
    }
    array_push(ramas, _rama);
    // ramita que sale de la mitad
    if (random(1) < 0.6 && array_length(_rama) > 3) {
        var _p = _rama[array_length(_rama) div 2];
        var _a2 = _ang + choose(-1, 1) * random_range(30, 55);
        var _l2 = _largo * 0.3;
        array_push(ramas, [{ x: _p.x, y: _p.y },
                           { x: _p.x + lengthdir_x(_l2 * 0.5, _a2), y: _p.y + lengthdir_y(_l2 * 0.5, _a2) * 0.6 },
                           { x: _p.x + lengthdir_x(_l2, _a2 + 10), y: _p.y + lengthdir_y(_l2, _a2 + 10) * 0.6 }]);
    }
}
