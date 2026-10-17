// ===== Cambiar de clase con la rueda del mouse =====
var _wheel = mouse_wheel_up() - mouse_wheel_down();
if (_wheel != 0) {
    var _n = array_length(clases);
    clase_idx = (clase_idx + _wheel + _n) mod _n;
    clase = clases[clase_idx];
    if (state == "charge") { state = "idle"; carga = 0; }   // cambiar de clase cancela la carga del mago
}

// ===== Entrada de movimiento (WASD + flechas) =====
var _h = (keyboard_check(ord("D")) || keyboard_check(vk_right)) - (keyboard_check(ord("A")) || keyboard_check(vk_left));
var _v = (keyboard_check(ord("S")) || keyboard_check(vk_down))  - (keyboard_check(ord("W")) || keyboard_check(vk_up));
var _len = point_distance(0, 0, _h, _v);

// ===== Espejismos: envejecer y borrar los que ya se desvanecieron =====
for (var _i = array_length(espejismos) - 1; _i >= 0; _i--) {
    espejismos[_i].vida -= 1;
    if (espejismos[_i].vida <= 0) array_delete(espejismos, _i, 1);
}

// ===== Nivel del dash segun las monedas =====
if (debug_monedas && keyboard_check_pressed(ord("C"))) monedas += 5;   // solo para probar
var _nv = 0;
for (var _i = 0; _i < array_length(dash_niveles); _i++) {
    if (monedas >= dash_niveles[_i].monedas) _nv = _i;
}
if (_nv != dash_nivel) {
    // al subir de nivel te regala las cargas nuevas
    dash_cargas += max(0, dash_niveles[_nv].cargas - dash_niveles[dash_nivel].cargas);
    dash_nivel = _nv;
}
var _dn = dash_niveles[dash_nivel];
dash_cargas = min(dash_cargas, _dn.cargas);

// recuperar cargas de dash con el tiempo
if (dash_cargas < _dn.cargas) {
    dash_recarga -= 1;
    if (dash_recarga <= 0) {
        dash_cargas += 1;
        dash_recarga = _dn.cd;
    }
}

// ===== Terminar el ataque actual cuando se acaba su animacion =====
if (state == "attack") {
    atk_timer -= 1;
    if (atk_timer <= 0) state = (_len > 0) ? "walk" : "idle";
}

// ===== Dash: barra espaciadora =====
// Va hacia donde te mueves; si estas quieto, hacia el cursor. Cancela el ataque en curso.
if (keyboard_check_pressed(vk_space) && state != "dash" && dash_cargas > 0) {
    if (dash_cargas >= _dn.cargas) dash_recarga = _dn.cd;   // empieza a recargar
    dash_cargas -= 1;
    dash_dir   = (_len > 0) ? point_direction(0, 0, _h, _v) : point_direction(x, y, mouse_x, mouse_y);
    dash_vel   = _dn.dist / dash_dur;
    dash_timer = dash_dur;
    state      = "dash";
    atk_timer  = 0;
    proy_pendiente = false;
    carga      = 0;
    inmune     = true;
    dash_golpeados = {};
    // mira hacia donde sale disparado
    if (dash_dir >= 315 || dash_dir < 45) facing = "derecha";
    else if (dash_dir < 135)              facing = "arriba";
    else if (dash_dir < 225)              facing = "izquierda";
    else                                  facing = "abajo";
}

// ===== Ataque: manten el clic izquierdo (mira hacia el mouse) =====
// Caballero y soldado: si sigues apretando al terminar la animacion, empieza otro ataque de inmediato.
// Mago: el clic empieza a cargar la bola de fuego (ver el bloque de abajo).
if (state != "attack" && state != "dash" && state != "charge" && mouse_check_button(mb_left)) {
    var _ang = point_direction(x, y, mouse_x, mouse_y);
    if (_ang >= 315 || _ang < 45)  facing = "derecha";
    else if (_ang < 135)           facing = "arriba";
    else if (_ang < 225)           facing = "izquierda";
    else                           facing = "abajo";
    if (clase == "mago") {
        state = "charge";
        carga = 0;
        image_index = 0;
        proy_pendiente = false;
    } else {
        state = "attack";
        image_index = 0;
        proy_pendiente = variable_struct_exists(proy, clase);   // si la clase tiene proyectil, lo lanza durante este ataque
        proy_clase = clase;
        // duracion del ataque en pasos (a partir de la velocidad del sprite)
        var _as = spr[$ clase].ataque[$ facing];
        var _spd = sprite_get_speed(_as);
        if (sprite_get_speed_type(_as) == spritespeed_framespersecond) _spd = _spd / game_get_speed(gamespeed_fps);
        atk_timer = ceil(sprite_get_number(_as) / max(_spd, 0.01));
        // cadencia fija (soldado): el ataque dura justo 1/cadencia segundos; la animacion se acelera para encajar
        atk_img_speed = 1;
        if (variable_struct_exists(proy, clase) && proy[$ clase].cadencia > 0) {
            var _natural = atk_timer;
            atk_timer = max(1, round(game_get_speed(gamespeed_fps) / proy[$ clase].cadencia));
            atk_img_speed = _natural / atk_timer;
        }
    }
}

// ===== Mago: mientras mantienes el clic carga la bola de fuego (mas grande y mas efectos); al soltar se lanza =====
if (state == "charge") {
    var _fps = game_get_speed(gamespeed_fps);
    var _ca = point_direction(x, y, mouse_x, mouse_y);   // sigue al cursor mientras carga
    if (_ca >= 315 || _ca < 45)  facing = "derecha";
    else if (_ca < 135)          facing = "arriba";
    else if (_ca < 225)          facing = "izquierda";
    else                         facing = "abajo";
    var _soltado = !mouse_check_button(mb_left);
    if (!_soltado) carga = min(carga + 1, mago_cfg.carga_max * _fps);
    carga_t    = carga / (mago_cfg.carga_max * _fps);
    carga_esc  = lerp(mago_cfg.escala_min, mago_cfg.escala_max, carga_t) * escala_jugador;
    carga_dist = mago_cfg.dist + 12 * carga_esc;
    if (_soltado) {
        // lanzar la bola: tamano, dano y cantidad de efectos segun lo cargado
        instance_create_depth(x + lengthdir_x(carga_dist, _ca), y + lengthdir_y(carga_dist, _ca), depth - 1, mago_cfg.obj, {
            direccion: _ca,
            dano: round(lerp(mago_cfg.dano_min, mago_cfg.dano_max, carga_t)),
            escala: carga_esc,
            efectos: round(lerp(mago_cfg.efectos_min, mago_cfg.efectos_max, carga_t)),
            radio: mago_cfg.radio_por_escala * carga_esc,
            escala_efecto: lerp(mago_cfg.escala_efecto_min, mago_cfg.escala_efecto_max, carga_t) * escala_jugador,
            dano_efecto: mago_cfg.dano_efecto
        });
        // la animacion de ataque sigue desde el cuadro del hechizo hasta el final
        var _as = spr[$ clase].ataque[$ facing];
        var _spd = sprite_get_speed(_as);
        if (sprite_get_speed_type(_as) == spritespeed_framespersecond) _spd = _spd / game_get_speed(gamespeed_fps);
        state = "attack";
        image_index = mago_cfg.frame_lanzar;
        atk_img_speed = 1;
        atk_timer = max(1, ceil((sprite_get_number(_as) - mago_cfg.frame_lanzar) / max(_spd, 0.01)));
        carga = 0;
    }
}

// ===== Direccion a la que mira (4 direcciones) segun el movimiento =====
if (state != "attack" && state != "dash" && state != "charge" && _len > 0) {
    if (_h != 0 && _v == 0) {
        facing = (_h < 0) ? "izquierda" : "derecha";
    } else if (_v != 0 && _h == 0) {
        facing = (_v < 0) ? "arriba" : "abajo";
    } else {
        // diagonal: conserva la direccion actual si sigue siendo valida; si no, prioriza horizontal
        var _okh = (facing == "izquierda" && _h < 0) || (facing == "derecha" && _h > 0);
        var _okv = (facing == "arriba" && _v < 0)     || (facing == "abajo" && _v > 0);
        if (!_okh && !_okv) facing = (_h < 0) ? "izquierda" : "derecha";
    }
}

// ===== Mover (velocidad normalizada en diagonal; el dash manda mientras dura) =====
var _gx = x, _gy = y, _dejar_espejismo = false;
if (state == "dash") {
    hsp = lengthdir_x(dash_vel, dash_dir);
    vsp = lengthdir_y(dash_vel, dash_dir);
    _dejar_espejismo = true;
    dash_timer -= 1;
    if (dash_timer <= 0) {
        inmune = false;
        state = (_len > 0) ? "walk" : "idle";
    }
} else if (_len > 0) {
    hsp = (_h / _len) * move_speed;
    vsp = (_v / _len) * move_speed;
} else {
    hsp = 0;
    vsp = 0;
}
// TODO: aqui van las colisiones con paredes/props cuando existan
x = clamp(x + hsp, 16, room_width - 16);
y = clamp(y + vsp, 16, room_height - 16);

// ===== Dash: dano a los enemigos que atraviesas =====
// Un enemigo es cualquier instancia con  es_enemigo = true  (y  hp).  Si tiene un metodo  recibir_dano(_cantidad)  lo llama;
// si no, le resta la cantidad a su  hp.  Cada enemigo recibe dano una sola vez por dash.
if (_dejar_espejismo) {
    var _lista = ds_list_create();
    var _nhit = collision_circle_list(x, y, dash_radio, all, false, true, _lista, false);
    for (var _k = 0; _k < _nhit; _k++) {
        var _en = _lista[| _k];
        if (!variable_instance_exists(_en, "es_enemigo") || !_en.es_enemigo) continue;
        if (variable_struct_exists(dash_golpeados, string(_en))) continue;
        dash_golpeados[$ string(_en)] = true;
        if (variable_instance_exists(_en, "recibir_dano")) _en.recibir_dano(_dn.dano);
        else if (variable_instance_exists(_en, "hp")) _en.hp -= _dn.dano;
    }
    ds_list_destroy(_lista);
}

// ===== Estado =====
if (state != "attack" && state != "dash" && state != "charge") state = (_len > 0) ? "walk" : "idle";

// ===== Elegir sprite: clase + animacion + direccion =====
var _anim = (state == "attack" || state == "charge") ? "ataque" : ((state == "walk" || state == "dash") ? "caminata" : "reposo");
if (_anim == "reposo" && reposo_usa_caminata) _anim = "caminata";   // quieto = primer cuadro de caminata
var _anim_prev = anim;
anim = _anim;
var _new_spr = spr[$ clase][$ _anim][$ facing];
if (sprite_index != _new_spr) {
    var _frame = image_index;
    sprite_index = _new_spr;
    // al caminar conserva el cuadro al cambiar de direccion; en otros casos empieza en 0
    image_index = (state == "walk" || state == "dash" || (_anim == "ataque" && _anim_prev == "ataque")) ? (_frame mod image_number) : 0;
}
// quieto con el sprite de caminata: congelado en el primer cuadro
if (state == "idle" && reposo_usa_caminata) {
    image_speed = 0;
    image_index = 0;
} else if (state == "charge") {
    // cargando: se queda en el cuadro de "baculo apuntando"
    image_speed = 0;
    image_index = mago_cfg.frame_carga;
} else {
    image_speed = (state == "attack") ? atk_img_speed : 1;
}

// ===== Lanzar el proyectil de la clase cuando la animacion llega al cuadro del disparo =====
if (proy_pendiente) {
    if (state != "attack" || clase != proy_clase) {
        proy_pendiente = false;          // el ataque se cancelo (dash, cambio de clase)
    } else {
        var _pd = proy[$ clase];
        if (image_index >= _pd.frame) {
            proy_pendiente = false;
            var _pa = point_direction(x, y, mouse_x, mouse_y);
            instance_create_depth(x + lengthdir_x(_pd.dist, _pa), y + lengthdir_y(_pd.dist, _pa), depth - 1,
                                  _pd.obj, { direccion: _pa, dano: _pd.dano, escala: escala_jugador * _pd.escala });
        }
    }
}

// ===== Dejar un espejismo atras mientras dura el dash =====
if (_dejar_espejismo) {
    var _es = escala[$ clase][$ anim][$ facing] * escala_jugador;
    array_push(espejismos, { x: _gx, y: _gy + 14 * (1 - _es), spr: sprite_index, img: image_index, esc: _es, vida: espejismo_vida });
}
