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
<<<<<<< HEAD
opt_hover = false;
=======
meta_reset_hover = false;
meta_confirm_cancel_hover = false;
meta_confirm_reset_hover = false;
>>>>>>> bc5c0fb533b438faed69e713ba8fe290103d4506

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
        // boton Options (arriba a la izquierda)
        opt_hover = point_in_rectangle(_mx, _my, opt_x, opt_y, opt_x + opt_w, opt_y + opt_h);
        if (opt_hover != opt_hover_snd) {
            if (opt_hover) sfx_play(sfx_boton_hover);
            opt_hover_snd = opt_hover;
        }
        if (opt_hover && bloqueo <= 0 && mouse_check_button_pressed(mb_left)) {
            sfx_play(sfx_boton_clic);
            menu_accion("opciones");
        }
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
    } else if (pantalla == "opciones") {
        // Opciones de sonido: arrastrar la barra con el mouse, o W/S para elegir y A/D (o flechas) para cambiar
        var _on = array_length(opt_sliders);
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) opt_sel = (opt_sel + 1) mod _on;
        if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) opt_sel = (opt_sel - 1 + _on) mod _on;
        var _odx = (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) - (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")));
        if (_odx != 0) {
            opt_set(opt_sel, round((opt_get(opt_sel) + _odx * 0.05) * 20) / 20);
            opciones_audio_guardar();
            if (opt_sel == 1) sfx_play(sfx_boton_clic);   // para oir el nivel de los efectos
        }
        if (bloqueo <= 0 && mouse_check_button_pressed(mb_left)) {
            for (var _oi = 0; _oi < _on; _oi++) {
                var _ocy = opt_fila_y0 + _oi * opt_fila_sep;
                if (point_in_rectangle(_mx, _my, opt_pista_x - 14, _ocy - 22, opt_pista_x + opt_pista_w + 14, _ocy + 22)) { opt_arrastre = _oi; opt_sel = _oi; }
            }
        }
        if (opt_arrastre >= 0) {
            if (mouse_check_button(mb_left)) {
                var _ov = clamp(round((_mx - opt_pista_x) / opt_pista_w * 100) / 100, 0, 1);
                if (_ov != opt_get(opt_arrastre)) opt_set(opt_arrastre, _ov);
            } else {
                opciones_audio_guardar();
                if (opt_arrastre == 1) sfx_play(sfx_boton_clic);   // para oir el nivel de los efectos
                opt_arrastre = -1;
            }
        }
        // boton Volver, Esc, Backspace o Enter
        volver_hover = point_in_rectangle(_mx, _my, room_width / 2 - boton_w / 2, volver_cy - boton_h / 2, room_width / 2 + boton_w / 2, volver_cy + boton_h / 2);
        var _ovolver = (bloqueo <= 0) && ((volver_hover && mouse_check_button_pressed(mb_left))
                       || keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace) || keyboard_check_pressed(vk_enter));
        if (_ovolver) { opciones_audio_guardar(); opt_arrastre = -1; sfx_play(sfx_boton_clic); pantalla = "principal"; bloqueo = 15; }
    } else if (pantalla == "mejoras") {
        // Mejoras permanentes: entrada directa, sin crear ni pausar instancias.
        var _mu = min(room_width / 1280, room_height / 720);
        var _mpx = (room_width - 960 * _mu) * 0.5;
        var _mpy = (room_height - 480 * _mu) * 0.5;
        var _mfx = _mpx + 110 * _mu;
        var _mfy = _mpy + 88 * _mu;

        meta_fila_hover = -1;
        if (meta_confirmacion_abierta) {
            // La advertencia es modal: nada de la lista puede pulsarse mientras esta abierta.
            var _ccx = room_width * 0.5 - 145 * _mu;
            var _crx = room_width * 0.5 + 145 * _mu;
            var _cby = room_height * 0.5 + 92 * _mu;
            var _cbw = 240 * _mu, _cbh = 64 * _mu;
            meta_confirm_cancel_hover = point_in_rectangle(_mx, _my, _ccx - _cbw * 0.5, _cby - _cbh * 0.5, _ccx + _cbw * 0.5, _cby + _cbh * 0.5);
            meta_confirm_reset_hover = point_in_rectangle(_mx, _my, _crx - _cbw * 0.5, _cby - _cbh * 0.5, _crx + _cbw * 0.5, _cby + _cbh * 0.5);

            if (meta_confirm_cancel_hover) meta_confirmacion_sel = 0;
            if (meta_confirm_reset_hover) meta_confirmacion_sel = 1;
            if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) meta_confirmacion_sel = 0;
            if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) meta_confirmacion_sel = 1;

            var _cancelar = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace)
                         || (meta_confirm_cancel_hover && mouse_check_button_pressed(mb_left));
            var _confirmar = (meta_confirm_reset_hover && mouse_check_button_pressed(mb_left))
                          || ((keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) && meta_confirmacion_sel == 1);
            if (_cancelar || ((keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) && meta_confirmacion_sel == 0)) {
                sfx_play(sfx_boton_clic);
                meta_confirmacion_abierta = false;
                bloqueo = 10;
            }
            else if (_confirmar) {
                meta_reiniciar_mejoras();
                sfx_play(sfx_compra);
                meta_confirmacion_abierta = false;
                bloqueo = 15;
            }
        }
        else {
            for (var _mi = 0; _mi < array_length(global.meta_progreso.mejoras); _mi++) {
                var _mby = _mfy + _mi * 40 * _mu + 4 * _mu;
                var _mbx = _mfx + 625 * _mu;
                if (point_in_rectangle(_mx, _my, _mbx, _mby, _mbx + 102 * _mu, _mby + 32 * _mu)) meta_fila_hover = _mi;
            }

            if (meta_fila_hover != meta_hover_snd) {
                if (meta_fila_hover >= 0) sfx_play(sfx_boton_hover);
                meta_hover_snd = meta_fila_hover;
            }

            var _mvy = _mpy + 432 * _mu;
            var _mrx = room_width * 0.5 - 250 * _mu;
            var _mvx = room_width * 0.5 + 30 * _mu;
            meta_reset_hover = point_in_rectangle(_mx, _my, _mrx, _mvy, _mrx + 220 * _mu, _mvy + 36 * _mu);
            meta_volver_hover = point_in_rectangle(_mx, _my, _mvx, _mvy, _mvx + 220 * _mu, _mvy + 36 * _mu);
            volver_hover = meta_volver_hover;

            if (bloqueo <= 0 && mouse_check_button_pressed(mb_left)) {
                if (meta_fila_hover >= 0) {
                    if (meta_comprar_mejora(meta_fila_hover)) sfx_play(sfx_compra);
                    else sfx_play(sfx_error);   // no alcanzan las monedas o ya esta al maximo
                }
                else if (meta_reset_hover) {
                    sfx_play(sfx_boton_clic);
                    meta_confirmacion_abierta = true;
                    meta_confirmacion_sel = 0;
                }
                else if (meta_volver_hover) { sfx_play(sfx_boton_clic); pantalla = "principal"; bloqueo = 15; }
            }
            if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace)) {
                pantalla = "principal";
                bloqueo = 15;
            }
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
var _meta_o = (pantalla == "principal" && opt_hover) ? frames_boton - 1 : 0;
opt_frame += clamp(_meta_o - opt_frame, -anim_vel, anim_vel);
