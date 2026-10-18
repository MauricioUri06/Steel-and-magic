// Demonio con escudo mecanico (medio, melee): el escudo frontal casi anula el dano.
// El escudo gira despacio hacia el jugador: hay que rodearlo (o usar el dash) y pegarle por la espalda,
// o aprovechar cuando ataca, porque baja el escudo.
event_inherited();
hp_max = 20;
hp     = hp_max;
vel    = 1.2;
radio  = 14;
color  = make_colour_rgb(140, 40, 160);

dano         = 4;
rango_ataque = 32;
area_radio   = 20;
aviso        = 26;

spr_por_estado = {
    perseguir: spr_demonio_caminar,
    aviso:     spr_demonio_aviso,
    atacar:    spr_demonio_ataque,
    recuperar: spr_demonio_recuperar,
    cayendo:   spr_demonio_caida,
    muerto:    spr_demonio_muerto
};

escudo_dir    = 0;     // hacia donde apunta el escudo
escudo_giro   = 2.5;   // grados por paso
escudo_angulo = 70;    // medio angulo que cubre (70 = cubre 140 grados)
escudo_mult   = 0.2;   // dano que pasa a traves del escudo (20%)
bloqueo       = 0;     // pasos que el escudo se dibuja en blanco al bloquear

escudo_arriba = function() { return estado == "perseguir"; };

recibir_dano = function(_cantidad) {
    // los ataques del jugador no dicen de donde vienen: se usa la posicion del jugador
    if (escudo_arriba() && instance_exists(o_player)
        && abs(angle_difference(escudo_dir, point_direction(x, y, o_player.x, o_player.y))) < escudo_angulo) {
        _cantidad *= escudo_mult;
        bloqueo = 6;
    } else {
        flash = 6;
    }
    hp -= _cantidad;
};

comportamiento_melee = comportamiento;
comportamiento = function() {
    comportamiento_melee();
    if (bloqueo > 0) bloqueo -= 1;
    if (instance_exists(o_player)) {
        var _d = angle_difference(point_direction(x, y, o_player.x, o_player.y), escudo_dir);
        escudo_dir += clamp(_d, -escudo_giro, escudo_giro);
    }
};

dibujar_melee = dibujar_extra;
dibujar_extra = function() {
    dibujar_melee();
    // con sprite el escudo ya se ve: el arco solo aparece un instante al bloquear (indica hacia donde cubre)
    if (!escudo_arriba() || (spr_actual != -1 && bloqueo <= 0)) return;
    // arco del escudo
    draw_set_color(bloqueo > 0 ? c_white : c_ltgray);
    var _r = radio + 5;
    for (var _a = -escudo_angulo; _a < escudo_angulo; _a += 10) {
        draw_line_width(x + lengthdir_x(_r, escudo_dir + _a),      y + lengthdir_y(_r, escudo_dir + _a),
                        x + lengthdir_x(_r, escudo_dir + _a + 10), y + lengthdir_y(_r, escudo_dir + _a + 10), 3);
    }
};
