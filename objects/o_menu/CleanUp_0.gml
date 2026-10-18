// libera las fuentes (font_add) y los sprites de texto creados desde surfaces
var _f = [fuente_titulo, fuente_boton, fuente_texto, fuente_pix];
for (var _i = 0; _i < array_length(_f); _i++) {
    if (_f[_i] != -1) font_delete(_f[_i]);
}
for (var _j = 0; _j < array_length(botones); _j++) sprite_delete(botones[_j].spr_texto);
sprite_delete(volver_spr);
