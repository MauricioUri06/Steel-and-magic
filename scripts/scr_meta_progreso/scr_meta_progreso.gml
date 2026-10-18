/// @description API aislada para monedas y mejoras permanentes.
/// Los demas sistemas solo necesitan llamar a estas funciones publicas.

function meta_inicializar() {
    if (variable_global_exists("meta_progreso")) return;

    global.meta_progreso = {
        archivo: "steel_magic_meta.ini",
        monedas_banco: 0,
        monedas_run: 0,
        ultima_recompensa: 0,
        room_inicio: -1,
        mejoras: [
            { id:"vida_maxima", nombre:"VIDA MAXIMA", efecto:"+5 HP", max_nivel:10, nivel:0, costo_base:20, crecimiento:1.45, icon_x:96,  icon_y:576 },
            { id:"velocidad", nombre:"VELOCIDAD", efecto:"+2%", max_nivel:5, nivel:0, costo_base:35, crecimiento:1.70, icon_x:208, icon_y:576 },
            { id:"dano", nombre:"ATAQUE", efecto:"+8%", max_nivel:5, nivel:0, costo_base:45, crecimiento:1.75, icon_x:320, icon_y:576 },
            { id:"dash", nombre:"DASH", efecto:"DISTANCIA Y RECARGA", max_nivel:5, nivel:0, costo_base:60, crecimiento:1.80, icon_x:432, icon_y:576 },
            { id:"radio_monedas", nombre:"RADIO DE EXPERIENCIA", efecto:"+10%", max_nivel:3, nivel:0, costo_base:40, crecimiento:1.90, icon_x:544, icon_y:576 },
            { id:"bonus_monedas", nombre:"MONEDAS GANADAS", efecto:"+5%", max_nivel:5, nivel:0, costo_base:55, crecimiento:1.90, icon_x:656, icon_y:576 },
            { id:"reroll", nombre:"REROLL DE CARTAS", efecto:"+1 POR PARTIDA", max_nivel:3, nivel:0, costo_base:90, crecimiento:2.10, icon_x:768, icon_y:576 },
            { id:"cuarta_opcion", nombre:"CUARTA CARTA", efecto:"DESBLOQUEO ESPECIAL", max_nivel:1, nivel:0, costo_base:300, crecimiento:1.00, icon_x:880, icon_y:576 }
        ]
    };

    meta_cargar();
}

function meta_cargar() {
    if (!variable_global_exists("meta_progreso")) return;

    var _meta = global.meta_progreso;
    ini_open(_meta.archivo);
    _meta.monedas_banco = max(0, floor(ini_read_real("progreso", "monedas_banco", 0)));
    for (var _i = 0; _i < array_length(_meta.mejoras); _i++) {
        var _mejora = _meta.mejoras[_i];
        _mejora.nivel = clamp(floor(ini_read_real("mejoras", _mejora.id, 0)), 0, _mejora.max_nivel);
    }
    ini_close();
}

function meta_guardar() {
    meta_inicializar();
    var _meta = global.meta_progreso;
    ini_open(_meta.archivo);
    ini_write_real("progreso", "monedas_banco", _meta.monedas_banco);
    for (var _i = 0; _i < array_length(_meta.mejoras); _i++) {
        var _mejora = _meta.mejoras[_i];
        ini_write_real("mejoras", _mejora.id, _mejora.nivel);
    }
    ini_close();
}

function meta_costo_mejora(_indice) {
    meta_inicializar();
    var _mejora = global.meta_progreso.mejoras[_indice];
    return round(_mejora.costo_base * power(_mejora.crecimiento, _mejora.nivel));
}

function meta_comprar_mejora(_indice) {
    meta_inicializar();
    var _meta = global.meta_progreso;
    var _mejora = _meta.mejoras[_indice];
    if (_mejora.nivel >= _mejora.max_nivel) return false;

    var _costo = meta_costo_mejora(_indice);
    if (_meta.monedas_banco < _costo) return false;

    _meta.monedas_banco -= _costo;
    _mejora.nivel += 1;
    meta_guardar();
    return true;
}

function meta_sumar_monedas_run(_cantidad) {
    meta_inicializar();
    global.meta_progreso.monedas_run += max(0, floor(_cantidad));
    return global.meta_progreso.monedas_run;
}

function meta_asegurar_controlador() {
    var _controlador = instance_find(o_meta_manager, 0);
    if (_controlador == noone) {
        _controlador = instance_create_depth(0, 0, -100000, o_meta_manager);
    }
    return _controlador;
}

function meta_abrir_menu_muerte() {
    meta_inicializar();
    var _meta = global.meta_progreso;

    // Permite que el sistema de enemigos entregue directamente las monedas de la run.
    if (argument_count > 0) _meta.monedas_run = max(0, floor(argument[0]));

    var _bonus = 1 + 0.05 * _meta.mejoras[5].nivel;
    var _recompensa = floor(_meta.monedas_run * _bonus);
    _meta.monedas_banco += _recompensa;
    _meta.monedas_run = 0;
    _meta.ultima_recompensa = _recompensa;
    meta_guardar();

    var _controlador = meta_asegurar_controlador();
    with (_controlador) {
        menu_abierto = true;
        captura_lista = false;
        mundo_pausado = false;
        compra_realizada = false;
        fila_hover = -1;
        boton_salida_hover = false;
    }
}

function meta_menu_abierto() {
    var _controlador = instance_find(o_meta_manager, 0);
    return (_controlador != noone) && _controlador.menu_abierto;
}

function meta_configurar_room_inicio(_room) {
    meta_inicializar();
    global.meta_progreso.room_inicio = _room;
}

function meta_obtener_bonos() {
    meta_inicializar();
    var _m = global.meta_progreso.mejoras;
    return {
        vida_extra: 5 * _m[0].nivel,
        multiplicador_velocidad: 1 + 0.02 * _m[1].nivel,
        multiplicador_dano: 1 + 0.08 * _m[2].nivel,
        multiplicador_dash_distancia: 1 + 0.08 * _m[3].nivel,
        multiplicador_dash_recarga: max(0.60, 1 - 0.06 * _m[3].nivel),
        cargas_dash_extra: floor(_m[3].nivel / 2),
        multiplicador_radio_monedas: 1 + 0.10 * _m[4].nivel,
        multiplicador_monedas: 1 + 0.05 * _m[5].nivel,
        rerolls_extra: _m[6].nivel,
        cuarta_opcion: (_m[7].nivel > 0)
    };
}
