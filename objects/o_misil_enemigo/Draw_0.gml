if (explotando > 0) {
    draw_set_alpha(explotando / dur_explosion);
    draw_set_color(c_orange);
    draw_circle(x, y, area, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    exit;
}
// cuerpo del misil: linea en la direccion de vuelo + punta
draw_set_color(c_dkgray);
draw_line_width(x, y, x - lengthdir_x(12, direccion), y - lengthdir_y(12, direccion), 4);
draw_set_color(color);
draw_circle(x, y, radio * 0.6, false);
draw_set_color(c_white);
