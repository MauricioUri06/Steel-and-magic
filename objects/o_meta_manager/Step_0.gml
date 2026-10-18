if (!menu_abierto) {
    if (debug_meta && keyboard_check_pressed(ord("N"))) {
        global.meta_progreso.monedas_banco += 100;
        meta_guardar();
    }
    if (debug_meta && keyboard_check_pressed(ord("M"))) {
        meta_abrir_menu_muerte(25);
    }
    exit;
}

// La captura se realiza al final del primer Draw GUI. Luego se detienen
// todas las instancias excepto este controlador, sin tocar su codigo.
if (captura_lista && !mundo_pausado) {
    instance_deactivate_all(true);
    mundo_pausado = true;
}
if (!captura_lista) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _u = min(_gw / 1280, _gh / 720);
var _panel_x = (_gw - 960 * _u) * 0.5;
var _panel_y = (_gh - 480 * _u) * 0.5;
var _fila_x = _panel_x + 110 * _u;
var _fila_y = _panel_y + 88 * _u;
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

fila_hover = -1;
for (var _i = 0; _i < array_length(global.meta_progreso.mejoras); _i++) {
    var _by = _fila_y + _i * 40 * _u + 4 * _u;
    var _bx = _fila_x + 625 * _u;
    if (point_in_rectangle(_mx, _my, _bx, _by, _bx + 102 * _u, _by + 32 * _u)) {
        fila_hover = _i;
    }
}

var _salida_x = _gw * 0.5 - 116 * _u;
var _salida_y = _panel_y + 432 * _u;
boton_salida_hover = point_in_rectangle(_mx, _my, _salida_x, _salida_y, _salida_x + 232 * _u, _salida_y + 36 * _u);

if (mouse_check_button_pressed(mb_left)) {
    if (fila_hover >= 0) {
        if (meta_comprar_mejora(fila_hover)) compra_realizada = true;
    } else if (boton_salida_hover) {
        cerrar_menu();
    }
}

if (keyboard_check_pressed(vk_escape)) cerrar_menu();
