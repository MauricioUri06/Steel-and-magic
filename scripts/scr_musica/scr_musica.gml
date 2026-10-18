// ===== Musica del juego (scr_musica) =====
// Una sola cancion suena a la vez, en loop. Al cambiar de room la anterior se apaga con un fundido y la nueva sube sola.
//   musica_para_room(room)       elige la cancion segun la room (la llaman o_menu y o_player)
//   musica_volumen(mult, ms)     baja o sube el volumen (1 = normal, 0.3 = pausa, 0 = silencio); lo usa o_player
//   sfx_jingle(sonido)           suena un jingle de una sola vez (muerte, jefe vencido, victoria): la musica se calla mientras
//                                suena y vuelve sola cuando esta por terminar (sfx_jingle(snd, vol, false): no vuelve; lo usa la victoria)
//   sfx_play(sonido, vol, pitch, variacion, espera_ms)   efecto de sonido corto (ver mas abajo); los sfx_* estan en la carpeta music/sfx
// Para sumar la musica de otra room (por ejemplo un jefe): agregar su sonido en musica_para_room.
// Los sonidos se nombran directo (mus_menu, ...) y no con asset_get_index: asi GameMaker no los quita al compilar.

#macro MUSICA_VOL 0.7        // volumen base de la musica (deja espacio para los efectos de sonido)
#macro MUSICA_FADE_MS 1000   // fundido de entrada de cada cancion
#macro MUSICA_SALIDA_MS 600  // fundido de salida de la cancion anterior
#macro SFX_VOL 0.85          // volumen de los jingles (sfx_muerte, sfx_jefe, sfx_victoria)
#macro SFX_EFECTOS_VOL 0.8   // volumen general de los efectos de sonido cortos (sfx_play): disparos, golpes, cartas, botones...

// ===== Opciones de sonido (las ajusta el jugador en el boton Options del menu) =====
// global.vol_musica (musica y jingles) y global.vol_efectos (efectos cortos) van de 0 a 1 y se guardan en steel_magic_opciones.ini.
// Se multiplican por MUSICA_VOL / SFX_EFECTOS_VOL, que siguen siendo el balance interno entre musica y efectos.
// (los globales sobreviven a game_restart, asi que el ajuste se conserva al volver al menu)
function opciones_audio_inicializar() {
    if (variable_global_exists("vol_musica") && variable_global_exists("vol_efectos")) return;
    global.vol_musica = 1;
    global.vol_efectos = 1;
    ini_open("steel_magic_opciones.ini");
    global.vol_musica  = clamp(ini_read_real("sonido", "musica", 1), 0, 1);
    global.vol_efectos = clamp(ini_read_real("sonido", "efectos", 1), 0, 1);
    ini_close();
}

function opciones_audio_guardar() {
    opciones_audio_inicializar();
    ini_open("steel_magic_opciones.ini");
    ini_write_real("sonido", "musica", global.vol_musica);
    ini_write_real("sonido", "efectos", global.vol_efectos);
    ini_close();
}

// volumen base de la musica ya con el ajuste del jugador
function musica_vol() {
    opciones_audio_inicializar();
    return MUSICA_VOL * global.vol_musica;
}

// aplica en vivo el volumen de la musica que esta sonando (mientras se mueve el control en Options)
function opciones_audio_aplicar() {
    musica_inicializar();
    if (musica_sonando()) audio_sound_gain(global.musica_inst, musica_vol() * musica_mult_total(), 0);
}

function musica_inicializar() {
    if (!variable_global_exists("musica_inst")) {
        global.musica_inst = -1;   // instancia que esta sonando
        global.musica_snd  = -1;   // sonido (asset) que esta sonando
        global.musica_mult = 1;    // multiplicador actual (pausa, muerte...)
        global.musica_duck = 1;    // 0 mientras suena un jingle (la musica se calla), 1 el resto del tiempo
        global.jingle_inst = -1;   // jingle que esta sonando
        global.jingle_id   = 0;    // cuenta de jingles: solo el ultimo devuelve la musica
        global.musica_gen  = 0;    // cuenta de reinicios de la musica (ver musica_reiniciar)
    }
}

// game_restart() NO reinicia las variables globales (GameMaker las conserva). Despues de morir o de volver al menu desde la pausa
// quedaban el volumen en 0 (muerte), el "duck" en 0 (el jingle de muerte callaba la musica y el temporizador que la devolvia se pierde
// con el reinicio) y un sonido que ya no existe: la musica del menu y de los actos arrancaba muda. Esto lo deja todo como recien abierto.
// Se llama justo antes de game_restart (o_player) y al abrir el menu (o_menu).
function musica_reiniciar() {
    musica_inicializar();
    if (global.musica_inst != -1) audio_stop_sound(global.musica_inst);
    if (global.jingle_inst != -1) audio_stop_sound(global.jingle_inst);
    global.musica_inst = -1;
    global.musica_snd  = -1;
    global.musica_mult = 1;
    global.musica_duck = 1;
    global.jingle_inst = -1;
    global.jingle_id  += 1;   // los temporizadores de jingles anteriores ya no devuelven nada
    global.musica_gen += 1;   // ni los que detienen una cancion que se apagaba
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
        call_later((MUSICA_SALIDA_MS + 100) / 1000, time_source_units_seconds, method({ inst: global.musica_inst, gen: global.musica_gen }, function() {
            if (variable_global_exists("musica_gen") && global.musica_gen == gen) audio_stop_sound(inst);
        }));
    }
    global.musica_snd  = _snd;
    global.musica_inst = -1;
    if (_snd == -1) return;
    global.musica_inst = audio_play_sound(_snd, 100, true);
    audio_sound_gain(global.musica_inst, 0, 0);
    audio_sound_gain(global.musica_inst, musica_vol() * musica_mult_total(), MUSICA_FADE_MS);
}

function musica_volumen(_mult, _ms = 250) {
    musica_inicializar();
    if (_mult == global.musica_mult) return;
    global.musica_mult = _mult;
    if (musica_sonando()) audio_sound_gain(global.musica_inst, musica_vol() * musica_mult_total(), _ms);
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
    if (musica_sonando()) audio_sound_gain(global.musica_inst, musica_vol() * musica_mult_total(), _ms);
}

// Jingle de una sola vez. Si llega otro mientras suena uno, el nuevo lo reemplaza.
// La musica se calla y vuelve (en 1.5 s) cuando faltan 1.5 s para que termine, mientras se apaga su reverb.
// Si la musica de una room nueva empieza durante el jingle (cambio de acto), arranca callada y sube sola al terminar.
// _vuelve_musica = false (la victoria final): la musica del acto se apaga con un fundido y NO vuelve (hasta reiniciar el juego).
function sfx_jingle(_snd, _vol = SFX_VOL, _vuelve_musica = true) {
    musica_inicializar();
    if (global.jingle_inst != -1) audio_stop_sound(global.jingle_inst);
    global.jingle_id += 1;
    global.jingle_inst = audio_play_sound(_snd, 200, false);
    opciones_audio_inicializar();
    audio_sound_gain(global.jingle_inst, _vol * global.vol_musica, 0);
    musica_duck(0, 300);
    if (!_vuelve_musica) {
        musica_cambiar(-1);   // fundido de salida y se detiene; el duck queda en 0, asi que ni una room nueva la hace sonar
        return;
    }
    var _seg = max(1, audio_sound_length(_snd) - 1.5);
    call_later(_seg, time_source_units_seconds, method({ id_jingle: global.jingle_id }, function() {
        if (variable_global_exists("jingle_id") && global.jingle_id == id_jingle) musica_duck(1, 1500);   // (tras un game_restart los globales empiezan de cero)
    }));
}

// Efecto de sonido corto (disparo, golpe, boton...). No toca la musica.
//   _vol       0..1, relativo a SFX_EFECTOS_VOL (los sonidos ya vienen balanceados entre si; esto afina uno en un lugar concreto)
//   _pitch     1 = normal | _var: variacion aleatoria del pitch (0.05 = +-5%), para que no suene igual cada vez
//   _espera_ms tiempo minimo entre dos veces el mismo sonido (evita que se amontonen con las balas y los golpes)
// Devuelve la instancia que suena (para cortarla con audio_stop_sound) o -1 si no sono por la espera.
function sfx_play(_snd, _vol = 1, _pitch = 1, _var = 0, _espera_ms = 0) {
    if (_espera_ms > 0) {
        if (!variable_global_exists("sfx_ultimo")) global.sfx_ultimo = {};
        var _k = string(_snd);
        if (variable_struct_exists(global.sfx_ultimo, _k) && current_time - global.sfx_ultimo[$ _k] < _espera_ms) return -1;
        global.sfx_ultimo[$ _k] = current_time;
    }
    var _inst = audio_play_sound(_snd, 50, false);
    opciones_audio_inicializar();
    audio_sound_gain(_inst, SFX_EFECTOS_VOL * global.vol_efectos * _vol, 0);
    var _p = _pitch * (1 + random_range(-_var, _var));
    if (_p != 1) audio_sound_pitch(_inst, _p);
    return _inst;
}
