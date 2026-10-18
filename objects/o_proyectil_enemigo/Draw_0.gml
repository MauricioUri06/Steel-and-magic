if (estilo == "llama") {
    // llamita: estela de circulos que se achican y se desvanecen hacia atras, con un temblor lateral
    var _t = (current_time / 60) + parpadeo_ofs * 2;
    var _atras = direccion + 180;
    for (var _i = 4; _i >= 1; _i--) {
        var _d = radio * 1.1 * _i;
        var _lado = sin(_t + _i * 1.7) * radio * 0.35 * _i / 4;   // la cola se mueve como una llama
        var _cx = x + lengthdir_x(_d, _atras) + lengthdir_x(_lado, direccion + 90);
        var _cy = y + lengthdir_y(_d, _atras) + lengthdir_y(_lado, direccion + 90);
        draw_set_alpha(0.75 - _i * 0.15);
        draw_set_color(color);
        draw_circle(_cx, _cy, radio * (1 - _i * 0.18), false);
    }
    draw_set_alpha(0.9);
    draw_set_color(color);
    draw_circle(x, y, radio, false);
    draw_set_color(merge_colour(color, c_white, 0.6));
    draw_circle(x, y, radio * 0.7, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_circle(x, y, radio * 0.4, false);
    exit;
}
draw_set_color(color);
draw_circle(x, y, radio, false);
draw_set_color(c_white);
draw_circle(x, y, radio * 0.5, false);
