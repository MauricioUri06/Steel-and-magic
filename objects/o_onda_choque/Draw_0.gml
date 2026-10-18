// anillo de polvo/energia que se va desvaneciendo al crecer (achatado como el suelo)
var _vida = 1 - radio / radio_max;
draw_set_color(color);
for (var _i = 0; _i < 3; _i++) {
    var _r = radio - _i * 4;
    if (_r <= 0) continue;
    draw_set_alpha(_vida * (0.8 - _i * 0.25));
    draw_ellipse(x - _r, y - _r * 0.6, x + _r, y + _r * 0.6, true);
}
draw_set_alpha(1);
draw_set_color(c_white);
