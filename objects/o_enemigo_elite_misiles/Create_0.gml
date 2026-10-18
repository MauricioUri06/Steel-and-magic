// Elite con lanzamisiles (fuerte, distancia): misil lento teledirigido que explota en area.
event_inherited();
hp_max = 30;
hp     = hp_max;
xp_drop = 4;
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

spr_por_estado = {
    perseguir: spr_elite_caminar,
    apuntar:   spr_elite_apuntar,
    disparar:  spr_elite_disparo,
    recuperar: spr_elite_recuperar,
    cayendo:   spr_elite_caida,
    muerto:    spr_elite_muerto
};
anim_vel = 0.1;   // pesado: camina mas lento
