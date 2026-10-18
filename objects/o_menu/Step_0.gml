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
        if (sel >= 0 && (_clic || _enter)) menu_accion(botones[sel].accion);
        _resaltado = sel;
    } else {
        // Tutorial / Mejoras: boton Volver, Esc, Backspace o Enter
        volver_hover = point_in_rectangle(_mx, _my, room_width / 2 - boton_w / 2, volver_cy - boton_h / 2, room_width / 2 + boton_w / 2, volver_cy + boton_h / 2);
        var _volver = (bloqueo <= 0) && ((volver_hover && mouse_check_button_pressed(mb_left))
                      || keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace) || keyboard_check_pressed(vk_enter));
        if (_volver) { pantalla = "principal"; bloqueo = 15; }
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
