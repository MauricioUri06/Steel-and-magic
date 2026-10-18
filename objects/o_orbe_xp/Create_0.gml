// ===== Orbe de experiencia =====
// Lo sueltan los enemigos al morir (soltar_xp en o_enemigo_base). Salta un poco al caer, flota en el suelo
// y cuando el jugador se acerca vuela hacia el (iman). Al tocarlo le da su valor: o_player.ganar_xp(valor).
if (!variable_instance_exists(id, "valor")) valor = 1;

radio      = 3 + min(valor, 5);   // los que valen mas se ven mas grandes
radio_iman = 90;                  // distancia a la que empieza a volar hacia el jugador
if (instance_exists(o_player) && variable_instance_exists(o_player, "meta_bonos")) radio_iman *= o_player.meta_bonos.multiplicador_radio_monedas;   // mejora permanente Radio de experiencia
vel        = 0;
vel_max    = 9;
acel       = 0.6;

// salto inicial hacia un lado al azar
var _a = random(360), _f = random_range(1.5, 3);
hsp = lengthdir_x(_f, _a);
vsp = lengthdir_y(_f, _a);

fase = random(360);   // para que no floten todos al mismo ritmo
