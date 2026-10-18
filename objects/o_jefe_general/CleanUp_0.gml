if (muerte_final_congelado) {
    instance_activate_all();
    muerte_final_congelado = false;
}
if (sprite_exists(muerte_final_captura)) sprite_delete(muerte_final_captura);
