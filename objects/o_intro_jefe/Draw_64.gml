var _gw = display_get_gui_width(), _gh = display_get_gui_height();

// progreso de entrada (frena al llegar) y de salida (acelera al irse)
var _pin  = clamp(t / entrada, 0, 1);
_pin = 1 - power(1 - _pin, 3);
var _pout = clamp((t - salida_ini) / (total - salida_ini), 0, 1);
_pout = power(_pout, 2);

// ===== Fondo: el juego congelado, oscurecido =====
if (sprite_exists(captura)) draw_sprite_stretched(captura, 0, 0, 0, _gw, _gh);
draw_set_color(c_black);
draw_set_alpha(0.65 * min(1, t / 8) * (1 - _pout));
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// ===== Franja diagonal =====
var _cy   = _gh / 2;
var _h2   = _gh * 0.3;          // media altura de la franja
var _incl = _gw * 0.05;         // inclinacion: el borde sube hacia la derecha
var _dx   = _gw * 1.3 * (1 - _pin) - _gw * 1.3 * _pout;   // la franja entra desde la derecha y sale por la izquierda
var _temblor = (t > entrada && t < entrada + 10) ? irandom_range(-4, 4) : 0;

if (!surface_exists(superficie)) superficie = surface_create(_gw, _gh);
surface_set_target(superficie);
draw_clear_alpha(c_black, 0);
if (sprite_exists(spr)) {
    // la ilustracion llena la franja y se desliza un poco mientras esta quieta
    var _esc = (_h2 * 2.6) / sprite_get_height(spr);
    draw_sprite_ext(spr, 0, _gw / 2 + _dx - t * 0.25 + _temblor, _cy + _temblor, _esc, _esc, 0, c_white, 1);
}
// borrar lo que queda fuera de la franja (arriba y abajo de los bordes diagonales)
gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
draw_set_color(c_black);
draw_triangle(0, 0, _gw, 0, _gw, _cy - _h2 - _incl, false);
draw_triangle(0, 0, _gw, _cy - _h2 - _incl, 0, _cy - _h2 + _incl, false);
draw_triangle(0, _gh, _gw, _gh, _gw, _cy + _h2 - _incl, false);
draw_triangle(0, _gh, _gw, _cy + _h2 - _incl, 0, _cy + _h2 + _incl, false);
gpu_set_blendmode(bm_normal);
surface_reset_target();
draw_surface(superficie, 0, 0);

// bordes dorados de la franja (entran con ella)
var _lx0 = max(0, _dx), _lx1 = min(_gw, _gw + _dx);
if (_lx1 > _lx0) {
    // altura del borde en x: baja _incl a la izquierda y sube _incl a la derecha
    var _s0 = _incl - 2 * _incl * _lx0 / _gw, _s1 = _incl - 2 * _incl * _lx1 / _gw;
    draw_set_color(color_borde);
    draw_line_width(_lx0, _cy - _h2 + _s0, _lx1, _cy - _h2 + _s1, 4);
    draw_line_width(_lx0, _cy + _h2 + _s0, _lx1, _cy + _h2 + _s1, 4);
}

// destello blanco al llegar
if (t >= entrada && t < entrada + 8) {
    draw_set_color(c_white);
    draw_set_alpha(0.6 * (1 - (t - entrada) / 8));
    draw_rectangle(0, _cy - _h2 - _incl, _gw, _cy + _h2 + _incl, false);
    draw_set_alpha(1);
}

// ===== Nombre: entra desde la izquierda un poco despues =====
var _pt = clamp((t - 10) / 16, 0, 1);
_pt = 1 - power(1 - _pt, 3);
var _tx = lerp(-_gw * 0.6, _gw * 0.06, _pt) - _gw * 1.3 * _pout;
var _ty = _cy + _h2 - 96;
draw_set_halign(fa_left);
draw_set_color(c_black);
draw_text_transformed(_tx + 4, _ty + 4, nombre, 4, 4, 0);
draw_set_color(color_borde);
draw_text_transformed(_tx, _ty, nombre, 4, 4, 0);
draw_set_color(c_black);
draw_text_transformed(_tx + 2, _ty + 58, subtitulo, 2, 2, 0);
draw_set_color(c_white);
draw_text_transformed(_tx, _ty + 56, subtitulo, 2, 2, 0);
draw_set_color(c_white);
