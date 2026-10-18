// rombo dorado (mismo color que la barra de XP) que flota y brilla
var _fy = y - 3 + sin(degtorad(fase)) * 2;
var _r = radio;
draw_set_alpha(0.35);
draw_set_color(make_colour_rgb(255, 214, 102));
draw_circle(x, _fy, _r + 3, false);   // brillo
draw_set_alpha(1);
draw_set_color(make_colour_rgb(200, 140, 30));
draw_triangle(x, _fy - _r - 1, x - _r - 1, _fy, x + _r + 1, _fy, false);
draw_triangle(x, _fy + _r + 1, x - _r - 1, _fy, x + _r + 1, _fy, false);
draw_set_color(make_colour_rgb(255, 214, 102));
draw_triangle(x, _fy - _r, x - _r, _fy, x + _r, _fy, false);
draw_triangle(x, _fy + _r, x - _r, _fy, x + _r, _fy, false);
draw_set_color(c_white);
draw_circle(x - _r * 0.3, _fy - _r * 0.3, max(1, _r * 0.25), false);
