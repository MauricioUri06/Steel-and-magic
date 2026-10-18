// ===== Menu principal de Steel & Magic =====
// Pantallas: "principal", "tutorial", "mejoras". Se maneja con el mouse o con teclado (W/S o flechas + Enter, Esc para volver).

global.pausa = false;       // por si se vuelve aqui desde la pausa de un nivel
pantalla = "principal";
room_inicio = rm_acto_1_ruinas;   // room a la que va el boton Empezar
meta_inicializar();
musica_reiniciar();       // deja la musica como recien abierta (los globales sobreviven a game_restart; ver scr_musica)
musica_para_room(room);   // suena mus_menu (ver scr_musica)
meta_fila_hover = -1;
meta_volver_hover = false;
meta_reset_hover = false;
meta_confirmacion_abierta = false;
meta_confirmacion_sel = 0;       // 0 = cancelar, 1 = reiniciar
meta_confirm_cancel_hover = false;
meta_confirm_reset_hover = false;

// --- estado ---
sel = -1;                 // boton seleccionado (-1 = ninguno)
sel_snd = -1;             // ultimo boton que ya hizo sonido de hover
meta_hover_snd = -1;      // idem para las filas de la pantalla Mejoras
modo_mouse = true;        // true: manda el cursor; false: mandan las teclas
mx_prev = mouse_x;
my_prev = mouse_y;
bloqueo = 0;              // pasos en los que se ignoran los clics (evita doble clic al cambiar de pantalla)
fade = 1;                 // 1 = negro total; baja a 0 al entrar
fade_saliendo = false;
fade_vel = 0.05;          // cuanto sube el negro por paso al salir de la pantalla
accion_pendiente = "";
cambiando = false;        // true cuando ya se pidio el cambio de room
// si se llega tras reiniciar desde la pausa o la pantalla de muerte, arranque.ini puede pedir abrir directo la pantalla Mejoras
if (file_exists("arranque.ini")) {
    ini_open("arranque.ini");
    var _pant = ini_read_string("arranque", "pantalla", "principal");
    ini_close();
    file_delete("arranque.ini");
    if (_pant == "mejoras") { pantalla = "mejoras"; bloqueo = 15; }
}

// --- fondo con parallax ---
// Las capas son de 640x360 y se dibujan al doble (1280x720). vel = pixeles de pantalla por paso (mas cerca = mas rapido).
fondo_esc = 2;
fondo_t = 0;
capas = [
    { spr: s_menu_lejano,  vel: 0.15 },
    { spr: s_menu_medio,   vel: 0.45 },
    { spr: s_menu_cercano, vel: 0.90 }
];

// --- botones (s_boton_menu: 6 cuadros, 0 = dorado ... 5 = mecanico) ---
botones = [
    { texto: "Empezar",  accion: "empezar",  frame: 0 },
    { texto: "Tutorial", accion: "tutorial", frame: 0 },
    { texto: "Mejoras",  accion: "mejoras",  frame: 0 },
    { texto: "Salir",    accion: "salir",    frame: 0 }
];
frames_boton = sprite_get_number(s_boton_menu);
boton_esc = 2;                                            // 192x48 -> 384x96 en pantalla
boton_w = sprite_get_width(s_boton_menu) * boton_esc;
boton_h = sprite_get_height(s_boton_menu) * boton_esc;
boton_sep = 8;            // espacio entre botones
boton_y0 = 250;           // borde de arriba del primer boton
anim_vel = 0.45;          // cuadros por paso de la transicion dorado <-> mecanico
volver_frame = 0;         // boton "Volver" de Tutorial y Mejoras
volver_hover = false;
volver_cy = 590;
// Scroll del Tutorial (rueda del mouse, flechas o W/S): tut_scroll = desplazamiento actual, tut_scroll_obj = a donde va, tut_max = lo que sobra de contenido
tut_scroll = 0;
tut_scroll_obj = 0;
tut_max = 0;      // lo calcula Draw_0 segun cuanto mide el texto

// --- titulo: sprite s_menu_titulo (referencia directa, para que GameMaker no lo quite al compilar) ---
spr_titulo = s_menu_titulo;

// --- colores y fuentes ---
col_oro      = make_colour_rgb(255, 214, 102);
col_oro_osc  = make_colour_rgb(201, 128, 30);
col_cian     = make_colour_rgb(110, 235, 255);
col_texto    = make_colour_rgb(225, 230, 240);
fuente_titulo = font_add("Georgia", 54, true, false, 32, 255);
fuente_boton  = font_add("Georgia", 28, true, false, 32, 255);
fuente_texto  = font_add("Georgia", 22, false, false, 32, 255);
fuente_pix    = font_add("Verdana", 12, true, false, 32, 255);   // se usa a tamano chico y se amplia, para el texto pixelado de los botones

// --- acciones de los botones ---
menu_accion = function(_a) {
    switch (_a) {
        case "empezar":  fade_saliendo = true; accion_pendiente = "empezar"; fade_vel = 1 / (2   * game_get_speed(gamespeed_fps)); break;   // 2 s hasta negro
        case "salir":    fade_saliendo = true; accion_pendiente = "salir";   fade_vel = 1 / (0.5 * game_get_speed(gamespeed_fps)); break;
        case "tutorial": pantalla = "tutorial"; bloqueo = 15; tut_scroll = 0; tut_scroll_obj = 0; break;
        case "mejoras":  pantalla = "mejoras"; bloqueo = 15; break;
    }
};

// --- crea un sprite con el texto en blanco, a tamano chico (1 pixel = 1 pixel del boton original) ---
// Al dibujarlo ampliado x2 sin suavizado las letras quedan pixeladas, alineadas con la cuadricula del boton.
crear_sprite_texto = function(_texto) {
    draw_set_font(fuente_pix);
    var _w = ceil(string_width(_texto)) + 8;
    var _h = ceil(string_height(_texto)) + 8;
    var _s = surface_create(_w, _h);
    surface_set_target(_s);
    draw_clear_alpha(c_black, 0);
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    repeat (2) draw_text(floor(_w / 2), floor(_h / 2), _texto);   // dos pasadas: las letras quedan mas solidas
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    var _spr = sprite_create_from_surface(_s, 0, 0, _w, _h, false, false, floor(_w / 2), floor(_h / 2));
    surface_free(_s);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    return _spr;
};

// --- dibuja un boton (sprite + texto pixelado que pasa de marron sobre dorado a cian sobre acero) ---
dibujar_boton = function(_cx, _cy, _frame, _spr_texto) {
    var _f = clamp(floor(_frame), 0, frames_boton - 1);
    draw_sprite_ext(s_boton_menu, _f, _cx - boton_w / 2, _cy - boton_h / 2, boton_esc, boton_esc, 0, c_white, 1);
    var _t = _frame / (frames_boton - 1);
    var _col = merge_colour(make_colour_rgb(70, 38, 8), col_cian, _t);
    var _sombra = merge_colour(make_colour_rgb(255, 224, 130), make_colour_rgb(4, 18, 28), _t);
    draw_sprite_ext(_spr_texto, 0, _cx, _cy + boton_esc, boton_esc, boton_esc, 0, _sombra, 1);
    draw_sprite_ext(_spr_texto, 0, _cx, _cy,             boton_esc, boton_esc, 0, _col, 1);
};

// --- dibuja el panel de las pantallas Tutorial y Mejoras ---
dibujar_panel = function(_titulo) {
    draw_set_color(c_black);
    draw_set_alpha(0.6);
    draw_rectangle(0, 0, room_width, room_height, false);
    var _x1 = 140, _y1 = 50, _x2 = room_width - 140, _y2 = room_height - 50;
    draw_set_color(make_colour_rgb(12, 18, 30));
    draw_set_alpha(0.93);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(1);
    draw_set_color(col_oro_osc);
    for (var _k = 0; _k < 3; _k++) draw_rectangle(_x1 + _k, _y1 + _k, _x2 - _k, _y2 - _k, true);
    draw_set_color(col_cian);
    draw_rectangle(_x1 + 7, _y1 + 7, _x2 - 7, _y2 - 7, true);
    draw_set_font(fuente_titulo);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_colour(room_width / 2, 105 + 3, _titulo, c_black, c_black, c_black, c_black, 0.7);
    draw_text_colour(room_width / 2, 105, _titulo, make_colour_rgb(255, 236, 150), make_colour_rgb(255, 236, 150), col_oro_osc, col_oro_osc, 1);
};

// --- sprites de texto de los botones ---
for (var _i = 0; _i < array_length(botones); _i++) botones[_i].spr_texto = crear_sprite_texto(botones[_i].texto);
volver_spr = crear_sprite_texto("Volver");
