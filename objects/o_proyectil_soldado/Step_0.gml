// ===== Volar en linea recta =====
x += lengthdir_x(velocidad, direccion);
y += lengthdir_y(velocidad, direccion);

// ===== Dano a los enemigos que toca (cada enemigo una sola vez) =====
// Enemigo = instancia con  es_enemigo = true.  Si tiene el metodo  recibir_dano(_cantidad)  lo llama; si no, resta a su  hp.
var _destruir = false;
var _lista = ds_list_create();
var _nhit = instance_place_list(x, y, all, _lista, false);
for (var _k = 0; _k < _nhit; _k++) {
    var _en = _lista[| _k];
    if (!variable_instance_exists(_en, "es_enemigo") || !_en.es_enemigo) continue;
    if (variable_struct_exists(golpeados, string(_en))) continue;
    golpeados[$ string(_en)] = true;
    if (variable_instance_exists(_en, "recibir_dano")) _en.recibir_dano(dano);
    else if (variable_instance_exists(_en, "hp")) _en.hp -= dano;
    if (!atraviesa) _destruir = true;
}
ds_list_destroy(_lista);

// ===== Solo desaparece al salir del cuarto =====
if (bbox_right < 0 || bbox_left > room_width || bbox_bottom < 0 || bbox_top > room_height) _destruir = true;
if (_destruir) instance_destroy();
