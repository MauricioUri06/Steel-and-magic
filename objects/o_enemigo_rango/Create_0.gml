// ===== Enemigo a distancia (padre del elfo oscuro y del elite con lanzamisiles) =====
// Estados: perseguir (mantiene la distancia) -> apuntar (sprite de apuntar) -> disparar (rafaga) -> recuperar -> perseguir
event_inherited();

dist_ideal   = 170;       // se acerca hasta esta distancia
dist_min     = 110;       // si el jugador esta mas cerca, se aleja
aviso        = 30;        // pasos apuntando antes de disparar
aviso_fijo   = 10;        // los ultimos pasos del aviso la mira deja de seguir al jugador (para poder esquivar)
cd_disparo   = 90;        // pasos entre rafagas
cd           = irandom(cd_disparo);   // aleatorio para que no disparen todos a la vez
rafaga       = 1;         // disparos por rafaga
rafaga_pausa = 8;         // pasos entre disparos de la rafaga
disparos_restantes = 0;
recuperacion = 15;        // pasos quieto despues de la rafaga
dir_apunta   = 0;

proy_obj   = o_proyectil_enemigo;
proy_vel   = 4;
proy_dano  = 2;
proy_color = c_aqua;

// Crea el proyectil. Un hijo la puede reemplazar para disparar distinto.
disparar = function(_dir) {
    if (proy_obj == o_misil_enemigo) sfx_play(sfx_misil_lanzar, 0.8, 1, 0.05, 90);
    else sfx_play(sfx_enemigo_disparo, 0.8, 1, 0.08, 50);
    instance_create_depth(x + lengthdir_x(radio, _dir), y + lengthdir_y(radio, _dir), depth - 1, proy_obj,
                          { direccion: _dir, vel: proy_vel, dano: proy_dano, color: proy_color });
};

comportamiento = function() {
    if (!instance_exists(o_player)) return;
    if (cd > 0) cd -= 1;
    var _dist = point_distance(x, y, o_player.x, o_player.y);
    dir_mira = point_direction(x, y, o_player.x, o_player.y);

    switch (estado) {
        case "perseguir":
            var _lo_ve = !collision_line(x, y, o_player.x, o_player.y, o_solid, false, true);
            if (_dist > dist_ideal || !_lo_ve) mover(dir_mira, vel);
            else if (_dist < dist_min)          mover(dir_mira + 180, vel);
            if (_lo_ve && _dist <= dist_ideal + 40 && cd <= 0) {
                estado = "apuntar";
                timer  = aviso;
            }
            break;

        case "apuntar":
            timer -= 1;
            if (timer > aviso_fijo) dir_apunta = dir_mira;
            if (timer <= 0) {
                estado = "disparar";
                disparos_restantes = rafaga;
                timer = 0;
            }
            break;

        case "disparar":
            timer -= 1;
            if (timer <= 0) {
                if (disparos_restantes > 0) {
                    disparar(dir_apunta);
                    disparos_restantes -= 1;
                    timer = rafaga_pausa;
                } else {
                    estado = "recuperar";
                    timer  = recuperacion;
                    cd     = max(0, cd_disparo - reduccion_cd);   // reduccion_cd: ver o_enemigo_base
                }
            }
            break;

        case "recuperar":   // pausa corta despues de disparar (baja el arma)
            timer -= 1;
            if (timer <= 0) estado = "perseguir";
            break;
    }
};
