fondo_t += 1;
if (bloqueo > 0) bloqueo -= 1;

// ===== Fundido: entra desde negro; al elegir Empezar / Salir se oscurece antes de cambiar =====
if (fade_saliendo) {
    fade = min(1, fade + fade_vel);
    if (fade >= 1 && !cambiando) {
        cambiando = true;
        if (accion_pendiente == "empezar") {
            // o_player lee esto al nacer en el nivel y hace aparecer la pantalla desde negro en 2 s
            global.entrada_negro = true;
            room_goto(room_inicio);
        } else if (accion_pendiente == "salir") {
            game_end();
        }
    }
} else {
    fade = max(0, fade - 0.04);
}

// ===== Entrada =====
var _n = array_length(botones);
var _mx = mouse_x, _my = mouse_y;
if (_mx != mx_prev || _my != my_prev) modo_mouse = true;
mx_prev = _mx;
my_prev = _my;

var _resaltado = -1;      // boton que se ve mecanico
volver_hover = false;

if (!fade_saliendo) {
    if (pantalla == "principal") {
        // boton bajo el cursor
        var _bajo = -1;
        for (var _i = 0; _i < _n; _i++) {
            var _cy = boton_y0 + _i * (boton_h + boton_sep) + boton_h / 2;
            if (point_in_rectangle(_mx, _my, room_width / 2 - boton_w / 2, _cy - boton_h / 2, room_width / 2 + boton_w / 2, _cy + boton_h / 2)) _bajo = _i;
        }
        // teclado: W/S o flechas
        var _abajo  = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
        var _arriba = keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"));
        if (_abajo || _arriba) {
            modo_mouse = false;
            if (sel < 0) sel = _abajo ? 0 : _n - 1;
            else sel = (sel + (_abajo ? 1 : -1) + _n) mod _n;
        }
        if (modo_mouse) sel = _bajo;    // con el mouse solo se resalta lo que esta debajo del cursor

        var _clic = (bloqueo <= 0) && mouse_check_button_pressed(mb_left) && _bajo >= 0;
        var _enter = (bloqueo <= 0) && (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space));
        if (_clic) sel = _bajo;
        if (sel != sel_snd) {
            if (sel >= 0) sfx_play(sfx_boton_hover);
            sel_snd = sel;
        }
        if (sel >= 0 && (_clic || _enter)) {
            sfx_play(sfx_boton_clic);
            menu_accion(botones[sel].accion);
        }
        _resaltado = sel;
    } else if (pantalla == "tutorial") {
        // Tutorial: scroll con la rueda del mouse, flechas arriba/abajo, W/S o RePag/AvPag
        var _paso = (mouse_wheel_down() - mouse_wheel_up()) * 40;
        if (keyboard_check(vk_down) || keyboard_check(ord("S"))) _paso += 7;
        if (keyboard_check(vk_up)   || keyboard_check(ord("W"))) _paso -= 7;
        if (keyboard_check_pressed(vk_pagedown)) _paso += 300;
        if (keyboard_check_pressed(vk_pageup))   _paso -= 300;
        tut_scroll_obj = clamp(tut_scroll_obj + _paso, 0, tut_max);
        tut_scroll += (tut_scroll_obj - tut_scroll) * 0.35;
        // Tutorial: boton Volver, Esc, Backspace o Enter
        volver_hover = point_in_rectangle(_mx, _my, room_width / 2 - boton_w / 2, volver_cy - boton_h / 2, room_width / 2 + boton_w / 2, volver_cy + boton_h / 2);
        var _volver = (bloqueo <= 0) && ((volver_hover && mouse_check_button_pressed(mb_left))
                      || keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace) || keyboard_check_pressed(vk_enter));
        if (_volver) { sfx_play(sfx_boton_clic); pantalla = "principal"; bloqueo = 15; }
    } else if (pantalla == "mejoras") {
        // Mejoras permanentes: entrada directa, sin crear ni pausar instancias.
        var _mu = min(room_width / 1280, room_height / 720);
        var _mpx = (room_width - 960 * _mu) * 0.5;
        var _mpy = (room_height - 480 * _mu) * 0.5;
        var _mfx = _mpx + 110 * _mu;
        var _mfy = _mpy + 88 * _mu;

        meta_fila_hover = -1;
        for (var _mi = 0; _mi < array_length(global.meta_progreso.mejoras); _mi++) {
            var _mby = _mfy + _mi * 40 * _mu + 4 * _mu;
            var _mbx = _mfx + 625 * _mu;
            if (point_in_rectangle(_mx, _my, _mbx, _mby, _mbx + 102 * _mu, _mby + 32 * _mu)) meta_fila_hover = _mi;
        }

        if (meta_fila_hover != meta_hover_snd) {
            if (meta_fila_hover >= 0) sfx_play(sfx_boton_hover);
            meta_hover_snd = meta_fila_hover;
        }

        var _mvx = room_width * 0.5 - 116 * _mu;
        var _mvy = _mpy + 432 * _mu;
        meta_volver_hover = point_in_rectangle(_mx, _my, _mvx, _mvy, _mvx + 232 * _mu, _mvy + 36 * _mu);
        volver_hover = meta_volver_hover;

        if (bloqueo <= 0 && mouse_check_button_pressed(mb_left)) {
            if (meta_fila_hover >= 0) {
                if (meta_comprar_mejora(meta_fila_hover)) sfx_play(sfx_compra);
                else sfx_play(sfx_error);   // no alcanzan las monedas o ya esta al maximo
            }
            else if (meta_volver_hover) { sfx_play(sfx_boton_clic); pantalla = "principal"; bloqueo = 15; }
        }
        if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace)) {
            pantalla = "principal";
            bloqueo = 15;
        }
    }
}

// ===== Animacion de los botones: dorado <-> mecanico =====
for (var _j = 0; _j < _n; _j++) {
    var _b = botones[_j];
    var _meta = (pantalla == "principal" && _j == _resaltado) ? frames_boton - 1 : 0;
    _b.frame += clamp(_meta - _b.frame, -anim_vel, anim_vel);
}
var _meta_v = (pantalla != "principal" && volver_hover) ? frames_boton - 1 : 0;
volver_frame += clamp(_meta_v - volver_frame, -anim_vel, anim_vel);
