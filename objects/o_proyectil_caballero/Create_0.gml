// ===== Proyectil del caballero (media luna de espada) =====
// Lo crea o_player al atacar con el caballero:
//   instance_create_depth(x, y, depth - 1, o_proyectil_caballero, { direccion: angulo, dano: 4, escala: 1.4 });
// Si no se pasa alguno de esos valores, se usan los de aqui.
if (!variable_instance_exists(id, "direccion")) direccion = 0;   // angulo de vuelo (grados)
if (!variable_instance_exists(id, "dano"))      dano      = 4;
if (!variable_instance_exists(id, "escala"))    escala    = 1;

velocidad     = 6;      // px por paso
if (!variable_instance_exists(id, "alcance")) alcance = 40;   // rango maximo (px): al llegar aqui empieza a desaparecer (o_player lo agranda con la carta Tajo mas largo)
recorrido     = 0;
anim_vel      = 0.33;   // cuadros por paso (0.25 = 15 cuadros por segundo)
desvaneciendo = false;  // true = ya esta desapareciendo (animacion inversa) y NO hace dano
golpeados     = {};     // enemigos ya golpeados (cada uno recibe dano una sola vez)

sprite_set_offset(s_proyectil_caballero, 16, 17);   // origen en el centro de la media luna, para que gire bien
sprite_index = s_proyectil_caballero;
image_speed  = 0;       // la animacion se controla a mano en el Step
image_index  = 0;
image_angle  = direccion;   // el sprite mira hacia la derecha
image_xscale = escala;
image_yscale = escala;
