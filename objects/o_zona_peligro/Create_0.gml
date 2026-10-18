// ===== Zona de peligro en el suelo =====
// Avisa en el suelo, golpea una vez y, si persistir > 0, se queda quemando un rato.
// Se crea con crear_zona(x, y, estilo, radio, aviso, dano, persistir) (ver scr_enemigos).
//   estilo "sombra": una sombra que crece (algo cae del cielo) y despues una explosion.
//   estilo "fuego":  suelo que se calienta (brasas) y despues una llamarada; con persistir deja fuego.
if (!variable_instance_exists(id, "estilo"))    estilo    = "sombra";
if (!variable_instance_exists(id, "radio"))     radio     = 32;
if (!variable_instance_exists(id, "aviso"))     aviso     = 60;    // pasos de aviso
if (!variable_instance_exists(id, "dano"))      dano      = 4;     // dano del impacto
if (!variable_instance_exists(id, "persistir")) persistir = 0;     // pasos que queda el fuego (0 = nada)

dano_tick = 1;       // dano del fuego que queda
cada_tick = 30;      // pasos entre quemaduras
tick      = 0;
dur_impacto = 12;    // pasos que se ve la explosion

fase  = "aviso";     // "aviso" -> "impacto" -> "ardiendo" (opcional)
timer = aviso;
semilla = irandom(1000);   // para que las brasas/llamas de cada zona no esten en el mismo lugar
