// ===== Onda de choque =====
// Anillo que se expande desde donde se crea. Golpea una vez al jugador cuando el anillo le pasa por encima;
// se esquiva con el dash (inmune) o estando lejos. Se crea con crear_onda(...) (ver scr_enemigos).
if (!variable_instance_exists(id, "radio_max")) radio_max = 240;
if (!variable_instance_exists(id, "vel"))       vel       = 4;     // px por paso que crece
if (!variable_instance_exists(id, "dano"))      dano      = 4;
if (!variable_instance_exists(id, "color"))     color     = make_colour_rgb(200, 180, 140);

radio  = 0;
grosor = 14;      // ancho del anillo que hace dano
golpeo = false;
