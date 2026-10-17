// ===== Proyectil del soldado (bala) =====
// Lo crea o_player al disparar con el soldado:
//   instance_create_depth(x, y, depth - 1, o_proyectil_soldado, { direccion: angulo, dano: 2, escala: 1.4 });
// Si no se pasa alguno de esos valores, se usan los de aqui.
if (!variable_instance_exists(id, "direccion")) direccion = 0;   // angulo de vuelo (grados)
if (!variable_instance_exists(id, "dano"))      dano      = 2;
if (!variable_instance_exists(id, "escala"))    escala    = 1;

velocidad = 14;      // px por paso
atraviesa = true;    // true: sigue de largo al golpear a un enemigo (golpea a cada uno una sola vez)
                     // false: desaparece al golpear al primer enemigo
golpeados = {};      // enemigos ya golpeados

sprite_set_offset(s_proyectil_soldado, 16, 16);   // origen en el centro de la bala, para que gire bien
sprite_index = s_proyectil_soldado;
image_speed  = 1;    // animacion en bucle mientras vuela
image_angle  = direccion;   // el sprite mira hacia la derecha
image_xscale = escala;
image_yscale = escala;
