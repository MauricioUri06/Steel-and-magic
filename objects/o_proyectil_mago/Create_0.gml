// ===== Bola de fuego del mago =====
// La crea o_player al soltar el clic; mientras mas se cargo, mas grande y mas efectos deja.
// Recibe (todo opcional, estos son los valores por defecto):
//   direccion (angulo) | dano (impacto directo) | escala | efectos (cuantos efectos de fuego deja al destruirse)
//   radio (px, area donde caen los efectos) | escala_efecto | dano_efecto (dano por pulso de cada efecto)
if (!variable_instance_exists(id, "direccion"))     direccion     = 0;
if (!variable_instance_exists(id, "dano"))          dano          = 3;
if (!variable_instance_exists(id, "escala"))        escala        = 1;
if (!variable_instance_exists(id, "efectos"))       efectos       = 2;
if (!variable_instance_exists(id, "radio"))         radio         = 24;
if (!variable_instance_exists(id, "escala_efecto")) escala_efecto = 1;
if (!variable_instance_exists(id, "dano_efecto"))   dano_efecto   = 1;

velocidad = 7;      // px por paso
alcance   = 260;    // media distancia (px): al llegar aqui se destruye y deja los efectos
recorrido = 0;

sprite_set_offset(s_proyectil_mago, 16, 16);   // origen en el centro de la bola, para que gire bien
sprite_index = s_proyectil_mago;
image_speed  = 1;           // animacion en bucle mientras vuela
image_angle  = direccion;   // el sprite mira hacia la derecha
image_xscale = escala;
image_yscale = escala;
