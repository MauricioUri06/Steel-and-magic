// ===== Orco Mecha (jefe del acto 2) =====
// Un orco dentro de un mecha. Ataques:
//   salto      3 saltos seguidos hacia ti; cada uno avisa con una grieta y al caer agrieta el suelo.
//              Si choca contra una pared queda aturdido.
//   sismo      golpea el suelo: dos ondas de choque que se esquivan con el dash o alejandose.
//   misiles    lanza misiles al aire: caen donde marcan las sombras (la primera, donde estas parado).
event_inherited();

nombre = "Orco Mecha";
subtitulo = "Jefe del Acto II";
sala_siguiente = rm_acto_3_fortaleza;   // al vencerlo se pasa al acto 3
intro_spr = spr_orco_mecha_intro;   // ilustracion de la presentacion (o_intro_jefe)
sfx_intro = sfx_rugido_orco;   // rugido de la presentacion
hp_max = 600;   // antes 350, luego 420: tiene que ser mas duro que el dragon (480)
hp     = hp_max;
radio  = 32;
escala_sprite = 1.6;   // el sprite mide 96x80
vel    = 0.8;
color  = make_colour_rgb(80, 100, 60);

dist_ideal = 50;
pausa_min  = 40;
pausa_max  = 80;

fases = [
    { hp: 1, ataques: [
        { nombre: "salto",     aviso: 45, aviso_rep: 30, dur: 26, recuperacion: 50, repetir: 3 },
        { nombre: "sismo",     aviso: 50, dur: 50, recuperacion: 40 },
        { nombre: "misiles",   aviso: 35, dur: 56, recuperacion: 30 }
    ]}
];

vel_salto      = 8;
dano_salto     = 7;
aturdido       = 90;    // pasos extra de recuperacion si choca contra una pared
dano_sismo     = 5;
color_polvo    = make_colour_rgb(200, 180, 140);
dano_misil     = 4;
golpeo         = false;

// Al caer de un salto: grietas y polvo (solo estetica).
aterrizar = function() {
    crear_grietas(x + lado * radio * 0.5, y + pies_dy(), 60);
    crear_onda(x, y + pies_dy(), 70, 3, 0, color_polvo);
};

al_avisar = function(_n) {
    if (_n == "salto") {
        dir_mira = point_direction(x, y, o_player.x, o_player.y);   // la direccion queda fija: se puede esquivar
        crear_grieta(vel_salto * ataque.dur);
    }
};

al_atacar = function(_n) {
    switch (_n) {
        case "salto": golpeo = false; break;
        case "sismo":
            crear_onda(x, y + pies_dy(), 280, 4, dano_sismo, color_polvo);
            crear_grietas(x + lado * radio * 0.8, y + pies_dy(), 80);   // donde pega el puno (solo estetica)
            break;
    }
};

durante_ataque = function(_n, _t) {
    switch (_n) {
        case "salto":
            if (place_meeting(x + lengthdir_x(vel_salto, dir_mira), y + lengthdir_y(vel_salto, dir_mira), o_solid)) {
                // choco contra la pared: corta los saltos que faltan y queda aturdido
                ataque_terminado = true;
                repeticiones = 1;
                recuperacion_extra = aturdido;
                aterrizar();
            } else {
                mover(dir_mira, vel_salto);
                if (_t == ataque.dur - 1) aterrizar();   // ultimo paso del salto: cae
            }
            if (!golpeo && jugador_cerca(x, y, radio)) golpeo = danar_jugador(dano_salto);
            break;

        case "sismo":
            if (_t == 22) crear_onda(x, y + pies_dy(), 280, 4, dano_sismo, color_polvo);   // segunda onda
            break;

        case "misiles":
            if (_t mod 8 == 0) {
                // el primero cae justo donde esta el jugador; los demas cerca
                var _d = (_t == 0) ? 0 : irandom_range(30, 110);
                var _a = random(360);
                crear_zona(o_player.x + lengthdir_x(_d, _a), o_player.y + lengthdir_y(_d, _a), "sombra", 34, 50, dano_misil);
            }
            break;
    }
};

dibujar_suelo = function() {
    if (estado == "aviso" && variante == "salto") dibujar_grieta(min(1, (1 - timer / aviso_total) / 0.7));
};

// Sprites (claves: estado o "estado_ataque"). El salto tiene los suyos; sismo y misiles usan aviso y golpe.
spr_por_estado = {
    perseguir: spr_orco_mecha_caminar,
    aviso_salto:     spr_orco_mecha_aviso_salto,
    atacar_salto:    spr_orco_mecha_salto,
    recuperar_salto: spr_orco_mecha_aterrizaje,
    aviso:     spr_orco_mecha_aviso,
    atacar:    spr_orco_mecha_ataque,
    recuperar: spr_orco_mecha_recuperar,
    cayendo:   spr_orco_mecha_caida,
    muerto:    spr_orco_mecha_muerto
};
