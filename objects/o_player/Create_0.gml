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
    // monedas = minimo de monedas | dist = distancia del dash (px) | cd = pasos para recuperar una carga (60 = 1 s)
    // cargas = dashes seguidos | dano = dano que hace a cada enemigo que atraviesas
    { monedas: 0,   dist: 120, cd: 70, cargas: 1, dano: 2 },
    { monedas: 10,  dist: 150, cd: 55, cargas: 1, dano: 3 },
    { monedas: 25,  dist: 180, cd: 45, cargas: 2, dano: 4 },
    { monedas: 50,  dist: 210, cd: 35, cargas: 2, dano: 5 },
    { monedas: 100, dist: 250, cd: 25, cargas: 3, dano: 7 }
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
carga_t    = 0;   // 0..1
carga_esc  = 1;   // tamano actual de la bola
carga_dist = 0;   // distancia actual de la bola al jugador
