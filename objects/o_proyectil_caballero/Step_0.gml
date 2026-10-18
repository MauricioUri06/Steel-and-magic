if (!desvaneciendo) {
    // ===== Volando =====
    x += lengthdir_x(velocidad, direccion);
    y += lengthdir_y(velocidad, direccion);
    recorrido += velocidad;

    // animacion hacia adelante; se queda en el ultimo cuadro
    image_index = min(image_index + anim_vel, image_number - 1);

    // ===== Dano a los enemigos que toca (atraviesa; cada enemigo una sola vez) =====
    // Enemigo = instancia con  es_enemigo = true.  Si tiene el metodo  recibir_dano(_cantidad)  lo llama; si no, resta a su  hp.
    var _lista = ds_list_create();
    var _nhit = instance_place_list(x, y, all, _lista, false);
    for (var _k = 0; _k < _nhit; _k++) {
        var _en = _lista[| _k];
        if (!variable_instance_exists(_en, "es_enemigo") || !_en.es_enemigo) continue;
        if (variable_struct_exists(golpeados, string(_en))) continue;
        golpeados[$ string(_en)] = true;
        if (variable_instance_exists(_en, "recibir_dano")) _en.recibir_dano(dano);
        else if (variable_instance_exists(_en, "hp")) _en.hp -= dano;
        if (instance_exists(o_player)) o_player.golpe_extra(_en, direccion);   // carta Empuje
    }
    ds_list_destroy(_lista);

    // ===== Llego al limite del rango: empieza a desaparecer =====
    if (recorrido >= alcance) desvaneciendo = true;
} else {
    // ===== Desapareciendo: animacion a la inversa, ya sin hacer dano =====
    image_index -= anim_vel;
    if (image_index < 0) instance_destroy();
}
