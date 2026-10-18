if (congelado) {
    instance_activate_all();
    congelado = false;
}
font_delete(fuente_titulo);
font_delete(fuente_texto);
font_delete(fuente_boton);
