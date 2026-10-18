// ===== Misil enemigo (hijo de o_proyectil_enemigo) =====
// Persigue un poco al jugador y explota en area al chocar o al llegar al alcance.
event_inherited();

radio      = 6;
alcance    = 420;
giro       = 1.2;    // grados por paso que corrige hacia el jugador
area       = 40;     // radio de la explosion (px)
dur_explosion = 12;  // pasos que se ve la explosion
explotando = 0;

impactar = function(_al_jugador) {
    if (explotando > 0) return;
    explotando = dur_explosion;
    sfx_play(sfx_explosion_chica, 1, 0.9, 0.08, 60);
    vel = 0;
    if (jugador_cerca(x, y, area)) danar_jugador(dano);
};
