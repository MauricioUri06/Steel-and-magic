// Avisos con aspecto "del mundo" (sombras, suelo caliente), sin marcas rojas.
var _p = 1 - timer / max(1, aviso);   // 0..1 durante el aviso

switch (fase) {
    case "aviso":
        if (estilo == "sombra") {
            // sombra ovalada que crece y se oscurece mientras el objeto cae
            draw_set_color(c_black);
            draw_set_alpha(0.15 + 0.4 * _p);
            var _r = radio * (0.3 + 0.7 * _p);
            draw_ellipse(x - _r, y - _r * 0.6, x + _r, y + _r * 0.6, false);
        } else {
            // suelo que se calienta: mancha oscura y brasas que aparecen
            draw_set_color(make_colour_rgb(40, 20, 10));
            draw_set_alpha(0.25 + 0.35 * _p);
            draw_ellipse(x - radio, y - radio * 0.6, x + radio, y + radio * 0.6, false);
            // posiciones fijas por zona (sin random(), para no tocar el azar del resto del juego)
            draw_set_color(make_colour_rgb(255, 140, 40));
            for (var _i = 0; _i < 10; _i++) {
                var _a = (semilla + _i * 137.5) mod 360;
                var _d = radio * 0.9 * ((semilla + _i * 7919) mod 100) / 100;
                if (((semilla + _i * 31) mod 100) / 100 < _p) {
                    var _bx = x + lengthdir_x(_d, _a), _by = y + lengthdir_y(_d, _a) * 0.6;
                    draw_rectangle(_bx, _by, _bx + 1, _by + 1, false);
                }
            }
        }
        break;

    case "impacto":
        // explosion: circulo claro que se desvanece
        var _q = timer / dur_impacto;
        draw_set_alpha(_q);
        draw_set_color((estilo == "fuego") ? make_colour_rgb(255, 120, 30) : make_colour_rgb(255, 220, 160));
        draw_circle(x, y, radio * (1.1 - 0.3 * _q), false);
        draw_set_color(c_white);
        draw_circle(x, y, radio * 0.5 * _q, false);
        break;

    case "ardiendo":
        // fuego que queda: llamitas que parpadean, se apaga al final
        var _vida = min(1, timer / 30);
        draw_set_alpha(0.35 * _vida);
        draw_set_color(make_colour_rgb(60, 20, 5));
        draw_ellipse(x - radio, y - radio * 0.6, x + radio, y + radio * 0.6, false);
        var _colores = [make_colour_rgb(255, 90, 20), make_colour_rgb(255, 170, 40), make_colour_rgb(255, 230, 120)];
        var _k = current_time div 120;   // cambia ~8 veces por segundo: parpadeo
        draw_set_alpha(0.8 * _vida);
        for (var _i = 0; _i < 8; _i++) {
            var _a = (semilla + _i * 137.5 + _k * 53) mod 360;
            var _d = radio * 0.8 * ((semilla + _i * 7919 + _k * 13) mod 100) / 100;
            var _h = 3 + ((_i * 17 + _k * 29) mod 5);
            var _fx = x + lengthdir_x(_d, _a), _fy = y + lengthdir_y(_d, _a) * 0.6;
            draw_set_color(_colores[(_i + _k) mod 3]);
            draw_triangle(_fx - 2, _fy, _fx + 2, _fy, _fx, _fy - _h, false);
        }
        break;
}
draw_set_alpha(1);
draw_set_color(c_white);
