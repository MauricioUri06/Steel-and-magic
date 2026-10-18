// Goblin con implantes (basico, melee): rapido y fragil, golpe corto con el cuchillo.
event_inherited();
hp_max = 8;
hp     = hp_max;
xp_drop = 1;
vel    = 1.8;
radio  = 10;
color  = c_green;

dano         = 2;
rango_ataque = 26;
area_radio   = 16;
aviso        = 20;

spr_por_estado = {
    perseguir: spr_goblin_caminar,
    aviso:     spr_goblin_aviso,
    atacar:    spr_goblin_ataque,
    recuperar: spr_goblin_recuperar,
    cayendo:   spr_goblin_caida,
    muerto:    spr_goblin_muerto
};
