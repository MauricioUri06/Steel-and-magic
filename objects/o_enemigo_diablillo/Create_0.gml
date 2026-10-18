// Diablillo con jetpack (basico, melee volador): pasa por encima de las paredes y embiste en linea recta.
event_inherited();
hp_max  = 5;
hp      = hp_max;
vel     = 2.4;
radio   = 9;
color   = make_colour_rgb(230, 90, 40);
volador = true;
depth   = -50;   // se dibuja por encima de los que caminan

tipo_ataque   = "embestida";
dano          = 3;
rango_ataque  = 120;   // embiste desde lejos
aviso         = 30;
cd_ataque     = 90;
vel_embestida = 6;
dur_embestida = 22;
