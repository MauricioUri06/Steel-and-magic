// Elfo oscuro con rifle de energia (medio, distancia): rafaga de 3 disparos rapidos.
event_inherited();
hp_max = 12;
hp     = hp_max;
vel    = 1.4;
radio  = 11;
color  = make_colour_rgb(60, 50, 90);
monedas_drop = 2;

dist_ideal   = 200;
dist_min     = 120;
aviso        = 30;
cd_disparo   = 100;
rafaga       = 3;
rafaga_pausa = 6;
proy_vel     = 7;
proy_dano    = 2;
proy_color   = c_aqua;   // el rifle del sprite dispara energia cian

spr_por_estado = {
    perseguir: spr_elfo_caminar,
    apuntar:   spr_elfo_apuntar,
    disparar:  spr_elfo_disparo,
    recuperar: spr_elfo_recuperar,
    cayendo:   spr_elfo_caida,
    muerto:    spr_elfo_muerto
};
