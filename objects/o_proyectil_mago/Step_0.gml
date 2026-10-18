// ===== Volar =====
x += lengthdir_x(velocidad, direccion);
y += lengthdir_y(velocidad, direccion);
recorrido += velocidad;

// ===== Impacto: dano directo a los enemigos que toca =====
// Enemigo = instancia con  es_enemigo = true.  Si tiene el metodo  recibir_dano(_cantidad)  lo llama; si no, resta a su  hp.
var _impacto = false;
var _lista = ds_list_create();
var _nhit = instance_place_list(x, y, all, _lista, false);
for (var _k = 0; _k < _nhit; _k++) {
    var _en = _lista[| _k];
    if (!variable_instance_exists(_en, "es_enemigo") || !_en.es_enemigo) continue;
    _impacto = true;
    if (variable_instance_exists(_en, "recibir_dano")) _en.recibir_dano(dano);
    else if (variable_instance_exists(_en, "hp")) _en.hp -= dano;
    if (instance_exists(o_player)) o_player.golpe_extra(_en, direccion);   // carta Empuje
}
ds_list_destroy(_lista);

// ===== Al impactar o llegar al limite: se destruye y deja los efectos de fuego =====
if (_impacto || recorrido >= alcance) {
    // impacto: explosion (mas grande = mas grave y fuerte); si solo llego al limite del rango, solo se enciende el fuego
    if (_impacto) sfx_play(sfx_explosion, clamp(0.4 + 0.2 * escala, 0.5, 1), clamp(1.25 - 0.15 * escala, 0.8, 1.2), 0.05);
    else sfx_play(sfx_fuego, 0.7, 1, 0.08);
    var _ed = depth + 2;   // los efectos quedan en el suelo, por debajo del jugador
    // uno en el punto de impacto
    instance_create_depth(clamp(x, 16, room_width - 16), clamp(y, 16, room_height - 16), _ed, o_efecto_mago, { dano: dano_efecto, escala: escala_efecto });
    // los demas repartidos alrededor, a distintas distancias (hasta "radio", que depende del tamano de la bola)
    var _a0 = random(360);
    for (var _i = 1; _i < efectos; _i++) {
        var _a = _a0 + (_i - 1) * (360 / max(efectos - 1, 1)) + random_range(-15, 15);
        var _d = radio * random_range(0.45, 1);
        var _ex = clamp(x + lengthdir_x(_d, _a), 16, room_width - 16);
        var _ey = clamp(y + lengthdir_y(_d, _a), 16, room_height - 16);
        instance_create_depth(_ex, _ey, _ed, o_efecto_mago, { dano: dano_efecto, escala: escala_efecto });
    }
    instance_destroy();
}
