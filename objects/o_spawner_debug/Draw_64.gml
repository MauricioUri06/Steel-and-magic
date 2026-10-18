draw_set_color(c_white);
draw_text(16, 100, "DEBUG en el cursor: 1 goblin | 2 diablillo | 3 demonio escudo | 4 orco | 5 elfo | 6 elite misiles | R borrar");
if (instance_exists(o_player)) draw_text(16, 120, "HP jugador: " + string(o_player.hp));
