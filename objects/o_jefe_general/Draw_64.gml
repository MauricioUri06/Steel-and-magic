if (es_enemigo) {
    event_inherited();
    exit;
}

// Capturar despues del Draw normal evita dejar una copia del jefe en el fondo.
if (!muerte_final_congelado) {
    if (surface_exists(application_surface)) {
        muerte_final_captura = sprite_create_from_surface(application_surface, 0, 0,
            surface_get_width(application_surface), surface_get_height(application_surface), false, false, 0, 0);
    }
    instance_deactivate_all(true);
    muerte_final_congelado = true;
}

var _gw = display_get_gui_width(), _gh = display_get_gui_height();
var _t = muerte_final_t;
var _entrada = 1 - power(1 - clamp((_t - muerte_final_impacto) / 1.2, 0, 1), 3);
var _salida = clamp((_t - muerte_final_salida) / (muerte_final_fin - muerte_final_salida), 0, 1);
_salida = _salida * _salida * (3 - 2 * _salida);
var _foco = _entrada * (1 - _salida);
var _zoom = 1 + 0.8 * _foco;
var _ox = (x - muerte_final_camara_x) * _gw / muerte_final_camara_w;
var _oy = (y - muerte_final_camara_y) * _gh / muerte_final_camara_h;
var _gx = lerp(_ox, _gw * 0.5, _foco);
var _gy = lerp(_oy, _gh * 0.54, _foco);
var _carga = clamp((_t - muerte_final_impacto) / (muerte_final_ruptura - muerte_final_impacto), 0, 1);
var _estallido = max(0, 1 - (_t - muerte_final_ruptura) / 0.65);
if (_t < muerte_final_ruptura) _estallido = 0;
var _temblor = ((_t < muerte_final_ruptura) ? 2 * _carga : 9 * _estallido) * _gw / 1280;
var _dx = round(sin(_t * 149) * _temblor);
var _dy = round(cos(_t * 173) * _temblor * 0.65);
_gx += _dx;
_gy += _dy;

draw_set_alpha(1);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
if (sprite_exists(muerte_final_captura)) {
    draw_sprite_stretched(muerte_final_captura, 0, _gx - _ox * _zoom, _gy - _oy * _zoom, _gw * _zoom, _gh * _zoom);
}
draw_set_alpha(0.72 * _foco);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

var _sx = escala_sprite * _gw / muerte_final_camara_w * _zoom;
var _sy = escala_sprite * _gh / muerte_final_camara_h * _zoom;
var _unidad = min(_sx, _sy);
var _fuego = make_colour_rgb(255, 110, 55);
var _oro = make_colour_rgb(255, 214, 102);
var _pecho_y = _gy - 8 * _sy;

// Rayos que se comprimen en el pecho antes de romperse hacia fuera.
if (_t >= muerte_final_impacto && _t < muerte_final_ruptura + 0.65) {
    var _energia = (_t < muerte_final_ruptura) ? _carga : _estallido;
    for (var _i = 0; _i < 12; _i++) {
        var _ang = _i * 30 + _t * 12;
        var _r = ((_t < muerte_final_ruptura) ? lerp(75, 25, _carga) : lerp(150, 25, _estallido)) * _unidad;
        draw_set_color((_i mod 2 == 0) ? color_orbe : _fuego);
        draw_set_alpha(0.65 * _energia);
        draw_triangle(_gx + lengthdir_x(5 * _unidad, _ang - 90), _pecho_y + lengthdir_y(5 * _unidad, _ang - 90),
                      _gx + lengthdir_x(5 * _unidad, _ang + 90), _pecho_y + lengthdir_y(5 * _unidad, _ang + 90),
                      _gx + lengthdir_x(_r, _ang), _pecho_y + lengthdir_y(_r, _ang), false);
    }
}

// La caida original se reproduce despacio, sin depender del numero de Draws.
var _spr = muerte_final_pose;
var _frame = muerte_final_frame;
if (_t >= muerte_final_impacto && _t < muerte_final_cenizas) {
    _spr = spr_general_muerte;
    var _caida = clamp((_t - muerte_final_ruptura) / (muerte_final_cenizas - muerte_final_ruptura), 0, 1);
    _frame = min(sprite_get_number(_spr) - 1, floor(_caida * sprite_get_number(_spr)));
} else if (_t >= muerte_final_cenizas) {
    _spr = spr_general_cenizas;
    _frame = 0;
}
draw_set_alpha(1);
draw_sprite_ext(_spr, _frame, _gx, _gy, lado * _sx, _sy, 0, c_white, 1);

var _brillo = (_t < muerte_final_impacto) ? 0.75 * (1 - _t / muerte_final_impacto) : 0;
if (_t >= muerte_final_impacto && _t < muerte_final_ruptura) _brillo = _carga * 0.7;
_brillo = max(_brillo, _estallido * 0.85);
if (_brillo > 0) {
    gpu_set_fog(true, c_white, 0, 1);
    draw_sprite_ext(_spr, _frame, _gx, _gy, lado * _sx, _sy, 0, c_white, _brillo);
    gpu_set_fog(false, c_white, 0, 0);
}

// Dos ondas visuales y brasas deterministas: nunca crean colisiones ni dano.
for (var _onda = 0; _onda < 2; _onda++) {
    var _p = (_t - muerte_final_ruptura - _onda * 0.15) / 0.85;
    if (_p < 0 || _p > 1) continue;
    draw_set_color((_onda == 0) ? _oro : color_orbe);
    draw_set_alpha((1 - _p) * 0.8);
    var _radio = (12 + 170 * _p) * _unidad;
    draw_ellipse(_gx - _radio, _gy + 24 * _sy - _radio * 0.35,
                 _gx + _radio, _gy + 24 * _sy + _radio * 0.35, true);
}
for (var _part = 0; _part < 42; _part++) {
    var _edad = _t - muerte_final_ruptura - (_part mod 7) * 0.13;
    var _vida = 1.6 + (_part mod 5) * 0.35;
    if (_edad < 0 || _edad > _vida) continue;
    var _a = _part * 137.5;
    var _dist = (8 + 32 * _edad) * _unidad;
    var _px = _gx + lengthdir_x(_dist, _a);
    var _py = _pecho_y + lengthdir_y(_dist * 0.6, _a) - 18 * _edad * _sy;
    var _tam = max(1, round((1 + _part mod 3) * _unidad));
    draw_set_color(merge_colour(_fuego, make_colour_rgb(80, 65, 85), _edad / _vida));
    draw_set_alpha(1 - _edad / _vida);
    draw_rectangle(round(_px), round(_py), round(_px) + _tam, round(_py) + _tam, false);
}

// Un unico destello suave al romperse el nucleo; las bandas encuadran el final.
draw_set_color(_oro);
draw_set_alpha(0.28 * _estallido * _estallido);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);
draw_set_color(c_black);
var _banda = _gh * 0.105 * _foco;
draw_rectangle(0, 0, _gw, _banda, false);
draw_rectangle(0, _gh - _banda, _gw, _gh, false);

var _titulo = clamp((_t - muerte_final_titulo) / 0.7, 0, 1) * (1 - _salida);
if (_titulo > 0) {
    var _esc = min(_gw / 640, _gh / 360);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(_titulo);
    draw_set_color(c_black);
    draw_text_transformed(_gw * 0.5 + 2, _gh * 0.25 + 2, "GENERAL DEMONIO DERROTADO", _esc, _esc, 0);
    draw_set_color(_oro);
    draw_text_transformed(_gw * 0.5, _gh * 0.25, "GENERAL DEMONIO DERROTADO", _esc, _esc, 0);
    draw_set_color(c_white);
    draw_text_transformed(_gw * 0.5, _gh * 0.76, "LA ULTIMA LLAMA SE HA APAGADO", _esc * 0.65, _esc * 0.65, 0);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
