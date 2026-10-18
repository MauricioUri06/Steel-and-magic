// Elite con lanzamisiles (fuerte, distancia): misil lento teledirigido que explota en area.
event_inherited();
hp_max = 30;
hp     = hp_max;
vel    = 0.9;
radio  = 15;
color  = make_colour_rgb(120, 30, 30);
monedas_drop = 3;

dist_ideal = 230;
dist_min   = 140;
aviso      = 40;
cd_disparo = 150;
proy_obj   = o_misil_enemigo;
proy_vel   = 3;
proy_dano  = 5;
proy_color = c_orange;
