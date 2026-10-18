t += 1 / game_get_speed(gamespeed_fps);
// La activacion pedida al pulsar el boton se aplica al terminar ese evento.
if (saliendo) {
    if (instance_exists(jugador)) {
        jugador.p_menu_pantalla = "principal";
        jugador.p_saliendo = true;
    } else {
        ini_open("arranque.ini");
        ini_write_string("arranque", "destino", "menu");
        ini_write_string("arranque", "pantalla", "principal");
        ini_close();
        game_restart();
    }
    exit;
}
var _r = boton_rect();
hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _r[0], _r[1], _r[2], _r[3]);
var _objetivo = (hover || keyboard_check(vk_enter)) ? sprite_get_number(s_boton_menu) - 1 : 0;
var _paso = 27 / game_get_speed(gamespeed_fps);
boton_frame += clamp(_objetivo - boton_frame, -_paso, _paso);

// Bloqueo inicial para no aceptar el disparo que termino el combate.
if (!saliendo && t >= 0.8 && ((hover && mouse_check_button_pressed(mb_left)) || keyboard_check_pressed(vk_enter))) {
    saliendo = true;
    global.pausa = true;
    instance_activate_object(jugador);
}
