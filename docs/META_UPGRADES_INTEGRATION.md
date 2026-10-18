# Integracion del menu de mejoras permanentes

Este modulo esta aislado de `o_player`, enemigos y proyectiles. El unico objeto persistente es `o_meta_manager`; la interfaz usa `spr_meta_ui_atlas` y guarda el progreso en `steel_magic_meta.ini` dentro del almacenamiento local del juego.

## API publica

Cuando el jugador recoge monedas durante una partida:

```gml
meta_sumar_monedas_run(cantidad);
```

Cuando el jugador muere:

```gml
meta_abrir_menu_muerte();
```

Si el sistema de monedas del equipo ya lleva su propio contador, se puede entregarlo directamente:

```gml
meta_abrir_menu_muerte(monedas_de_esta_partida);
```

Para obtener todos los bonos permanentes sin acoplar este modulo al jugador:

```gml
var bonos = meta_obtener_bonos();
// bonos.vida_extra
// bonos.multiplicador_velocidad
// bonos.multiplicador_dano
// bonos.multiplicador_dash_distancia
// bonos.multiplicador_dash_recarga
// bonos.cargas_dash_extra
// bonos.multiplicador_radio_monedas
// bonos.multiplicador_monedas
// bonos.rerolls_extra
// bonos.cuarta_opcion
```

Si una nueva partida siempre debe comenzar en una room concreta:

```gml
meta_configurar_room_inicio(rm_acto_1_ruinas);
```

Si no se configura una room inicial, el boton inferior reinicia la room actual.

## Prueba aislada

`o_meta_manager` esta colocado solamente en `rm_acto_1_ruinas`, sin modificar `o_player`.

- `N`: suma 100 monedas permanentes de prueba.
- `M`: simula la muerte con 25 monedas obtenidas en la partida.
- `Esc`: omite las mejoras y empieza una nueva partida.

Antes de publicar la version final se puede poner `debug_meta = false` en el Create de `o_meta_manager`.

## Balance

Los precios estan centralizados en `scr_meta_progreso.gml`, en los campos `costo_base` y `crecimiento`. Esto permite ajustar la economia sin modificar la interfaz ni los sistemas de los companeros.
