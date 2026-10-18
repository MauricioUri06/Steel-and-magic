// ===== Musica del juego (scr_musica) =====
// Una sola cancion suena a la vez, en loop. Al cambiar de room la anterior se apaga con un fundido y la nueva sube sola.
//   musica_para_room(room)       elige la cancion segun la room (la llaman o_menu y o_player)
//   musica_volumen(mult, ms)     baja o sube el volumen (1 = normal, 0.3 = pausa, 0 = silencio); lo usa o_player
//   sfx_jingle(sonido)           suena un jingle de una sola vez (muerte, jefe vencido, victoria): la musica se calla mientras
//                                suena y vuelve sola cuando esta por terminar
// Para sumar la musica de otra room (por ejemplo un jefe): agregar su sonido en musica_para_room.
// Los sonidos se nombran directo (mus_menu, ...) y no con asset_get_index: asi GameMaker no los quita al compilar.

#macro MUSICA_VOL 0.7        // volumen base de la musica (deja espacio para los efectos de sonido)
#macro MUSICA_FADE_MS 1000   // fundido de entrada de cada cancion
#macro MUSICA_SALIDA_MS 600  // fundido de salida de la cancion anterior
#macro SFX_VOL 0.85          // volumen de los jingles (sfx_muerte, sfx_jefe, sfx_victoria)

function musica_inicializar() {
    if (!variable_global_exists("musica_inst")) {
        global.musica_inst = -1;   // instancia que esta sonando
        global.musica_snd  = -1;   // sonido (asset) que esta sonando
        global.musica_mult = 1;    // multiplicador actual (pausa, muerte...)
        global.musica_duck = 1;    // 0 mientras suena un jingle (la musica se calla), 1 el resto del tiempo
        global.jingle_inst = -1;   // jingle que esta sonando
        global.jingle_id   = 0;    // cuenta de jingles: solo el ultimo devuelve la musica
    }
}

function musica_sonando() {
    musica_inicializar();
    return (global.musica_inst != -1 && audio_is_playing(global.musica_inst));
}

function musica_para_room(_room) {
    var _snd = -1;
    if (_room == rm_menu)                   _snd = mus_menu;
    else if (_room == rm_acto_1_ruinas)     _snd = mus_acto1;
    else if (_room == rm_acto_2_oxidado)    _snd = mus_acto2;
    else if (_room == rm_acto_3_fortaleza)  _snd = mus_acto3;
    musica_cambiar(_snd);
}

function musica_cambiar(_snd) {
    musica_inicializar();
    if (_snd == global.musica_snd && musica_sonando()) return;   // ya suena esa
    // la anterior se apaga con un fundido y despues se detiene
    if (musica_sonando()) {
        audio_sound_gain(global.musica_inst, 0, MUSICA_SALIDA_MS);
        call_later((MUSICA_SALIDA_MS + 100) / 1000, time_source_units_seconds, method({ inst: global.musica_inst }, function() {
            audio_stop_sound(inst);
        }));
    }
    global.musica_snd  = _snd;
    global.musica_inst = -1;
    if (_snd == -1) return;
    global.musica_inst = audio_play_sound(_snd, 100, true);
    audio_sound_gain(global.musica_inst, 0, 0);
    audio_sound_gain(global.musica_inst, MUSICA_VOL * musica_mult_total(), MUSICA_FADE_MS);
}

function musica_volumen(_mult, _ms = 250) {
    musica_inicializar();
    if (_mult == global.musica_mult) return;
    global.musica_mult = _mult;
    if (musica_sonando()) audio_sound_gain(global.musica_inst, MUSICA_VOL * musica_mult_total(), _ms);
}

// volumen real de la musica = (pausa, muerte...) x (jingle)
function musica_mult_total() {
    musica_inicializar();
    return global.musica_mult * global.musica_duck;
}

// calla (0) o devuelve (1) la musica por culpa de un jingle; sin cambiar el multiplicador de la pausa o la muerte
function musica_duck(_mult, _ms = 300) {
    musica_inicializar();
    global.musica_duck = _mult;
    if (musica_sonando()) audio_sound_gain(global.musica_inst, MUSICA_VOL * musica_mult_total(), _ms);
}

// Jingle de una sola vez. Si llega otro mientras suena uno, el nuevo lo reemplaza.
// La musica se calla y vuelve (en 1.5 s) cuando faltan 1.5 s para que termine, mientras se apaga su reverb.
// Si la musica de una room nueva empieza durante el jingle (cambio de acto), arranca callada y sube sola al terminar.
function sfx_jingle(_snd, _vol = SFX_VOL) {
    musica_inicializar();
    if (global.jingle_inst != -1) audio_stop_sound(global.jingle_inst);
    global.jingle_id += 1;
    global.jingle_inst = audio_play_sound(_snd, 200, false);
    audio_sound_gain(global.jingle_inst, _vol, 0);
    musica_duck(0, 300);
    var _seg = max(1, audio_sound_length(_snd) - 1.5);
    call_later(_seg, time_source_units_seconds, method({ id_jingle: global.jingle_id }, function() {
        if (variable_global_exists("jingle_id") && global.jingle_id == id_jingle) musica_duck(1, 1500);   // (tras un game_restart los globales empiezan de cero)
    }));
}
