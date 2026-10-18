// ===== Enemigo cuerpo a cuerpo (padre de goblin, diablillo, demonio con escudo y orco) =====
// Estados: perseguir -> aviso (quieto con su sprite de aviso, ya eligio hacia donde ataca) -> atacar -> recuperar -> perseguir
// El aviso le da tiempo al jugador para alejarse o esquivar con el dash.
event_inherited();

tipo_ataque  = "golpe";   // "golpe" = area delante de el | "embestida" = carga en linea recta
rango_ataque = 30;        // distancia al jugador a la que empieza el ataque
aviso        = 24;        // pasos de aviso antes de atacar (60 = 1 s)
dano         = 3;
cd_ataque    = 50;        // pasos minimos entre ataques
recuperacion = 20;        // pasos quieto despues de atacar (ventana para pegarle)
cd           = 0;
golpeo       = false;     // ya hizo dano en este ataque

// golpe
area_radio = 20;          // radio del area del golpe (aparece delante del enemigo)
// embestida
vel_embestida = 6;
dur_embestida = 18;

// centro del area del golpe
area_x = function() { return x + lengthdir_x(radio + area_radio * 0.5, dir_mira); };
area_y = function() { return y + lengthdir_y(radio + area_radio * 0.5, dir_mira); };

comportamiento = function() {
    if (!instance_exists(o_player)) return;
    if (cd > 0) cd -= 1;

    switch (estado) {
        case "perseguir":
            dir_mira = point_direction(x, y, o_player.x, o_player.y);
            if (point_distance(x, y, o_player.x, o_player.y) <= rango_ataque && cd <= 0) {
                estado = "aviso";
                timer  = aviso;
                if (tipo_ataque == "embestida") crear_grieta(vel_embestida * dur_embestida);
            } else {
                mover(dir_mira, vel);
            }
            break;

        case "aviso":   // quieto; la direccion queda fija para que se pueda esquivar
            timer -= 1;
            if (timer <= 0) {
                estado = "atacar";
                golpeo = false;
                timer  = (tipo_ataque == "embestida") ? dur_embestida : 6;
            }
            break;

        case "atacar":
            timer -= 1;
            if (tipo_ataque == "embestida") {
                // si va a chocar con una pared, la embestida termina ahi (y pasa a recuperar)
                if (!volador && place_meeting(x + lengthdir_x(vel_embestida, dir_mira), y + lengthdir_y(vel_embestida, dir_mira), o_solid)) timer = 0;
                else mover(dir_mira, vel_embestida);
                if (!golpeo && jugador_cerca(x, y, radio)) golpeo = danar_jugador(dano);
            } else if (!golpeo) {
                golpeo = true;   // un solo intento por golpe, acierte o no
                if (jugador_cerca(area_x(), area_y(), area_radio)) danar_jugador(dano);
            }
            if (timer <= 0) {
                estado = "recuperar";
                timer  = recuperacion;
                cd     = max(0, cd_ataque - reduccion_cd);   // reduccion_cd: ver o_enemigo_base
            }
            break;

        case "recuperar":
            timer -= 1;
            if (timer <= 0) estado = "perseguir";
            break;
    }
};

// Aviso de la embestida: la grieta del base crece durante el aviso y desaparece al empezar la carga.
dibujar_suelo = function() {
    if (tipo_ataque == "embestida" && estado == "aviso") dibujar_grieta(min(1, (1 - timer / aviso) / 0.7));
};
