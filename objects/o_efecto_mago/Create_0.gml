// ===== Efecto de fuego en el suelo (lo crea la bola de fuego del mago al destruirse) =====
// Recibe (opcional): dano (por pulso, a cada enemigo encima) | escala
if (!variable_instance_exists(id, "dano"))   dano   = 1;
if (!variable_instance_exists(id, "escala")) escala = 1;

duracion_seg = 3;     // segundos que se queda en el suelo antes de empezar a desaparecer
pulso_seg    = 0.5;   // cada cuantos segundos hace dano a los enemigos que estan encima
fase  = "activo";     // "activo" -> pasados los 3 s -> "muriendo" (animacion de destruccion, ya sin dano)
vida  = round(duracion_seg * game_get_speed(gamespeed_fps));
pulso = 0;

// cuadros del sprite: 0-3 aparece y arde, 4-5 se apaga (destruccion)
frame_ultimo_activo = 3;   // ultimo cuadro de la parte "activa"
frame_bucle_ini     = 2;   // mientras arde, parpadea entre este cuadro y el ultimo activo
anim_vel       = 0.3;      // cuadros por paso al aparecer y al apagarse
anim_vel_bucle = 0.15;     // cuadros por paso mientras arde

sprite_set_offset(s_proyectil_efecto_mago, 16, 30);   // origen en la base de las llamas (el suelo)
sprite_index = s_proyectil_efecto_mago;
image_speed  = 0;          // la animacion se controla a mano en el Step
image_index  = 0;
image_xscale = escala * choose(1, -1);   // espejado al azar para que no se vean todos iguales
image_yscale = escala;
sfx_play(sfx_fuego, 0.35, 1, 0.1, 120);   // las llamas nuevas (varias a la vez, o las del dash) suenan como una sola
