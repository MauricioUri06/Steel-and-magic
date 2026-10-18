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
                if (tipo_ataque == "embestida") crear_grieta();
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
                cd     = cd_ataque;
            }
            break;

        case "recuperar":
            timer -= 1;
            if (timer <= 0) estado = "perseguir";
            break;
    }
};

// ===== Aviso de la embestida: una grieta en el suelo que avanza por el camino de la carga =====
grieta_color = make_colour_rgb(25, 18, 14);
grieta_luz   = make_colour_rgb(110, 95, 80);   // borde claro, da sensacion de profundidad
grieta       = [];     // puntos del trazo principal: { d: distancia a lo largo, o: desvio lateral }
grieta_ramas = [];     // ramitas: { d, ang, largo }
grieta_x     = 0;      // desde donde sale (los pies al empezar el aviso)
grieta_y     = 0;

// Se genera una vez por ataque (si se generara en cada Draw, temblaria).
crear_grieta = function() {
    grieta = []; grieta_ramas = [];
    grieta_x = x;
    grieta_y = y + pies_dy();
    var _largo = vel_embestida * dur_embestida, _o = 0;
    for (var _d = 0; _d <= _largo; _d += 7) {
        _o = clamp(_o + irandom_range(-3, 3), -5, 5);
        array_push(grieta, { d: _d, o: (_d == 0) ? 0 : _o });
        if (_d > 10 && random(1) < 0.3) {
            array_push(grieta_ramas, { d: _d, o: _o, ang: choose(-1, 1) * irandom_range(30, 60), largo: irandom_range(5, 10) });
        }
    }
};

// punto de la grieta en coordenadas del room
grieta_px = function(_d, _o) { return grieta_x + lengthdir_x(_d, dir_mira) + lengthdir_x(_o, dir_mira + 90); };
grieta_py = function(_d, _o) { return grieta_y + lengthdir_y(_d, dir_mira) + lengthdir_y(_o, dir_mira + 90); };

dibujar_suelo = function() {
    // solo durante el aviso: crece y desaparece en cuanto empieza la carga
    if (tipo_ataque != "embestida" || estado != "aviso" || array_length(grieta) == 0) return;
    var _alpha = 0.85;
    var _max = min(1, (1 - timer / aviso) / 0.7) * grieta[array_length(grieta) - 1].d;

    draw_set_alpha(_alpha);
    for (var _i = 1; _i < array_length(grieta); _i++) {
        var _a = grieta[_i - 1], _b = grieta[_i];
        if (_b.d > _max) break;
        var _w = lerp(3, 1, _b.d / max(1, _max + 7));   // mas ancha cerca del enemigo
        draw_set_color(grieta_luz);
        draw_line_width(grieta_px(_a.d, _a.o), grieta_py(_a.d, _a.o) + 1, grieta_px(_b.d, _b.o), grieta_py(_b.d, _b.o) + 1, 1);
        draw_set_color(grieta_color);
        draw_line_width(grieta_px(_a.d, _a.o), grieta_py(_a.d, _a.o), grieta_px(_b.d, _b.o), grieta_py(_b.d, _b.o), _w);
    }
    draw_set_color(grieta_color);
    for (var _j = 0; _j < array_length(grieta_ramas); _j++) {
        var _r = grieta_ramas[_j];
        if (_r.d > _max) continue;
        var _x0 = grieta_px(_r.d, _r.o), _y0 = grieta_py(_r.d, _r.o);
        draw_line_width(_x0, _y0, _x0 + lengthdir_x(_r.largo, dir_mira + _r.ang), _y0 + lengthdir_y(_r.largo, dir_mira + _r.ang), 1);
    }
    draw_set_alpha(1);
};
