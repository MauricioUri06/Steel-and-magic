// Con sprites si el enemigo los tiene (spr_por_estado); si no, formas simples provisionales.
var _alpha = ((estado == "muerto") ? timer / dur_muerto : 1) * alpha_cuerpo;   // el cadaver se desvanece
var _top   = y - radio;   // donde va la barra de vida

if (es_enemigo) dibujar_suelo();

var _spr = buscar_sprite();
if (_spr != -1) {
    if (_spr != spr_actual) { spr_actual = _spr; anim = 0; }
    else anim += anim_vel;
    // la caida, el cadaver y la recuperacion no hacen bucle: se quedan en el ultimo cuadro
    var _n = sprite_get_number(_spr);
    var _img = (estado == "cayendo" || estado == "muerto" || estado == "recuperar") ? min(anim, _n - 1) : anim mod _n;
    draw_sprite_ext(_spr, _img, x, y, lado * escala_sprite, escala_sprite, 0, c_white, _alpha);
    if (flash > 0) {
        // destello blanco al recibir dano
        gpu_set_fog(true, c_white, 0, 1);
        draw_sprite_ext(_spr, _img, x, y, lado * escala_sprite, escala_sprite, 0, c_white, 0.8 * _alpha);
        gpu_set_fog(false, c_white, 0, 0);
    }
    _top = y - sprite_get_yoffset(_spr) * escala_sprite;
} else {
    draw_set_alpha(_alpha);
    draw_set_color((flash > 0) ? c_white : (es_enemigo ? color : merge_colour(color, c_black, 0.5)));
    draw_circle(x, y, radio, false);
    draw_set_color(c_black);
    draw_circle(x, y, radio, true);
    // "ojo" para ver hacia donde mira
    draw_circle(x + lengthdir_x(radio * 0.6, dir_mira), y + lengthdir_y(radio * 0.6, dir_mira), 2, false);
    draw_set_alpha(1);
}

if (!es_enemigo) exit;   // muriendo: sin avisos ni barra de vida

dibujar_extra();

// barra de vida (solo si esta herido)
if (barra_vida && hp < hp_max) {
    var _w = radio * 2;
    var _bx = x - radio, _by = _top - 6;
    draw_set_color(c_black);
    draw_rectangle(_bx - 1, _by - 1, _bx + _w + 1, _by + 4, false);
    draw_set_color(c_red);
    draw_rectangle(_bx, _by, _bx + _w * max(hp, 0) / hp_max, _by + 3, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
