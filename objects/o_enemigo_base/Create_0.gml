// ===== Enemigo base (padre de TODOS los enemigos) =====
// Arbol:  o_enemigo_base -> o_enemigo_melee / o_enemigo_rango -> cada enemigo.
// Los hijos, en su Create, llaman event_inherited() y cambian estos valores.
// Contrato con el jugador y sus proyectiles: es_enemigo = true, hp, y el metodo recibir_dano(_cantidad).

es_enemigo   = true;
hp_max       = 10;
hp           = hp_max;
vel          = 1.5;     // px por paso (nombre propio: "speed" es una variable reservada de GameMaker)
radio        = 12;      // tamano del dibujo (la colision usa la mascara spr_enemigo_mask, 24x24)
color        = c_red;
volador      = false;   // true = ignora las paredes (o_solid)
monedas_drop = 1;       // monedas que suma al jugador al morir

mask_index = spr_enemigo_mask;   // los hijos no heredan la mascara del .yy; en el Step se escala segun el radio

estado   = "perseguir"; // cada padre define sus estados; la muerte usa "cayendo" y "muerto"
timer    = 0;           // contador de uso libre para el estado actual
dir_mira = 0;           // hacia donde mira (grados)
flash    = 0;           // pasos que se dibuja en blanco despues de recibir dano

// ===== Sprites (opcional) =====
// Si un hijo llena este struct, se dibuja con sprites en vez de con formas: { estado: sprite }.
// Ejemplo: spr_por_estado = { perseguir: spr_orco_caminar, cayendo: spr_orco_caida, muerto: spr_orco_muerto };
// Un estado sin sprite usa el de "perseguir". Los sprites miran a la DERECHA; se voltean solos.
spr_por_estado = {};
escala_sprite  = 1.4;   // igual que escala_jugador, para que los pixeles midan lo mismo
anim_vel       = 0.15;  // cuadros por paso (0.15 = 9 cuadros por segundo)
anim           = 0;     // cuadro actual
spr_actual     = -1;
lado           = 1;     // 1 = mira a la derecha, -1 = a la izquierda

// ===== Muerte =====
dur_caida  = 24;        // pasos con el sprite de caida
dur_muerto = 60;        // pasos que el cadaver tarda en desvanecerse

// Lo llaman el dash, los proyectiles y los efectos del jugador.
recibir_dano = function(_cantidad) {
    hp -= _cantidad;
    flash = 6;
};

// Deja de ser enemigo (no recibe golpes, no estorba) y empieza la animacion de muerte.
morir = function() {
    if (instance_exists(o_player)) o_player.monedas += monedas_drop;
    es_enemigo = false;
    mask_index = -1;    // sin sprite_index = sin colision
    flash      = 0;
    estado     = "cayendo";
    timer      = dur_caida;
};

// Mueve en un angulo; si no vuela, se desliza contra las paredes (cada eje por separado).
mover = function(_dir, _vel) {
    var _dx = lengthdir_x(_vel, _dir);
    var _dy = lengthdir_y(_vel, _dir);
    if (volador || !place_meeting(x + _dx, y, o_solid)) x += _dx;
    if (volador || !place_meeting(x, y + _dy, o_solid)) y += _dy;
    x = clamp(x, radio, room_width - radio);
    y = clamp(y, radio, room_height - radio);
};

// IA del enemigo: cada padre la reemplaza. Por defecto solo persigue.
comportamiento = function() {
    if (!instance_exists(o_player)) return;
    dir_mira = point_direction(x, y, o_player.x, o_player.y);
    mover(dir_mira, vel);
};

// Dibujo extra encima del cuerpo (avisos de ataque, escudos...). Cada padre o hijo la reemplaza.
dibujar_extra = function() {};
// Dibujo en el suelo, DEBAJO del cuerpo (grietas, sombras...). Cada padre o hijo la reemplaza.
dibujar_suelo = function() {};

// Distancia en y desde el origen hasta los pies (para dibujar cosas en el suelo).
pies_dy = function() {
    if (spr_actual == -1) return radio;
    return (sprite_get_height(spr_actual) - sprite_get_yoffset(spr_actual) - 2) * escala_sprite;
};
