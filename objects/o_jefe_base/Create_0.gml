// ===== Jefe base (padre del Orco Mecha, el Dragon cibernetico y el General Demonio) =====
// Hijo de o_enemigo_base: hereda vida, dano, muerte, movimiento y dibujo con sprites.
//
// Ciclo:  perseguir (pausa entre ataques) -> aviso -> atacar -> recuperar -> perseguir
// Cada ataque es un struct en "fases":
//   { nombre: "misiles", aviso: 30, dur: 48, recuperacion: 40, repetir: 1, aviso_rep: 20 }
//     aviso        pasos de aviso (el jefe se prepara; el jugador tiene tiempo de reaccionar)
//     dur          pasos maximos que dura el ataque (el hijo puede terminarlo antes con ataque_terminado = true)
//     recuperacion pasos quieto despues (ventana para pegarle)
//     repetir      (opcional) veces seguidas que lo hace; aviso_rep = aviso de las repeticiones
// El hijo programa los ataques en estos metodos, con un switch por nombre:
//   al_avisar(nombre)          una vez, al empezar el aviso
//   durante_aviso(nombre)      cada paso del aviso
//   al_atacar(nombre)          una vez, al empezar el ataque
//   durante_ataque(nombre, t)  cada paso del ataque (t = pasos desde que empezo)
//
// Fases: fases[i].hp = fraccion de vida a la que empieza esa fase (la primera siempre es 1).
// Al cambiar de fase pasa por "transicion" (invulnerable) y llama a al_cambiar_fase(fase).
// Sprites por fase: en la fase 2 se buscan primero las claves con "f2_" delante (ej. "f2_perseguir").
event_inherited();

nombre       = "Jefe";
hp_max       = 300;
hp           = hp_max;
radio        = 26;
vel          = 1;
color        = c_maroon;
monedas_drop = 30;
pesado       = true;    // los enemigos normales no lo empujan
barra_vida   = false;   // usa la barra grande del HUD (Draw GUI)
dur_caida    = 40;
dur_muerto   = 120;

dist_ideal = 60;        // entre ataques se acerca hasta esta distancia
pausa_min  = 50;        // pasos entre ataques (al azar entre min y max)
pausa_max  = 90;

fase   = 0;
fases  = [ { hp: 1, ataques: [] } ];
dur_transicion = 90;
invulnerable   = false;

ataque           = undefined;   // ataque actual (struct)
ultimo_ataque    = "";
repeticiones     = 0;
t_ataque         = 0;
ataque_terminado = false;
aviso_total      = 1;           // pasos totales del aviso actual (para avisos que crecen: 1 - timer / aviso_total)
recuperacion_extra = 0;         // pasos que se suman a la recuperacion del ataque actual (ej. aturdido)
timer            = pausa_max;

recibir_dano = function(_cantidad) {
    if (invulnerable || estado == "transicion") return;
    hp -= _cantidad;
    flash = 6;
};

// ===== Metodos que cada jefe reemplaza =====
al_avisar       = function(_n) {};
durante_aviso   = function(_n) {};
al_atacar       = function(_n) {};
durante_ataque  = function(_n, _t) {};
al_cambiar_fase = function(_f) {};
// Movimiento entre ataques. Por defecto se acerca hasta dist_ideal.
movimiento_libre = function() {
    dir_mira = point_direction(x, y, o_player.x, o_player.y);
    if (point_distance(x, y, o_player.x, o_player.y) > dist_ideal) mover(dir_mira, vel);
};

// Ataque al azar de la fase actual, sin repetir el anterior (si hay mas de uno).
elegir_ataque = function() {
    var _lista = fases[fase].ataques;
    var _n = array_length(_lista);
    var _a = _lista[irandom(_n - 1)];
    while (_n > 1 && _a.nombre == ultimo_ataque) _a = _lista[irandom(_n - 1)];
    ultimo_ataque = _a.nombre;
    return _a;
};

empezar_aviso = function(_pasos) {
    estado   = "aviso";
    timer    = _pasos;
    aviso_total = max(1, _pasos);
    variante = ataque.nombre;
    al_avisar(ataque.nombre);
};

comportamiento = function() {
    if (!instance_exists(o_player)) return;

    // ===== Cambio de fase segun la vida =====
    if (estado != "transicion" && fase + 1 < array_length(fases) && hp / hp_max <= fases[fase + 1].hp) {
        fase    += 1;
        estado   = "transicion";
        timer    = dur_transicion;
        variante = "";
        alpha_cuerpo = 1;
        invulnerable = false;
        al_cambiar_fase(fase);
        return;
    }

    switch (estado) {
        case "perseguir":
            movimiento_libre();
            timer -= 1;
            if (timer <= 0) {
                ataque = elegir_ataque();
                repeticiones = ataque[$ "repetir"] ?? 1;
                empezar_aviso(ataque.aviso);
            }
            break;

        case "aviso":
            durante_aviso(ataque.nombre);
            timer -= 1;
            if (timer <= 0) {
                estado = "atacar";
                t_ataque = 0;
                ataque_terminado = false;
                al_atacar(ataque.nombre);
            }
            break;

        case "atacar":
            durante_ataque(ataque.nombre, t_ataque);
            t_ataque += 1;
            if (ataque_terminado || t_ataque >= ataque.dur) {
                repeticiones -= 1;
                if (repeticiones > 0) {
                    empezar_aviso(ataque[$ "aviso_rep"] ?? ataque.aviso);
                } else {
                    estado = "recuperar";
                    timer  = ataque.recuperacion + recuperacion_extra;
                    recuperacion_extra = 0;
                }
            }
            break;

        case "recuperar":
            timer -= 1;
            if (timer <= 0) {
                estado   = "perseguir";
                variante = "";
                timer    = irandom_range(pausa_min, pausa_max);
            }
            break;

        case "transicion":
            timer -= 1;
            if (timer <= 0) {
                estado = "perseguir";
                timer  = pausa_min;
            }
            break;
    }
};

// En fase 2+ prueba primero las claves con prefijo "f2_", "f3_"...
claves_sprite = function() {
    var _base = [estado + "_" + variante, estado, "perseguir"];
    if (fase == 0) return _base;
    var _p = "f" + string(fase + 1) + "_";
    return [_p + _base[0], _p + _base[1], _p + _base[2], _base[0], _base[1], _base[2]];
};
