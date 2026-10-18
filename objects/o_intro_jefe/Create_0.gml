// ===== Presentacion de jefe (estilo Smash) =====
// La crea o_jefe_base la primera vez que se actualiza un jefe que tiene intro_spr:
//   instance_create_depth(0, 0, -10000, o_intro_jefe, { spr: ..., nombre: "...", subtitulo: "..." });
// Congela el juego (foto del ultimo cuadro), la ilustracion entra desde la derecha en una franja diagonal,
// entra el nombre, se queda un momento y todo sale hacia la izquierda. Clic o tecla para saltarla.
if (!variable_instance_exists(id, "spr"))       spr = -1;
if (!variable_instance_exists(id, "nombre"))    nombre = "";
if (!variable_instance_exists(id, "subtitulo")) subtitulo = "";

// foto del ultimo cuadro para el fondo y congelar todo lo demas (igual que la pausa del jugador)
captura = sprite_create_from_surface(application_surface, 0, 0,
                                     surface_get_width(application_surface), surface_get_height(application_surface),
                                     false, false, 0, 0);
instance_deactivate_all(true);

t          = 0;
entrada    = 18;    // pasos que tarda en entrar la ilustracion
salida_ini = 115;   // paso en que empieza a irse
total      = 138;   // paso en que termina y sigue el juego
superficie = -1;    // aca se dibuja la ilustracion recortada en diagonal
color_borde = make_colour_rgb(255, 214, 102);
