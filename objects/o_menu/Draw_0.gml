gpu_set_texfilter(false);   // sin suavizado: pixel art nitido
draw_set_alpha(1);
draw_set_color(c_white);

// ===== Fondo: cielo fijo + 3 capas que se desplazan a distinta velocidad =====
draw_sprite_ext(s_menu_cielo, 0, 0, 0, fondo_esc, fondo_esc, 0, c_white, 1);
for (var _i = 0; _i < array_length(capas); _i++) {
    var _c = capas[_i];
    var _w = sprite_get_width(_c.spr) * fondo_esc;
    var _off = (fondo_t * _c.vel) mod _w;
    draw_sprite_ext(_c.spr, 0, -_off,      0, fondo_esc, fondo_esc, 0, c_white, 1);
    draw_sprite_ext(_c.spr, 0, _w - _off,  0, fondo_esc, fondo_esc, 0, c_white, 1);
}

if (pantalla == "principal") {
    // ----- titulo -----
    var _bob = sin(fondo_t * 0.03) * 4;
    if (spr_titulo != -1) {
        var _ts = min(2, 210 / sprite_get_height(spr_titulo), 1100 / sprite_get_width(spr_titulo));
        var _tw = sprite_get_width(spr_titulo), _th = sprite_get_height(spr_titulo);
        draw_sprite_ext(spr_titulo, 0,
            room_width / 2 + (sprite_get_xoffset(spr_titulo) - _tw / 2) * _ts,
            125 + _bob + (sprite_get_yoffset(spr_titulo) - _th / 2) * _ts, _ts, _ts, 0, c_white, 1);
    } else {
        draw_set_font(fuente_titulo);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        var _a = "STEEL", _b2 = " & ", _c2 = "MAGIC";
        var _wa = string_width(_a), _wb = string_width(_b2), _wc = string_width(_c2);
        var _x0 = room_width / 2 - (_wa + _wb + _wc) / 2;
        var _ty = 125 + _bob;
        var _acero1 = make_colour_rgb(225, 242, 252), _acero2 = make_colour_rgb(100, 135, 165);
        var _oro1 = make_colour_rgb(255, 236, 150);
        draw_text_colour(_x0 + 4, _ty + 4, _a + _b2 + _c2, c_black, c_black, c_black, c_black, 0.7);
        draw_text_colour(_x0, _ty, _a, _acero1, _acero1, _acero2, _acero2, 1);
        draw_text_colour(_x0 + _wa, _ty, _b2, c_white, c_white, col_cian, col_cian, 1);
        draw_text_colour(_x0 + _wa + _wb, _ty, _c2, _oro1, _oro1, col_oro_osc, col_oro_osc, 1);
    }

    // ----- botones -----
    for (var _j = 0; _j < array_length(botones); _j++) {
        var _bt = botones[_j];
        var _cy = boton_y0 + _j * (boton_h + boton_sep) + boton_h / 2;
        dibujar_boton(room_width / 2, _cy, _bt.frame, _bt.spr_texto);
    }
}
else if (pantalla == "tutorial") {
    dibujar_panel("Tutorial");
    var _filas = [
        ["W A S D / Flechas", "Moverte"],
        ["Mouse",             "Apuntar"],
        ["Clic izquierdo",    "Atacar (mantenlo para seguir atacando)"],
        ["Rueda del mouse",   "Cambiar de clase: Caballero, Mago o Soldado"],
        ["Espacio",           "Dash: esquiva y hace daño a quien atraviesas"]
    ];
    draw_set_font(fuente_texto);
    draw_set_valign(fa_middle);
    for (var _r = 0; _r < array_length(_filas); _r++) {
        var _y = 185 + _r * 44;
        draw_set_halign(fa_left);
        draw_text_colour(200, _y, _filas[_r][0], col_cian, col_cian, col_cian, col_cian, 1);
        draw_text_colour(470, _y, _filas[_r][1], col_texto, col_texto, col_texto, col_texto, 1);
    }
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text_ext_colour(room_width / 2, 415, "Mago: mantén el clic para cargar la bola de fuego. Mientras más la cargues, más grande, más daño y más fuego deja en el suelo.", 30, 860, col_oro, col_oro, col_oro, col_oro, 1);
    draw_text_ext_colour(room_width / 2, 485, "Sobrevive a las oleadas, derrota enemigos y gana monedas para mejorar a tu héroe.", 30, 860, col_texto, col_texto, col_texto, col_texto, 1);
    dibujar_boton(room_width / 2, volver_cy, volver_frame, volver_spr);
}
else if (pantalla == "mejoras") {
    dibujar_panel("Mejoras");
    draw_set_font(fuente_texto);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text_ext_colour(room_width / 2, 215, "Aquí vas a gastar las monedas que ganes en mejoras permanentes para tus héroes.", 30, 860, col_texto, col_texto, col_texto, col_texto, 1);
    draw_set_font(fuente_boton);
    draw_text_colour(room_width / 2, 330, "Próximamente", col_oro, col_oro, col_oro_osc, col_oro_osc, 1);
    dibujar_boton(room_width / 2, volver_cy, volver_frame, volver_spr);
}

// ===== Fundido =====
if (fade > 0) {
    draw_set_color(c_black);
    draw_set_alpha(fade);
    draw_rectangle(0, 0, room_width, room_height, false);
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
