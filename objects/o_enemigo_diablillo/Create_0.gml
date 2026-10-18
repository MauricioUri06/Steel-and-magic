// Diablillo con jetpack (basico, distancia volador): pasa por encima de las paredes y dispara tiros debiles.
event_inherited();
hp_max  = 5;
hp      = hp_max;
vel     = 2.2;
radio   = 9;
color   = make_colour_rgb(230, 90, 40);
volador = true;
depth   = -50;   // se dibuja por encima de los que caminan

dist_ideal = 140;
dist_min   = 80;
aviso      = 24;
cd_disparo = 70;
proy_vel   = 5;
proy_dano  = 1;
proy_color = c_aqua;

spr_por_estado = {
    perseguir: spr_diablillo_caminar,
    apuntar:   spr_diablillo_apuntar,
    disparar:  spr_diablillo_disparo,
    recuperar: spr_diablillo_recuperar,
    cayendo:   spr_diablillo_caida,
    muerto:    spr_diablillo_muerto
};
