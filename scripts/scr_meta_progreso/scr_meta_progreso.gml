/// @description API aislada para monedas y mejoras permanentes.
/// Los demas sistemas solo necesitan llamar a estas funciones publicas.

function meta_inicializar() {
    if (variable_global_exists("meta_progreso")) return;

    global.meta_progreso = {
        archivo: "steel_magic_meta.ini",
        version_guardado: 1,
        monedas_banco: 0,
        monedas_run: 0,
        ultima_recompensa: 0,
        room_inicio: -1,
        record: {
            tiene_record: false,
            victorias: 0,
            mejor_tiempo: 0,
            enemigos: 0,
            monedas: 0,
            nivel: 0,
            clase: 0
        },
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

    // Los guardados creados durante las pruebas no tenian version y podian
    // conservar monedas o niveles entregados por los controles de depuracion.
    // Se reinician una sola vez; desde ahora el progreso valido se conserva.
    var _version = floor(ini_read_real("progreso", "version", 0));
    if (_version < _meta.version_guardado) {
        _meta.monedas_banco = 0;
        _meta.monedas_run = 0;
        _meta.ultima_recompensa = 0;
        for (var _r = 0; _r < array_length(_meta.mejoras); _r++) {
            var _mejora_prueba = _meta.mejoras[_r];
            _mejora_prueba.nivel = 0;
        }
        ini_close();
        meta_guardar();
        return;
    }

    _meta.monedas_banco = max(0, floor(ini_read_real("progreso", "monedas_banco", 0)));
    for (var _i = 0; _i < array_length(_meta.mejoras); _i++) {
        var _mejora = _meta.mejoras[_i];
        _mejora.nivel = clamp(floor(ini_read_real("mejoras", _mejora.id, 0)), 0, _mejora.max_nivel);
    }
    var _record = _meta.record;
    _record.tiene_record = (ini_read_real("records", "tiene_record", 0) > 0);
    _record.victorias = max(0, floor(ini_read_real("records", "victorias", 0)));
    _record.mejor_tiempo = max(0, ini_read_real("records", "mejor_tiempo", 0));
    _record.enemigos = max(0, floor(ini_read_real("records", "enemigos", 0)));
    _record.monedas = max(0, floor(ini_read_real("records", "monedas", 0)));
    _record.nivel = max(0, floor(ini_read_real("records", "nivel", 0)));
    _record.clase = clamp(floor(ini_read_real("records", "clase", 0)), 0, 2);
    ini_close();
}

function meta_guardar() {
    meta_inicializar();
    var _meta = global.meta_progreso;
    ini_open(_meta.archivo);
    ini_write_real("progreso", "version", _meta.version_guardado);
    ini_write_real("progreso", "monedas_banco", _meta.monedas_banco);
    for (var _i = 0; _i < array_length(_meta.mejoras); _i++) {
        var _mejora = _meta.mejoras[_i];
        ini_write_real("mejoras", _mejora.id, _mejora.nivel);
    }
    var _record = _meta.record;
    ini_write_real("records", "tiene_record", _record.tiene_record ? 1 : 0);
    ini_write_real("records", "victorias", _record.victorias);
    ini_write_real("records", "mejor_tiempo", _record.mejor_tiempo);
    ini_write_real("records", "enemigos", _record.enemigos);
    ini_write_real("records", "monedas", _record.monedas);
    ini_write_real("records", "nivel", _record.nivel);
    ini_write_real("records", "clase", _record.clase);
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

/// Transfiere al banco las monedas obtenidas en la partida y guarda el progreso.
/// Se llama una sola vez cuando muere el jugador.
function meta_cobrar_monedas_run(_cantidad) {
    meta_inicializar();
    var _meta = global.meta_progreso;
    var _monedas = max(0, floor(_cantidad));
    var _bonus = 1 + 0.05 * _meta.mejoras[5].nivel;
    var _recompensa = floor(_monedas * _bonus);

    _meta.monedas_banco += _recompensa;
    _meta.monedas_run = 0;
    _meta.ultima_recompensa = _recompensa;
    meta_guardar();
    return _recompensa;
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

    meta_cobrar_monedas_run(_meta.monedas_run);

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

/// Convierte segundos a un reloj compacto HH:MM:SS o MM:SS.
function meta_formatear_tiempo(_segundos) {
    var _total = max(0, floor(_segundos));
    var _horas = _total div 3600;
    var _minutos = (_total div 60) mod 60;
    var _seg = _total mod 60;
    var _ss = ((_seg < 10) ? "0" : "") + string(_seg);
    if (_horas > 0) {
        var _mm = ((_minutos < 10) ? "0" : "") + string(_minutos);
        return string(_horas) + ":" + _mm + ":" + _ss;
    }
    return string(_minutos) + ":" + _ss;
}

function meta_nombre_clase(_clase) {
    var _nombres = ["CABALLERO", "MAGO", "SOLDADO"];
    return _nombres[clamp(floor(_clase), 0, 2)];
}

function meta_sprite_clase(_clase) {
    switch (clamp(floor(_clase), 0, 2)) {
        case 1: return ico_record_weapon_mage;
        case 2: return ico_record_weapon_soldier;
        default: return ico_record_weapon_knight;
    }
}

/// Registra la victoria inmediatamente. El record personal es la partida
/// completada en menos tiempo y conserva el resto de sus estadisticas.
function meta_registrar_victoria(_tiempo, _enemigos, _monedas, _nivel, _clase) {
    meta_inicializar();
    var _record = global.meta_progreso.record;
    var _nuevo = !_record.tiene_record || _tiempo < _record.mejor_tiempo;

    _record.victorias += 1;
    if (_nuevo) {
        _record.tiene_record = true;
        _record.mejor_tiempo = max(0, _tiempo);
        _record.enemigos = max(0, floor(_enemigos));
        _record.monedas = max(0, floor(_monedas));
        _record.nivel = max(1, floor(_nivel));
        _record.clase = clamp(floor(_clase), 0, 2);
    }

    meta_guardar();
    return _nuevo;
}
