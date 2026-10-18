if (!menu_abierto) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Guarda el ultimo fotograma completo de la room antes de pausar el mundo.
if (!captura_lista && surface_exists(application_surface)) {
    var _sw = surface_get_width(application_surface);
    var _sh = surface_get_height(application_surface);
    if (surface_exists(fondo_surface)) surface_free(fondo_surface);
    fondo_surface = surface_create(_sw, _sh);
    surface_copy(fondo_surface, 0, 0, application_surface);
    captura_lista = true;
}

if (surface_exists(fondo_surface)) {
    draw_surface_stretched(fondo_surface, 0, 0, _gw, _gh);
}

draw_set_alpha(0.72);
draw_set_color(make_colour_rgb(3, 7, 12));
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

var _u = min(_gw / 1280, _gh / 720);
var _panel_x = (_gw - 960 * _u) * 0.5;
var _panel_y = (_gh - 480 * _u) * 0.5;
var _fila_x = _panel_x + 110 * _u;
var _fila_y = _panel_y + 88 * _u;

// Panel principal: region 640x320 del atlas, ampliada a 960x480.
draw_sprite_part_ext(spr_meta_ui_atlas, 0, 192, 24, 640, 320, _panel_x, _panel_y, 1.5 * _u, 1.5 * _u, c_white, 1);

// Emblema, titulo y saldo.
draw_sprite_part_ext(spr_meta_ui_atlas, 0, 432, 672, 96, 96, _panel_x + 88 * _u, _panel_y + 10 * _u, 0.70 * _u, 0.70 * _u, c_white, 1);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_black);
draw_text_transformed(_panel_x + 174 * _u + 2, _panel_y + 18 * _u + 2, "HAS MUERTO", 2.0 * _u, 2.0 * _u, 0);
draw_set_color(make_colour_rgb(225, 184, 76));
draw_text_transformed(_panel_x + 174 * _u, _panel_y + 18 * _u, "HAS MUERTO", 2.0 * _u, 2.0 * _u, 0);

draw_set_font(-1);
draw_set_color(make_colour_rgb(80, 220, 235));
draw_text_transformed(_panel_x + 176 * _u, _panel_y + 52 * _u, "EL LEGADO PERDURA", 0.9 * _u, 0.9 * _u, 0);

draw_sprite_part_ext(spr_meta_ui_atlas, 0, 160, 704, 32, 32, _panel_x + 700 * _u, _panel_y + 26 * _u, 1.0 * _u, 1.0 * _u, c_white, 1);
draw_set_font(-1);
draw_set_color(make_colour_rgb(241, 211, 106));
draw_text_transformed(_panel_x + 740 * _u, _panel_y + 27 * _u, string(global.meta_progreso.monedas_banco), 1.15 * _u, 1.15 * _u, 0);
draw_set_font(-1);
draw_set_color(make_colour_rgb(170, 190, 199));
draw_text_transformed(_panel_x + 740 * _u, _panel_y + 50 * _u, "+" + string(global.meta_progreso.ultima_recompensa) + " ESTA RUN", 0.75 * _u, 0.75 * _u, 0);

// Encabezados de la lista.
draw_set_font(-1);
draw_set_color(make_colour_rgb(137, 170, 178));
draw_text_transformed(_fila_x + 48 * _u, _panel_y + 72 * _u, "MEJORA", 0.72 * _u, 0.72 * _u, 0);
draw_text_transformed(_fila_x + 247 * _u, _panel_y + 72 * _u, "EFECTO", 0.72 * _u, 0.72 * _u, 0);
draw_text_transformed(_fila_x + 410 * _u, _panel_y + 72 * _u, "NIVEL", 0.72 * _u, 0.72 * _u, 0);
draw_text_transformed(_fila_x + 548 * _u, _panel_y + 72 * _u, "COSTO", 0.72 * _u, 0.72 * _u, 0);

var _meta = global.meta_progreso;
for (var _i = 0; _i < array_length(_meta.mejoras); _i++) {
    var _mejora = _meta.mejoras[_i];
    var _ry = _fila_y + _i * 40 * _u;

    draw_sprite_part_ext(spr_meta_ui_atlas, 0, 224, 384, 528, 40, _fila_x, _ry, 1.40 * _u, 1.0 * _u, c_white, 1);
    draw_sprite_part_ext(spr_meta_ui_atlas, 0, _mejora.icon_x, _mejora.icon_y, 48, 48, _fila_x + 8 * _u, _ry + 4 * _u, 0.66 * _u, 0.66 * _u, c_white, 1);

    draw_set_font(-1);
    draw_set_color(make_colour_rgb(221, 229, 226));
    draw_text_transformed(_fila_x + 48 * _u, _ry + 10 * _u, _mejora.nombre, 0.80 * _u, 0.80 * _u, 0);
    draw_set_font(-1);
    draw_set_color(make_colour_rgb(86, 215, 229));
    draw_text_transformed(_fila_x + 247 * _u, _ry + 11 * _u, _mejora.efecto, 0.72 * _u, 0.72 * _u, 0);

    // Diamantes de nivel; se comprimen automaticamente para los diez niveles de vida.
    var _paso = (_mejora.max_nivel > 5) ? 10 : 16;
    var _esc_nivel = (_mejora.max_nivel > 5) ? 0.50 : 0.70;
    for (var _n = 0; _n < _mejora.max_nivel; _n++) {
        var _nx = (_n < _mejora.nivel) ? 336 : 272;
        draw_sprite_part_ext(spr_meta_ui_atlas, 0, _nx, 704, 16, 16, _fila_x + (410 + _n * _paso) * _u, _ry + 12 * _u, _esc_nivel * _u, _esc_nivel * _u, c_white, 1);
    }

    var _maximo = (_mejora.nivel >= _mejora.max_nivel);
    var _costo = meta_costo_mejora(_i);
    if (_maximo) {
        draw_set_color(make_colour_rgb(225, 184, 76));
        draw_text_transformed(_fila_x + 548 * _u, _ry + 11 * _u, "MAX", 0.80 * _u, 0.80 * _u, 0);
    } else {
        draw_sprite_part_ext(spr_meta_ui_atlas, 0, 160, 704, 32, 32, _fila_x + 542 * _u, _ry + 11 * _u, 0.50 * _u, 0.50 * _u, c_white, 1);
        draw_set_color(make_colour_rgb(241, 211, 106));
        draw_text_transformed(_fila_x + 562 * _u, _ry + 11 * _u, string(_costo), 0.80 * _u, 0.80 * _u, 0);
    }

    var _habilitado = !_maximo && (_meta.monedas_banco >= _costo);
    var _estado_x = 184;
    if (!_habilitado) _estado_x = 712;
    else if (fila_hover == _i && mouse_check_button(mb_left)) _estado_x = 536;
    else if (fila_hover == _i) _estado_x = 360;
    draw_sprite_part_ext(spr_meta_ui_atlas, 0, _estado_x, 472, 128, 40, _fila_x + 625 * _u, _ry + 4 * _u, 0.80 * _u, 0.80 * _u, c_white, 1);

    draw_set_halign(fa_center);
    draw_set_font(-1);
    draw_set_color(_habilitado ? make_colour_rgb(224, 240, 237) : make_colour_rgb(105, 116, 120));
    draw_text_transformed(_fila_x + 676 * _u, _ry + 12 * _u, _maximo ? "MAXIMO" : "MEJORAR", 0.72 * _u, 0.72 * _u, 0);
    draw_set_halign(fa_left);
}

// Boton inferior: si no se compro nada, funciona como "omitir".
var _salida_x = _gw * 0.5 - 116 * _u;
var _salida_y = _panel_y + 432 * _u;
var _salida_estado = boton_salida_hover ? (mouse_check_button(mb_left) ? 536 : 360) : 184;
draw_sprite_part_ext(spr_meta_ui_atlas, 0, _salida_estado, 472, 128, 40, _salida_x, _salida_y, 1.81 * _u, 0.90 * _u, c_white, 1);
draw_set_halign(fa_center);
draw_set_font(-1);
draw_set_color(make_colour_rgb(232, 239, 235));
var _salida_texto = compra_realizada ? "INICIAR NUEVA PARTIDA" : "OMITIR MEJORAS";
draw_text_transformed(_gw * 0.5, _salida_y + 10 * _u, _salida_texto, 0.82 * _u, 0.82 * _u, 0);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
