// Orco con exoesqueleto (fuerte, melee): lento y muy resistente. Se agacha (aviso), embiste en linea recta
// y despues queda un rato quieto recuperandose: ese es el momento para pegarle.
event_inherited();
hp_max = 40;
hp     = hp_max;
xp_drop = 4;
vel    = 0.9;
radio  = 18;
color  = make_colour_rgb(90, 110, 70);
monedas_drop = 3;

tipo_ataque   = "embestida";
dano          = 6;
rango_ataque  = 150;   // embiste desde lejos
aviso         = 40;
vel_embestida = 7;
dur_embestida = 22;    // recorre unos 150 px
cd_ataque     = 120;
recuperacion  = 45;

spr_por_estado = {
    perseguir: spr_orco_caminar,
    aviso:     spr_orco_aviso,
    atacar:    spr_orco_embestida,
    recuperar: spr_orco_recuperar,
    cayendo:   spr_orco_caida,
    muerto:    spr_orco_muerto
};
anim_vel = 0.12;
