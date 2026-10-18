// Solo para probar: teclas 1-6 crean un enemigo en el cursor, 7-9 un jefe, R destruye todos.
var _tipos = [o_enemigo_goblin, o_enemigo_diablillo, o_enemigo_demonio_escudo,
              o_enemigo_orco_exo, o_enemigo_elfo, o_enemigo_elite_misiles,
              o_jefe_orco_mecha, o_jefe_dragon, o_jefe_general];
for (var _i = 0; _i < array_length(_tipos); _i++) {
    if (keyboard_check_pressed(ord(string(_i + 1)))) instance_create_depth(mouse_x, mouse_y, 0, _tipos[_i]);
}
if (keyboard_check_pressed(ord("R"))) {
    instance_destroy(o_enemigo_base);
    instance_destroy(o_proyectil_enemigo);
    instance_destroy(o_zona_peligro);
    instance_destroy(o_onda_choque);
    instance_destroy(o_grieta_suelo);
    instance_destroy(o_orbe_xp);
}
