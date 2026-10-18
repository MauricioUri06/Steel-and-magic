// ===== Oleadas =====
// 30 oleadas, una cada 10 segundos (o 2 s despues de matar a todos), cada una mas dificil. Las oleadas 10, 20 y 30 son un jefe.
// Mientras haya un jefe vivo el reloj se detiene (no aparecen mas oleadas). Se pone una instancia en el room.
//
// Dificultad: cada oleada tiene "puntos" para gastar en enemigos (cada tipo cuesta segun lo fuerte que es)
// y los tipos fuertes se desbloquean mas tarde. La vida de los enemigos normales sube un poco por oleada.

total_oleadas  = 30;
oleada         = 0;                                  // ultima oleada lanzada (0 = ninguna)
intervalo      = 10 * game_get_speed(gamespeed_fps); // pasos entre oleadas
timer          = 3 * game_get_speed(gamespeed_fps);  // la primera llega a los 3 s
tras_limpiar   = 2 * game_get_speed(gamespeed_fps);  // si mueren todos, la siguiente llega a los 2 s
pausa_spawn    = 8;                                  // pasos entre cada enemigo de una oleada (aparecen de a uno)
cola           = [];                                 // enemigos que faltan aparecer de la oleada actual
timer_cola     = 0;
max_vivos      = 60;                                 // tope de enemigos a la vez (rendimiento): la cola espera
victoria       = false;
debug          = false;  // true: la tecla N lanza la siguiente oleada ya (para probar).
debug_matar    = true;   // true: la tecla U mata a toda la oleada y lanza la siguiente (para probar). Ponlo en false para la version final.

// tipos de enemigos: coste = puntos que gasta, desde = oleada desde la que puede aparecer
tipos = [
    { obj: o_enemigo_goblin,         coste: 1, desde: 1  },
    { obj: o_enemigo_diablillo,      coste: 1, desde: 2  },
    { obj: o_enemigo_elfo,           coste: 2, desde: 4  },
    { obj: o_enemigo_demonio_escudo, coste: 3, desde: 6  },
    { obj: o_enemigo_orco_exo,       coste: 4, desde: 12 },
    { obj: o_enemigo_elite_misiles,  coste: 4, desde: 14 }
];
jefes = [o_jefe_orco_mecha, o_jefe_dragon, o_jefe_general];   // oleadas 10, 20 y 30

puntos_de = function(_n) { return round(4 + _n * 1.6); };     // oleada 1: 6 puntos ... oleada 29: 50
vida_mult = function(_n) { return 1 + (_n - 1) * 0.02; };     // oleada 29: +56% de vida

// true si hay un jefe vivo (uno muriendo ya no cuenta)
jefe_vivo = function() {
    var _vivo = false;
    with (o_jefe_base) if (es_enemigo) _vivo = true;
    return _vivo;
};

// Arma la lista de enemigos de la oleada _n (o el jefe si es multiplo de 10).
armar_oleada = function(_n) {
    if (_n mod 10 == 0) return [jefes[_n div 10 - 1]];
    var _lista = [];
    var _puntos = puntos_de(_n);
    while (_puntos > 0) {
        var _opciones = [];
        for (var _i = 0; _i < array_length(tipos); _i++) {
            if (tipos[_i].desde <= _n && tipos[_i].coste <= _puntos) array_push(_opciones, tipos[_i]);
        }
        if (array_length(_opciones) == 0) break;
        var _t = _opciones[irandom(array_length(_opciones) - 1)];
        array_push(_lista, _t.obj);
        _puntos -= _t.coste;
    }
    return _lista;
};

lanzar_oleada = function() {
    oleada += 1;
    cola = armar_oleada(oleada);
    timer_cola = 0;
    timer = intervalo;
};

// Lugar para aparecer: lejos del jugador, dentro del room y fuera de las paredes.
lugar_libre = function() {
    var _cx = room_width / 2, _cy = room_height / 2;
    if (instance_exists(o_player)) { _cx = o_player.x; _cy = o_player.y; }
    var _x = _cx, _y = _cy;
    repeat (20) {
        var _a = random(360), _d = irandom_range(260, 380);
        _x = clamp(_cx + lengthdir_x(_d, _a), 32, room_width - 32);
        _y = clamp(_cy + lengthdir_y(_d, _a), 32, room_height - 32);
        if (!collision_circle(_x, _y, 20, o_solid, false, true)
            && (!instance_exists(o_player) || point_distance(_x, _y, o_player.x, o_player.y) > 150)) break;
    }
    return [_x, _y];
};

aparecer = function(_obj) {
    var _p = lugar_libre();
    var _e = instance_create_depth(_p[0], _p[1], 0, _obj);
    if (!object_is_ancestor(_obj, o_jefe_base)) {
        _e.hp_max = round(_e.hp_max * vida_mult(oleada));
        _e.hp = _e.hp_max;
    }
    crear_onda(_p[0], _p[1], 40, 2, 0, make_colour_rgb(170, 60, 220));   // portal (sin dano)
};
