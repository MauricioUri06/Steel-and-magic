// ===== Orco Mecha (jefe del acto 1) =====
// Un orco dentro de un mecha. Ataques:
//   embestida  3 cargas seguidas; cada una avisa con una grieta. Si choca contra una pared queda aturdido.
//   sismo      golpea el suelo: dos ondas de choque que se esquivan con el dash o alejandose.
//   misiles    lanza misiles al aire: caen donde marcan las sombras (la primera, donde estas parado).
event_inherited();

nombre = "Orco Mecha";
hp_max = 350;
hp     = hp_max;
radio  = 30;
vel    = 0.8;
color  = make_colour_rgb(80, 100, 60);

dist_ideal = 50;
pausa_min  = 40;
pausa_max  = 80;

fases = [
    { hp: 1, ataques: [
        { nombre: "embestida", aviso: 45, aviso_rep: 30, dur: 26, recuperacion: 50, repetir: 3 },
        { nombre: "sismo",     aviso: 50, dur: 50, recuperacion: 40 },
        { nombre: "misiles",   aviso: 35, dur: 56, recuperacion: 30 }
    ]}
];

vel_embestida  = 8;
dano_embestida = 7;
aturdido       = 90;    // pasos extra de recuperacion si choca contra una pared
dano_sismo     = 5;
color_polvo    = make_colour_rgb(200, 180, 140);
dano_misil     = 4;
golpeo         = false;

al_avisar = function(_n) {
    if (_n == "embestida") {
        dir_mira = point_direction(x, y, o_player.x, o_player.y);   // la direccion queda fija: se puede esquivar
        crear_grieta(vel_embestida * ataque.dur);
    }
};

al_atacar = function(_n) {
    switch (_n) {
        case "embestida": golpeo = false; break;
        case "sismo":     crear_onda(x, y + pies_dy(), 280, 4, dano_sismo, color_polvo); break;
    }
};

durante_ataque = function(_n, _t) {
    switch (_n) {
        case "embestida":
            if (place_meeting(x + lengthdir_x(vel_embestida, dir_mira), y + lengthdir_y(vel_embestida, dir_mira), o_solid)) {
                // choco contra la pared: corta las cargas que faltan y queda aturdido
                ataque_terminado = true;
                repeticiones = 1;
                recuperacion_extra = aturdido;
                crear_onda(x, y + pies_dy(), 70, 3, 0, color_polvo);   // polvo del golpe (sin dano)
            } else {
                mover(dir_mira, vel_embestida);
            }
            if (!golpeo && jugador_cerca(x, y, radio)) golpeo = danar_jugador(dano_embestida);
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
    if (estado == "aviso" && variante == "embestida") dibujar_grieta(min(1, (1 - timer / aviso_total) / 0.7));
};

// Sprites cuando esten (claves: estado o "estado_ataque"):
// spr_por_estado = { perseguir: ..., aviso_embestida: ..., atacar_embestida: ..., aviso_sismo: ..., atacar_sismo: ...,
//                    aviso_misiles: ..., atacar_misiles: ..., recuperar: ..., cayendo: ..., muerto: ... };
