// ===== Dragon cibernetico (jefe del acto 1) =====
// Vuela en circulos alrededor del jugador (pasa por encima de las paredes). Ataques:
//   aliento    barrido de plasma en abanico.
//   picada     sube fuera de vista (invulnerable); su sombra te sigue, se frena y cae: impacto,
//              onda de choque y anillo de plasma.
//   bombardeo  pasa en linea recta por encima tuyo dejando fuego en el suelo.
event_inherited();

nombre  = "Dragon cibernetico";
subtitulo = "Jefe del Acto I";
intro_spr = spr_dragon_intro;   // ilustracion de la presentacion (o_intro_jefe)
sala_siguiente = rm_acto_2_oxidado;   // al vencerlo se pasa al acto 2
hp_max  = 400;
hp      = hp_max;
radio   = 40;
escala_sprite = 2;   // mas grande que los demas (el sprite mide 96x80)
vel     = 2;
volador = true;
depth   = -60;
color   = make_colour_rgb(40, 120, 140);

pausa_min = 40;
pausa_max = 70;

fases = [
    { hp: 1, ataques: [
        { nombre: "aliento",   aviso: 40, dur: 70, recuperacion: 35 },
        { nombre: "picada",    aviso: 90, dur: 20, recuperacion: 50 },
        { nombre: "bombardeo", aviso: 30, dur: 60, recuperacion: 30 }
    ]}
];

dist_orbita = 200;          // distancia a la que vuela alrededor del jugador
giro_orbita = 0.8;          // grados por paso que da la vuelta
ang_orbita  = undefined;
color_plasma = c_aqua;

dir_apunta     = 0;
dano_aliento   = 2;
apertura       = 80;        // grados del abanico del aliento

sombra_x       = 0;
sombra_y       = 0;
vel_sombra     = 3.2;       // la sombra te persigue a esta velocidad...
sombra_fija    = 25;        // ...y los ultimos pasos del aviso se queda quieta (para esquivar)
radio_picada   = 70;
dano_picada    = 7;

dir_vuelo      = 0;
vel_bombardeo  = 5.5;
dano_fuego     = 3;

// Vuela en circulo alrededor del jugador.
movimiento_libre = function() {
    if (is_undefined(ang_orbita)) ang_orbita = point_direction(o_player.x, o_player.y, x, y);
    ang_orbita += giro_orbita;
    var _tx = o_player.x + lengthdir_x(dist_orbita, ang_orbita);
    var _ty = o_player.y + lengthdir_y(dist_orbita, ang_orbita);
    if (point_distance(x, y, _tx, _ty) > vel) mover(point_direction(x, y, _tx, _ty), vel);
    dir_mira = point_direction(x, y, o_player.x, o_player.y);
};

al_avisar = function(_n) {
    switch (_n) {
        case "picada":
            invulnerable = true;
            sombra_x = x;
            sombra_y = y + pies_dy();
            break;
        case "bombardeo":
            dir_vuelo = point_direction(x, y, o_player.x, o_player.y);
            dir_mira  = dir_vuelo;
            break;
    }
};

durante_aviso = function(_n) {
    switch (_n) {
        case "aliento":
            dir_apunta = point_direction(x, y, o_player.x, o_player.y);
            dir_mira   = dir_apunta;
            break;
        case "picada":
            alpha_cuerpo = max(0, alpha_cuerpo - 0.05);   // sube y sale de vista
            if (timer > sombra_fija) {
                var _d = point_distance(sombra_x, sombra_y, o_player.x, o_player.y);
                var _a = point_direction(sombra_x, sombra_y, o_player.x, o_player.y);
                sombra_x += lengthdir_x(min(vel_sombra, _d), _a);
                sombra_y += lengthdir_y(min(vel_sombra, _d), _a);
            }
            break;
    }
};

al_atacar = function(_n) {
    if (_n == "picada") {
        // cae sobre la sombra
        x = sombra_x;
        y = sombra_y - pies_dy();
        alpha_cuerpo = 1;
        invulnerable = false;
        if (jugador_cerca(sombra_x, sombra_y, radio_picada)) danar_jugador(dano_picada);
        crear_onda(sombra_x, sombra_y, 130, 5, 3, color_plasma);
        disparar_anillo(x, y, 12, random(30), 3, 2, color_plasma, 5, "llama");
    }
};

durante_ataque = function(_n, _t) {
    switch (_n) {
        case "aliento":
            if (_t mod 3 == 0) {
                var _ang = dir_apunta - apertura / 2 + apertura * _t / ataque.dur;
                dir_mira = _ang;
                disparar_bala(x + lengthdir_x(radio, _ang), y + lengthdir_y(radio, _ang), _ang, 4.5, dano_aliento, color_plasma, 5, "llama");
            }
            break;
        case "bombardeo":
            mover(dir_vuelo, vel_bombardeo);
            if (_t mod 7 == 0) crear_zona(x, y + pies_dy(), "fuego", 30, 25, dano_fuego, 150);
            break;
    }
};

dibujar_suelo = function() {
    // sombra de la picada: crece a medida que el dragon baja
    if (estado == "aviso" && variante == "picada") {
        var _p = 1 - timer / aviso_total;
        var _r = 20 + (radio_picada - 20) * _p;
        draw_set_color(c_black);
        draw_set_alpha(0.2 + 0.4 * _p);
        draw_ellipse(sombra_x - _r, sombra_y - _r * 0.6, sombra_x + _r, sombra_y + _r * 0.6, false);
        draw_set_alpha(1);
    }
};

// Sprites (claves: estado o "estado_ataque"). La picada en el aire es invisible; al caer queda en el suelo.
spr_por_estado = {
    perseguir:      spr_dragon_volar,
    aviso_aliento:  spr_dragon_aviso_aliento,
    atacar_aliento: spr_dragon_aliento,
    atacar_picada:  spr_dragon_caminar,
    recuperar:      spr_dragon_recuperar,
    cayendo:        spr_dragon_caida,
    muerto:         spr_dragon_muerto
};
