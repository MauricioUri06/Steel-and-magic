// ===== Stats =====
// OJO: antes era "speed = 5". "speed" es una variable reservada de GameMaker
// (mueve la instancia sola hacia la derecha), por eso se renombra a move_speed.
move_speed = 5;
hp = 30;

// ===== Clases (se cambian con la rueda del mouse) =====
clases        = ["cab", "mago", "sol"];
nombres_clase = ["Caballero", "Mago", "Soldado"];
clase_idx     = 0;                    // empieza con caballero
clase         = clases[clase_idx];

// ===== Estado =====
state  = "idle";      // "idle" | "walk" | "attack"
facing = "abajo";     // "abajo" | "arriba" | "izquierda" | "derecha"
hsp = 0;
vsp = 0;

// ===== Sprites: spr[clase][animacion][direccion] =====
// (referenciados directamente por nombre para que GameMaker no los quite al compilar)
spr = {
    cab: {
        reposo:   { abajo: s_reposo_cab_abajo,   arriba: s_reposo_cab_arriba,   izquierda: s_reposo_cab_izquierda,   derecha: s_reposo_cab_derecha },
        caminata: { abajo: s_caminata_cab_abajo, arriba: s_caminata_cab_arriba, izquierda: s_caminata_cab_izquierda, derecha: s_caminata_cab_derecha },
        ataque:   { abajo: s_ataque_cab_abajo,   arriba: s_ataque_cab_arriba,   izquierda: s_ataque_cab_izquierda,   derecha: s_ataque_cab_derecha }
    },
    mago: {
        // el sprite de reposo hacia arriba del mago se llama "s_resposo_mago_arriba" (typo en el nombre del asset)
        reposo:   { abajo: s_reposo_mago_abajo,   arriba: s_resposo_mago_arriba,   izquierda: s_reposo_mago_izquierda,   derecha: s_reposo_mago_derecha },
        caminata: { abajo: s_caminata_mago_abajo, arriba: s_caminata_mago_arriba, izquierda: s_caminata_mago_izquierda, derecha: s_caminata_mago_derecha },
        ataque:   { abajo: s_ataque_mago_abajo,   arriba: s_ataque_mago_arriba,   izquierda: s_ataque_mago_izquierda,   derecha: s_ataque_mago_derecha }
    },
    sol: {
        reposo:   { abajo: s_reposo_sol_abajo,   arriba: s_reposo_sol_arriba,   izquierda: s_reposo_sol_izquierda,   derecha: s_reposo_sol_derecha },
        caminata: { abajo: s_caminata_sol_abajo, arriba: s_caminata_sol_arriba, izquierda: s_caminata_sol_izquierda, derecha: s_caminata_sol_derecha },
        ataque:   { abajo: s_ataque_sol_abajo,   arriba: s_ataque_sol_arriba,   izquierda: s_ataque_sol_izquierda,   derecha: s_ataque_sol_derecha }
    }
};

// Escala por sprite: iguala el tamano de reposo/ataque con el de caminata (los frames de caminata
// estan dibujados ~30% mas grandes). Se dibuja anclado a los pies en Draw. Pon todo en 1.00 para desactivarlo.
escala = {
    cab: {
        reposo: { abajo: 1.35, arriba: 1.47, izquierda: 1.30, derecha: 1.34 },
        caminata: { abajo: 1.00, arriba: 1.00, izquierda: 1.00, derecha: 1.00 },
        ataque: { abajo: 1.29, arriba: 1.32, izquierda: 1.27, derecha: 1.30 }
    },
    mago: {
        reposo: { abajo: 1.13, arriba: 1.26, izquierda: 1.23, derecha: 1.22 },
        caminata: { abajo: 1.00, arriba: 1.00, izquierda: 1.00, derecha: 1.00 },
        ataque: { abajo: 1.13, arriba: 1.17, izquierda: 1.21, derecha: 1.20 }
    },
    sol: {
        reposo: { abajo: 1.24, arriba: 1.45, izquierda: 1.30, derecha: 1.25 },
        caminata: { abajo: 1.00, arriba: 1.00, izquierda: 1.00, derecha: 1.00 },
        ataque: { abajo: 1.28, arriba: 1.28, izquierda: 1.30, derecha: 1.23 }
    }
};

// Tamano general del jugador (1.0 = original, 1.2 = un poco mas grande, alineado a los pies)
escala_jugador = 1.4;
// El arte de reposo esta dibujado con menos pixeles que el de caminata y se ve mas chico/borroso.
// Con true, el reposo usa el primer cuadro de la caminata (misma calidad y tamano). Pon false para usar los sprites de reposo.
reposo_usa_caminata = true;
anim = "reposo";
atk_timer = 0;   // pasos que le quedan a la animacion de ataque

sprite_index = spr[$ clase].reposo[$ facing];
image_speed  = 1;

// ===== Flecha que indica hacia donde apunta el jugador (sigue al cursor) =====
// El sprite s_Flecha apunta hacia ARRIBA; se pone su origen en el centro de la flecha para que gire sobre si misma.
sprite_set_offset(s_Flecha, 16, 19);
flecha_dist   = 40;    // distancia al jugador (px)
flecha_escala = 0.75;  // tamano de la flecha (1 = original, 0.5 = mitad)

// ===== Monedas y Dash (barra espaciadora) =====
// Cada nivel del dash se desbloquea al llegar a cierta cantidad de monedas.
// Para dar monedas desde otro objeto (por ejemplo al recoger una):  o_player.monedas += 1;
monedas = 0;
debug_monedas = true;   // true: la tecla C suma 5 monedas para probar. Ponlo en false cuando ya haya monedas reales.

dash_niveles = [
    // Estos niveles (mejoras permanentes) suben la DISTANCIA y el DANO del dash. Las cargas y la recarga solo cambian con cartas.
    // monedas = minimo de monedas | dist = distancia del dash (px) | cd = pasos para recuperar una carga (60 = 1 s)
    // cargas = dashes seguidos (base) | dano = dano que hace a cada enemigo que atraviesas
    { monedas: 0,   dist: 120, cd: 70, cargas: 1, dano: 2 },
    { monedas: 10,  dist: 150, cd: 70, cargas: 1, dano: 3 },
    { monedas: 25,  dist: 180, cd: 70, cargas: 1, dano: 4 },
    { monedas: 50,  dist: 210, cd: 70, cargas: 1, dano: 5 },
    { monedas: 100, dist: 250, cd: 70, cargas: 1, dano: 7 }
];
dash_nivel   = 0;                          // se calcula solo segun las monedas
dash_cargas  = dash_niveles[0].cargas;     // dashes disponibles ahora
dash_recarga = 0;                          // pasos que faltan para recuperar una carga
dash_dur     = 8;                          // duracion del dash en pasos
dash_timer   = 0;
dash_dir     = 0;                          // angulo del dash
dash_vel     = 0;                          // px por paso
dash_radio   = 26;                         // radio (px) alrededor del jugador que golpea a los enemigos
dash_golpeados = {};                       // enemigos ya golpeados en este dash (cada uno recibe dano una sola vez)
inmune       = false;                      // true mientras dura el dash (usalo cuando los enemigos hagan dano)

// Espejismos: copias del jugador que se quedan atras y se desvanecen
espejismos      = [];                      // cada uno: {x, y, spr, img, esc, vida}
espejismo_vida  = 14;                      // cuanto dura cada uno (pasos, 60 = 1 s)
espejismo_alpha = 0.55;                    // opacidad inicial
espejismo_color = make_colour_rgb(90, 220, 255);   // tinte (cian)

// ===== Proyectiles por clase =====
// obj = objeto del proyectil | frame = cuadro del ataque (0-3) en el que sale | dano = dano por enemigo
// escala = tamano del proyectil respecto al del jugador | dist = distancia desde el jugador a la que aparece (px)
// cadencia = disparos por segundo con el clic mantenido (0 = lo que dure la animacion de ataque)
// El mago todavia no tiene proyectil (no esta en la lista).
proy = {
    cab: { obj: o_proyectil_caballero, frame: 2, dano: 4, escala: 2, dist: 26, cadencia: 0 },
    sol: { obj: o_proyectil_soldado,   frame: 2, dano: 2, escala: 1, dist: 30, cadencia: 5 }
};
proy_pendiente = false;   // hay un proyectil por salir en el ataque actual
proy_clase     = "";      // clase que inicio ese ataque
atk_img_speed  = 1;       // multiplicador de velocidad de la animacion de ataque (el soldado la acelera para disparar a su cadencia)

// ===== Mago: bola de fuego con carga (mantener el clic = cargar, soltar = lanzar) =====
// Los valores "min" son sin carga (un toque rapido) y los "max" con la carga completa; entre medio se interpolan.
sprite_set_offset(s_proyectil_mago, 16, 16);   // para dibujar la bola que sostiene (mismo origen que en el proyectil)
mago_cfg = {
    obj: o_proyectil_mago,
    carga_max: 1.5,           // segundos de carga para llegar a la bola mas grande
    recarga: 0.9,             // segundos de espera entre un disparo y el siguiente (sube este numero para disparar mas lento)
    escala_min: 0.7,          // tamano de la bola sin carga (relativo al jugador)
    escala_max: 2.2,          // tamano de la bola con carga maxima
    dano_min: 3,              // dano del impacto directo sin carga
    dano_max: 8,              // dano del impacto directo con carga maxima
    efectos_min: 2,           // efectos de fuego que deja en el suelo sin carga
    efectos_max: 8,           // efectos que deja con carga maxima
    escala_efecto_min: 1,     // tamano de cada efecto (relativo al jugador)
    escala_efecto_max: 1.6,
    dano_efecto: 1,           // dano por pulso (cada 0.5 s) de cada efecto a los enemigos que estan encima
    radio_por_escala: 24,     // los efectos caen en un radio (px) = esto x el tamano de la bola
    dist: 24,                 // distancia a la que se sostiene y sale la bola (crece un poco con su tamano)
    frame_carga: 1,           // cuadro de la animacion de ataque en el que se queda mientras carga (baculo apuntando)
    frame_lanzar: 2           // cuadro desde el que sigue al soltar (el destello del hechizo)
};
carga      = 0;   // pasos que lleva cargando
mago_recarga_t = 0;   // pasos que faltan para poder cargar otra bola
carga_t    = 0;   // 0..1
carga_esc  = 1;   // tamano actual de la bola
carga_dist = 0;   // distancia actual de la bola al jugador

// ===== Mejoras (las dan las cartas) =====
// mejoras = cuantas veces se tiene cada una | mejoras_max = cuantas veces se puede obtener
// Para darle una al jugador:  o_player.mejora_subir("dash_cargas");   (devuelve false si ya esta al maximo)
// Mientras debug_mejoras sea true:  tecla 1 = +1 carga de dash | 2 = dash recarga mas rapido | 3 = un tajo mas del caballero
debug_mejoras = true;
mejoras     = { dash_cargas: 0, dash_recarga: 0, tajos: 0 };
mejoras_max = { dash_cargas: 2, dash_recarga: 1, tajos: 2 };

mejora_subir = function(_id) {
    if (!variable_struct_exists(mejoras, _id)) return false;
    if (mejoras[$ _id] >= mejoras_max[$ _id]) return false;
    mejoras[$ _id] += 1;
    if (_id == "dash_cargas") dash_cargas += 1;   // la carga nueva se regala llena
    return true;
};

// Dash: maximo de cargas y recarga = nivel por monedas + mejoras (se recalculan en el Step)
dash_recarga_mejora = 0.25;   // cada nivel de "dash recarga" baja el tiempo de recarga en este %
dash_cargas_max = dash_niveles[0].cargas;
dash_cd         = dash_niveles[0].cd;

// Tajos del caballero segun mejoras.tajos (0, 1 o 2): cada tajo = [adelante (px), lateral (px), desvio de angulo]
// 1 tajo: al frente | 2 tajos: lado a lado | 3 tajos: en triangulo (uno adelante y dos abiertos a los lados)
tajos_formacion = [
    [ [26, 0, 0] ],
    [ [26, -16, -8], [26, 16, 8] ],
    [ [50, 0, 0], [26, -30, -24], [26, 30, 24] ]
];

// ===== Colision con paredes (o_solid) =====
// Caja de colision en los pies (no usa la mascara del sprite, que cambia con cada animacion). Ajusta estos 4 valores si se siente raro.
col_izq = 10;   // px hacia la izquierda del centro
col_der = 10;   // px hacia la derecha
col_arr = 0;    // px hacia arriba (0 = la caja empieza en el centro)
col_aba = 16;   // px hacia abajo (llega a los pies)
colision_solido = function(_x, _y) {
    return collision_rectangle(_x - col_izq, _y - col_arr, _x + col_der, _y + col_aba, o_solid, false, true) != noone;
};

// ===== Fundido de entrada y pausa (Esc) =====
// - Fundido: el nivel aparece desde negro en 2 s (o_menu deja global.entrada_negro = true antes de cambiar de room).
// - Pausa: Esc congela el juego, lo oscurece un poco y muestra "Reanudar" y "Menu principal".
//   La logica esta en pausa_actualizar() (se llama al inicio del Step) y se dibuja en el Draw GUI.
global.pausa = false;                 // mientras sea true, el Step del jugador no hace nada mas
alpha_entrada = 0;
if (variable_global_exists("entrada_negro") && global.entrada_negro) {
    alpha_entrada = 1;
    global.entrada_negro = false;
}
duracion_entrada = 2;                 // segundos hasta ver el nivel completo
spr_captura = -1;                     // foto del juego al pausar
p_sel = -1;
p_modo_mouse = true;
p_mx = device_mouse_x_to_gui(0);
p_my = device_mouse_y_to_gui(0);
p_bloqueo = 0;                        // pasos en los que se ignoran clics y Enter
p_saliendo = false;                   // true al elegir "Menu principal"
p_cambiando = false;
p_alpha_salida = 0;
p_anim_vel = 0.45;
p_botones = [ { accion: "reanudar", frame: 0, spr: -1 }, { accion: "menu", frame: 0, spr: -1 } ];
p_frames = sprite_get_number(s_boton_menu);
p_esc = 2;                            // el boton de 192x48 se dibuja a 384x96
p_w = sprite_get_width(s_boton_menu) * p_esc;
p_h = sprite_get_height(s_boton_menu) * p_esc;
p_sep = 8;

// Fuentes y textos pixelados: se crean UNA sola vez para todo el juego.
// El texto se dibuja chico en una surface y se amplia x2 sin suavizado, asi que las letras quedan pixeladas.
if (!variable_global_exists("pausa_ui") || is_undefined(global.pausa_ui)) {
    var _crear = function(_texto, _fuente) {
        draw_set_font(_fuente);
        var _w = ceil(string_width(_texto)) + 8;
        var _h = ceil(string_height(_texto)) + 8;
        var _s = surface_create(_w, _h);
        surface_set_target(_s);
        draw_clear_alpha(c_black, 0);
        gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
        draw_set_color(c_white);
        draw_set_alpha(1);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        repeat (2) draw_text(floor(_w / 2), floor(_h / 2), _texto);
        gpu_set_blendmode(bm_normal);
        surface_reset_target();
        var _spr = sprite_create_from_surface(_s, 0, 0, _w, _h, false, false, floor(_w / 2), floor(_h / 2));
        surface_free(_s);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_font(-1);
        return _spr;
    };
    var _fp = font_add("Verdana", 12, true, false, 32, 255);
    var _ft = font_add("Verdana", 14, true, false, 32, 255);
    global.pausa_ui = {
        spr_pausa:    _crear("PAUSA", _ft),
        spr_reanudar: _crear("Reanudar", _fp),
        spr_menu:     _crear("Menú principal", _fp),
        spr_mejoras:  _crear("Mejoras", _fp),
        spr_fallo:    _crear("HAS FALLADO", _ft)
    };
    font_delete(_fp);
    font_delete(_ft);
}
p_botones[0].spr = global.pausa_ui.spr_reanudar;
p_botones[1].spr = global.pausa_ui.spr_menu;

// centro vertical del boton _i en la pantalla (coordenadas GUI)
p_cy = function(_i) {
    return display_get_gui_height() / 2 - 32 + _i * (p_h + p_sep);
};

// Se llama al inicio de cada Step (incluso en pausa): maneja el fundido, Esc y los botones del menu de pausa.
pausa_actualizar = function() {
    if (alpha_entrada > 0) alpha_entrada = max(0, alpha_entrada - 1 / (duracion_entrada * game_get_speed(gamespeed_fps)));
    if (p_bloqueo > 0) p_bloqueo -= 1;

    var _gw = display_get_gui_width();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _n = array_length(p_botones);
    var _resaltado = -1;

    if (p_saliendo) {
        // volviendo al menu: se oscurece en 0.5 s y cambia de room
        p_alpha_salida = min(1, p_alpha_salida + 1 / (0.5 * game_get_speed(gamespeed_fps)));
        if (p_alpha_salida >= 1 && !p_cambiando) {
            p_cambiando = true;
            // Aqui room_goto(rm_menu) NO cambiaba de room (probado: rm_menu, room_first y por nombre). game_restart() si funciona
            // y deja el juego en la primera room (el menu). Antes se liberan los recursos creados a mano, para que no queden handles invalidos.
            show_debug_message("[pausa] volviendo al menu con game_restart()");
            if (sprite_exists(spr_captura)) sprite_delete(spr_captura);
            spr_captura = -1;
            if (variable_global_exists("pausa_ui") && !is_undefined(global.pausa_ui)) {
                sprite_delete(global.pausa_ui.spr_pausa);
                sprite_delete(global.pausa_ui.spr_reanudar);
                sprite_delete(global.pausa_ui.spr_menu);
                sprite_delete(global.pausa_ui.spr_mejoras);
                sprite_delete(global.pausa_ui.spr_fallo);
                global.pausa_ui = undefined;
            }
            game_restart();
        }
    }
    else if (!global.pausa) {
        // jugando: Esc pausa
        if (keyboard_check_pressed(vk_escape) && p_bloqueo <= 0 && !muerto) {
            // foto del ultimo cuadro (sin interfaz) para seguir viendo el juego detras del menu
            spr_captura = sprite_create_from_surface(application_surface, 0, 0, surface_get_width(application_surface), surface_get_height(application_surface), false, false, 0, 0);
            global.pausa = true;
            instance_deactivate_all(true);      // congela todo lo demas (enemigos, proyectiles, efectos...); el jugador sigue activo
            p_sel = -1;
            p_modo_mouse = true;
            p_bloqueo = 10;
        }
    }
    else {
        // en pausa
        if (_mx != p_mx || _my != p_my) p_modo_mouse = true;
        var _bajo = -1;
        for (var _i = 0; _i < _n; _i++) {
            var _cy = p_cy(_i);
            if (point_in_rectangle(_mx, _my, _gw / 2 - p_w / 2, _cy - p_h / 2, _gw / 2 + p_w / 2, _cy + p_h / 2)) _bajo = _i;
        }
        var _abajo  = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
        var _arriba = keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"));
        if (_abajo || _arriba) {
            p_modo_mouse = false;
            if (p_sel < 0) p_sel = _abajo ? 0 : _n - 1;
            else p_sel = (p_sel + (_abajo ? 1 : -1) + _n) mod _n;
        }
        if (p_modo_mouse) p_sel = _bajo;
        _resaltado = p_sel;

        var _clic  = (p_bloqueo <= 0) && mouse_check_button_pressed(mb_left) && _bajo >= 0;
        var _enter = (p_bloqueo <= 0) && (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space));
        var _accion = "";
        if (_clic) { p_sel = _bajo; _accion = p_botones[p_sel].accion; }
        else if (_enter && p_sel >= 0) _accion = p_botones[p_sel].accion;
        if (keyboard_check_pressed(vk_escape) && p_bloqueo <= 0) _accion = "reanudar";   // Esc otra vez = reanudar

        if (_accion == "reanudar") {
            instance_activate_all();
            if (sprite_exists(spr_captura)) sprite_delete(spr_captura);
            spr_captura = -1;
            global.pausa = false;
            p_bloqueo = 10;
        } else if (_accion == "menu") {
            p_saliendo = true;
            show_debug_message("[pausa] elegido: Menu principal");
        }
    }
    p_mx = _mx;
    p_my = _my;

    // animacion de los botones: dorado <-> mecanico
    for (var _j = 0; _j < _n; _j++) {
        var _b = p_botones[_j];
        var _meta = (global.pausa && _j == _resaltado) ? p_frames - 1 : 0;
        _b.frame += clamp(_meta - _b.frame, -p_anim_vel, p_anim_vel);
    }
};

// Draw GUI, al INICIO: foto del juego oscurecida (la interfaz del jugador se dibuja encima)
pausa_dibujar_fondo = function() {
    if ((global.pausa || muerto) && sprite_exists(spr_captura)) {
        var _gw = display_get_gui_width();
        var _gh = display_get_gui_height();
        draw_set_color(c_black);
        draw_set_alpha(1);
        draw_rectangle(-1, -1, _gw + 1, _gh + 1, false);
        draw_sprite_stretched(spr_captura, 0, 0, 0, _gw, _gh);
        draw_set_alpha(global.pausa ? 0.5 : 0);   // oscurecido solo en la pausa: sube el numero para oscurecer mas
        draw_rectangle(-1, -1, _gw + 1, _gh + 1, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
};

// Draw GUI, al FINAL: titulo y botones de la pausa + fundidos (entrada al nivel y salida al menu)
pausa_dibujar_ui = function() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _tf = gpu_get_texfilter();
    gpu_set_texfilter(false);

    if (global.pausa && !p_cambiando) {
        // titulo pixelado: cada pixel de la letra = 4 pixeles de pantalla
        var _ty = p_cy(0) - p_h / 2 - 60;
        draw_sprite_ext(global.pausa_ui.spr_pausa, 0, _gw / 2 + 4, _ty + 4, 4, 4, 0, c_black, 0.7);
        draw_sprite_ext(global.pausa_ui.spr_pausa, 0, _gw / 2,     _ty,     4, 4, 0, make_colour_rgb(255, 214, 102), 1);
        for (var _i = 0; _i < array_length(p_botones); _i++) {
            var _b = p_botones[_i];
            var _cy = p_cy(_i);
            var _f = clamp(floor(_b.frame), 0, p_frames - 1);
            draw_sprite_ext(s_boton_menu, _f, _gw / 2 - p_w / 2, _cy - p_h / 2, p_esc, p_esc, 0, c_white, 1);
            var _t = _b.frame / (p_frames - 1);
            var _col = merge_colour(make_colour_rgb(70, 38, 8), make_colour_rgb(110, 235, 255), _t);
            var _sombra = merge_colour(make_colour_rgb(255, 224, 130), make_colour_rgb(4, 18, 28), _t);
            draw_sprite_ext(_b.spr, 0, _gw / 2, _cy + p_esc, p_esc, p_esc, 0, _sombra, 1);
            draw_sprite_ext(_b.spr, 0, _gw / 2, _cy,         p_esc, p_esc, 0, _col, 1);
        }
    }

    var _a = max(alpha_entrada, p_alpha_salida, alpha_muerte);
    if (_a > 0) {
        draw_set_color(c_black);
        draw_set_alpha(clamp(_a, 0, 1));
        draw_rectangle(-1, -1, _gw + 1, _gh + 1, false);
    }

    gpu_set_texfilter(_tf);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
};

// ===== Muerte =====
// - Mantener la tecla P 3 s mata al jugador (solo para probar, mientras debug_morir sea true). Tambien muere solo si hp llega a 0.
// - Al morir: se congela todo lo demas, la pantalla se pone negra lentamente y aparece "HAS FALLADO" en rojo con dos botones:
//   "Mejoras" y "Menu principal". Ambos vuelven al menu con game_restart() (igual que la pausa); "Mejoras" deja el menu abierto en esa pantalla.
// - Para matar al jugador desde otro objeto:  o_player.morir();
debug_morir     = true;
morir_seg       = 3;      // segundos que hay que mantener P
morir_t         = 0;      // pasos que lleva apretada
muerto          = false;
duracion_muerte = 3;      // segundos hasta que la pantalla queda negra
alpha_muerte    = 0;      // 0..1: que tan negra esta la pantalla
m_ui_t          = 0;      // 0..1: aparicion del texto y de los botones
m_bloqueo       = 40;     // pasos, despues de aparecer, en los que se ignoran clics y Enter (por si seguias atacando)
m_sel           = -1;
m_modo_mouse    = true;
m_mx = device_mouse_x_to_gui(0);
m_my = device_mouse_y_to_gui(0);
m_botones = [
    { accion: "mejoras", frame: 0, spr: global.pausa_ui.spr_mejoras },
    { accion: "menu",    frame: 0, spr: global.pausa_ui.spr_menu }
];

// centro vertical del boton _i de la pantalla de muerte
m_cy = function(_i) {
    return display_get_gui_height() / 2 + 40 + _i * (p_h + p_sep);
};

// Mata al jugador: foto del ultimo cuadro, congela todo lo demas y empieza el fundido a negro.
morir = function() {
    if (muerto) return;
    muerto = true;
    hp = 0;
    alpha_muerte = 0;
    m_ui_t = 0;
    m_bloqueo = 40;
    m_sel = -1;
    m_modo_mouse = true;
    m_mx = device_mouse_x_to_gui(0);
    m_my = device_mouse_y_to_gui(0);
    image_speed = 0;
    spr_captura = sprite_create_from_surface(application_surface, 0, 0, surface_get_width(application_surface), surface_get_height(application_surface), false, false, 0, 0);
    instance_deactivate_all(true);   // igual que la pausa: el jugador sigue activo, lo demas queda congelado
    show_debug_message("[muerte] el jugador murio");
};

// Se llama al inicio de cada Step (despues de pausa_actualizar): detecta la muerte y maneja la pantalla de "HAS FALLADO".
muerte_actualizar = function() {
    var _fps = game_get_speed(gamespeed_fps);

    if (!muerto) {
        // jugando: P apretada 3 s (prueba) o sin vida
        if (debug_morir && !global.pausa && keyboard_check(ord("P"))) {
            morir_t += 1;
            if (morir_t >= morir_seg * _fps) morir();
        } else {
            morir_t = 0;
        }
        if (!global.pausa && hp <= 0) morir();
        return;
    }

    // muerto: primero la pantalla se pone negra; despues aparecen el texto y los botones
    if (alpha_muerte < 1) alpha_muerte = min(1, alpha_muerte + 1 / (duracion_muerte * _fps));
    else if (m_ui_t < 1) m_ui_t = min(1, m_ui_t + 1 / _fps);
    else if (m_bloqueo > 0) m_bloqueo -= 1;

    var _listo = (m_ui_t >= 1 && m_bloqueo <= 0 && !p_saliendo);
    var _gw = display_get_gui_width();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _n = array_length(m_botones);
    var _resaltado = -1;

    if (_listo) {
        if (_mx != m_mx || _my != m_my) m_modo_mouse = true;
        var _bajo = -1;
        for (var _i = 0; _i < _n; _i++) {
            var _cy = m_cy(_i);
            if (point_in_rectangle(_mx, _my, _gw / 2 - p_w / 2, _cy - p_h / 2, _gw / 2 + p_w / 2, _cy + p_h / 2)) _bajo = _i;
        }
        var _abajo  = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
        var _arriba = keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"));
        if (_abajo || _arriba) {
            m_modo_mouse = false;
            if (m_sel < 0) m_sel = _abajo ? 0 : _n - 1;
            else m_sel = (m_sel + (_abajo ? 1 : -1) + _n) mod _n;
        }
        if (m_modo_mouse) m_sel = _bajo;
        _resaltado = m_sel;

        var _accion = "";
        if (mouse_check_button_pressed(mb_left) && _bajo >= 0) { m_sel = _bajo; _accion = m_botones[m_sel].accion; }
        else if (keyboard_check_pressed(vk_enter) && m_sel >= 0) _accion = m_botones[m_sel].accion;   // solo Enter (Espacio es el dash)

        if (_accion != "") {
            // o_menu lee esto al nacer: "mejoras" abre directo la pantalla de Mejoras
            global.menu_inicio = (_accion == "mejoras") ? "mejoras" : "principal";
            p_saliendo = true;   // pausa_actualizar libera los recursos y llama a game_restart()
            show_debug_message("[muerte] elegido: " + _accion);
        }
    }
    m_mx = _mx;
    m_my = _my;

    // animacion de los botones: dorado <-> mecanico
    for (var _j = 0; _j < _n; _j++) {
        var _b = m_botones[_j];
        var _meta = (_j == _resaltado) ? p_frames - 1 : 0;
        _b.frame += clamp(_meta - _b.frame, -p_anim_vel, p_anim_vel);
    }
};

// Draw GUI, despues del fundido: "HAS FALLADO" en rojo y los dos botones (aparecen poco a poco una vez todo negro)
muerte_dibujar_ui = function() {
    if (!muerto || m_ui_t <= 0 || p_saliendo) return;
    var _gw = display_get_gui_width();
    var _tf = gpu_get_texfilter();
    gpu_set_texfilter(false);
    var _a = m_ui_t;
    var _ty = m_cy(0) - p_h / 2 - 110;
    draw_sprite_ext(global.pausa_ui.spr_fallo, 0, _gw / 2 + 5, _ty + 5, 5, 5, 0, c_black, 0.7 * _a);
    draw_sprite_ext(global.pausa_ui.spr_fallo, 0, _gw / 2,     _ty,     5, 5, 0, make_colour_rgb(224, 40, 40), _a);
    for (var _i = 0; _i < array_length(m_botones); _i++) {
        var _b = m_botones[_i];
        var _cy = m_cy(_i);
        var _f = clamp(floor(_b.frame), 0, p_frames - 1);
        draw_sprite_ext(s_boton_menu, _f, _gw / 2 - p_w / 2, _cy - p_h / 2, p_esc, p_esc, 0, c_white, _a);
        var _t = _b.frame / (p_frames - 1);
        var _col = merge_colour(make_colour_rgb(70, 38, 8), make_colour_rgb(110, 235, 255), _t);
        var _sombra = merge_colour(make_colour_rgb(255, 224, 130), make_colour_rgb(4, 18, 28), _t);
        draw_sprite_ext(_b.spr, 0, _gw / 2, _cy + p_esc, p_esc, p_esc, 0, _sombra, _a);
        draw_sprite_ext(_b.spr, 0, _gw / 2, _cy,         p_esc, p_esc, 0, _col, _a);
    }
    gpu_set_texfilter(_tf);
    draw_set_alpha(1);
    draw_set_color(c_white);
};

show_debug_message("[o_player] pausa y fundido listos. alpha_entrada = " + string(alpha_entrada));
