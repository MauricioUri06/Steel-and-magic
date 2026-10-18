t += 1;

// saltar la intro (pasa directo a la salida)
if (t > 20 && t < salida_ini && (keyboard_check_pressed(vk_anykey) || mouse_check_button_pressed(mb_any))) t = salida_ini;

if (t >= total) {
    instance_activate_all();
    instance_destroy();
}
