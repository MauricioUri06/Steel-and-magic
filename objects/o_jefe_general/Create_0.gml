// ===== General Demonio (jefe del acto 3, 2 fases) =====
// Fase 1:
//   tajo       dos tajos con la espada; cada uno lanza un abanico de cortes.
//   orbes      dos anillos de orbes lentos (pasar entre los huecos).
//   invocar    abre portales y llama esbirros (con limite).
// Fase 2 (al 50% de vida): onda de choque al transformarse, se vuelve mas rapido y agresivo.
//   teletajo   desaparece, aparece al lado tuyo (marca una sombra antes) y tajea; 3 veces.
//   espiral    espiral de fuego girando.
//   lluvia     lluvia infernal: fuego que cae en varias zonas alrededor tuyo (una justo donde estas).
//   invocar    esbirros mas fuertes.
event_inherited();

nombre = "General Demonio";
subtitulo = "Jefe del Acto III";
intro_spr = spr_general_intro;   // ilustracion de la presentacion (o_intro_jefe)
hp_max = 500;
hp     = hp_max;
radio  = 24;
escala_sprite = 1.15;   // el sprite (96x80) es grande: un poco menos que la escala del jugador
dur_caida     = ceil(15 / anim_vel);   // lo que dura la animacion de muerte (15 cuadros)
vel    = 1.2;
color  = make_colour_rgb(150, 20, 30);

dist_ideal = 45;
pausa_min  = 45;
pausa_max  = 75;

var _invocar = { nombre: "invocar", aviso: 50, dur: 20, recuperacion: 40 };
fases = [
    { hp: 1, ataques: [
        { nombre: "tajo",  aviso: 32, aviso_rep: 22, dur: 14, recuperacion: 30, repetir: 2 },
        { nombre: "orbes", aviso: 40, dur: 50, recuperacion: 35 },
        _invocar
    ]},
    { hp: 0.5, ataques: [
        { nombre: "teletajo", aviso: 36, aviso_rep: 26, dur: 14, recuperacion: 35, repetir: 3 },
        { nombre: "espiral",  aviso: 30, dur: 120, recuperacion: 40 },
        { nombre: "lluvia",   aviso: 30, dur: 30, recuperacion: 35 },
        _invocar
    ]}
];

color_corte  = make_colour_rgb(255, 200, 210);
color_orbe   = make_colour_rgb(170, 60, 220);
color_fuego  = make_colour_rgb(255, 90, 40);

alcance_tajo = 34;      // radio del golpe delante de el
dano_tajo    = 6;
dano_corte   = 3;       // cada bala del abanico
dano_orbe    = 3;
dano_espiral = 2;
ang_espiral  = 0;
dano_lluvia  = 4;
max_esbirros = 6;
esbirros_f1  = [o_enemigo_goblin, o_enemigo_diablillo];
esbirros_f2  = [o_enemigo_demonio_escudo, o_enemigo_diablillo, o_enemigo_goblin];

dest_x = 0;             // a donde aparece en el teletajo
dest_y = 0;

// Golpe de espada delante + abanico de 5 cortes.
tajear = function() {
    dir_mira = point_direction(x, y, o_player.x, o_player.y);
    var _fx = x + lengthdir_x(radio + 20, dir_mira), _fy = y + lengthdir_y(radio + 20, dir_mira);
    if (jugador_cerca(_fx, _fy, alcance_tajo)) danar_jugador(dano_tajo);
    for (var _i = -2; _i <= 2; _i++) {
        disparar_bala(_fx, _fy, dir_mira + _i * 12, 5, dano_corte, color_corte, 5);
    }
};

al_avisar = function(_n) {
    switch (_n) {
        case "tajo":
            dir_mira = point_direction(x, y, o_player.x, o_player.y);
            break;
        case "teletajo":
            invulnerable = true;
            var _a = random(360);
            dest_x = clamp(o_player.x + lengthdir_x(55, _a), radio, room_width - radio);
            dest_y = clamp(o_player.y + lengthdir_y(55, _a), radio, room_height - radio);
            break;
    }
};

durante_aviso = function(_n) {
    if (_n == "teletajo") alpha_cuerpo = max(0, alpha_cuerpo - 0.08);   // se desvanece
};

al_atacar = function(_n) {
    switch (_n) {
        case "tajo":
            tajear();
            break;
        case "teletajo":
            x = dest_x;
            y = dest_y;
            alpha_cuerpo = 1;
            invulnerable = false;
            tajear();
            break;
        case "invocar":
            var _cuantos = 0;
            with (o_enemigo_base) if (es_enemigo && !pesado) _cuantos += 1;
            var _tipos = (fase == 0) ? esbirros_f1 : esbirros_f2;
            for (var _i = 0; _i < 3 && _cuantos < max_esbirros; _i++) {
                var _a = _i * 120 + random(40);
                var _ex = clamp(x + lengthdir_x(70, _a), 16, room_width - 16);
                var _ey = clamp(y + lengthdir_y(70, _a), 16, room_height - 16);
                instance_create_depth(_ex, _ey, 0, _tipos[irandom(array_length(_tipos) - 1)]);
                crear_onda(_ex, _ey, 40, 2, 0, color_orbe);   // portal (sin dano)
                _cuantos += 1;
            }
            break;
        case "lluvia":
            crear_zona(o_player.x, o_player.y, "fuego", 36, 55, dano_lluvia, 120);
            repeat (7) {
                var _a = random(360), _d = irandom_range(60, 220);
                crear_zona(o_player.x + lengthdir_x(_d, _a), o_player.y + lengthdir_y(_d, _a), "fuego", 36, 55, dano_lluvia, 120);
            }
            break;
    }
};

durante_ataque = function(_n, _t) {
    switch (_n) {
        case "orbes":
            if (_t == 0)  disparar_anillo(x, y, 14, random(360), 2.2, dano_orbe, color_orbe, 6);
            if (_t == 25) disparar_anillo(x, y, 14, random(360), 2.2, dano_orbe, color_orbe, 6);
            break;
        case "espiral":
            if (_t mod 4 == 0) {
                ang_espiral += 14;
                disparar_bala(x, y, ang_espiral,       3, dano_espiral, color_fuego, 5);
                disparar_bala(x, y, ang_espiral + 180, 3, dano_espiral, color_fuego, 5);
            }
            break;
    }
};

al_cambiar_fase = function(_f) {
    // transformacion: onda de choque, mas rapido y con menos pausa entre ataques
    crear_onda(x, y, 300, 5, 3, color_orbe);
    vel       = 1.6;
    pausa_min = 30;
    pausa_max = 55;
    color     = make_colour_rgb(90, 10, 40);
};

dibujar_suelo = function() {
    // sombra donde va a aparecer en el teletajo
    if (estado == "aviso" && variante == "teletajo") {
        var _p = 1 - timer / aviso_total;
        var _r = 10 + 14 * _p;
        draw_set_color(make_colour_rgb(30, 0, 20));
        draw_set_alpha(0.25 + 0.45 * _p);
        draw_ellipse(dest_x - _r, dest_y + radio - _r * 0.6, dest_x + _r, dest_y + radio + _r * 0.6, false);
        draw_set_alpha(1);
    }
};

dibujar_extra = function() {
    // estela del tajo (efecto del golpe, no aviso)
    if (estado == "atacar" && (variante == "tajo" || variante == "teletajo")) {
        draw_set_color(color_corte);
        draw_set_alpha(1 - t_ataque / ataque.dur);
        var _r = radio + 22;
        for (var _a = -50; _a < 50; _a += 10) {
            draw_line_width(x + lengthdir_x(_r, dir_mira + _a),      y + lengthdir_y(_r, dir_mira + _a),
                            x + lengthdir_x(_r, dir_mira + _a + 10), y + lengthdir_y(_r, dir_mira + _a + 10), 3);
        }
        draw_set_alpha(1);
    }
    // transformacion: aura que late
    if (estado == "transicion") {
        draw_set_color(color_orbe);
        draw_set_alpha(0.3 + 0.2 * sin(current_time / 80));
        draw_circle(x, y, radio + 8 + 4 * sin(current_time / 120), false);
        draw_set_alpha(1);
    }
};

// Sprites (claves: estado o "estado_ataque"; la fase 2 usa las claves con "f2_" delante).
spr_por_estado = {
    perseguir: spr_general_caminar,
    aviso:     spr_general_aviso,
    atacar:    spr_general_ataque,
    recuperar: spr_general_recuperar,
    cayendo:   spr_general_muerte,    // se cae y se deshace en cenizas (15 cuadros)
    muerto:    spr_general_cenizas,   // queda el monton de cenizas y se desvanece

    f2_perseguir:  spr_general2_caminar,
    f2_transicion: spr_general2_aviso,
    f2_aviso:      spr_general2_aviso,
    f2_atacar:     spr_general2_ataque,
    f2_recuperar:  spr_general2_recuperar,
    f2_cayendo:    spr_general_muerte,
    f2_muerto:     spr_general_cenizas
};

// El final usa la misma captura de escenario que la intro, con su propio reloj.
muerte_final_t = 0;
muerte_final_impacto = 0.22;
muerte_final_ruptura = 1.6;
muerte_final_cenizas = 4.8;
muerte_final_titulo = 5.1;
muerte_final_salida = 6.7;
muerte_final_fin = 7.5;
muerte_final_captura = -1;
muerte_final_congelado = false;
muerte_final_jugador = noone;
muerte_final_nivel = 1;
muerte_final_pose = spr_general_caminar;
muerte_final_frame = 0;
muerte_final_camara_x = 0;
muerte_final_camara_y = 0;
muerte_final_camara_w = room_width;
muerte_final_camara_h = room_height;

morir_normal = morir;
morir = function() {
    if (!es_enemigo) return;
    muerte_final_jugador = instance_find(o_player, 0);
    if (instance_exists(muerte_final_jugador)) muerte_final_nivel = muerte_final_jugador.nivel;
    muerte_final_pose = buscar_sprite();
    muerte_final_frame = floor(anim) mod sprite_get_number(muerte_final_pose);
    morir_normal();   // conserva las monedas, la baja y los orbes; solo se paga una vez
    hp = 0;
    depth = -10001;

    var _cam = view_camera[0];
    if (_cam != -1) {
        muerte_final_camara_x = camera_get_view_x(_cam);
        muerte_final_camara_y = camera_get_view_y(_cam);
        muerte_final_camara_w = camera_get_view_width(_cam);
        muerte_final_camara_h = camera_get_view_height(_cam);
    }

    // Al caer el General se acaba el combate, incluidos sus ataques pendientes.
    with (o_proyectil_enemigo) instance_destroy();
    with (o_misil_enemigo) instance_destroy();
    with (o_zona_peligro) instance_destroy();
    with (o_onda_choque) instance_destroy();
    with (o_enemigo_base) {
        if (es_enemigo && !pesado) morir();
    }
};
