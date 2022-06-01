import 'package:crea_empresa_usuario_multi_idioma/navegacion/item_menu_lateral.dart';
import 'package:crea_empresa_usuario_multi_idioma/navegacion/menu_lateral.dart';
import 'package:flutter/material.dart';

/// Clase que contiene las diferentes rutas de las pantallas que vamos a presentar
/// Junto con los [_constructoresWidgets] que será utilizados parar cargar
/// las diferentes pantallas de la aplicación
class Ruta {
  static final Map<String, String> _rutas = <String, String>{};

  /// Mapa compuesto por una cadena que identifia a la función constructora de widgets
  /// que se mostraran la pantalla
  ///
  /// ejemplo tomado de: https://github.com/flutter/flutter/issues/17766
  static final Map<String, Widget Function(String?)> _constructoresWidgets =
      <String, Widget Function(String?)>{};

  static addRuta(String clave, String ruta) {
    Ruta._rutas[clave] = ruta;
  }

  static String getRuta(String clave) {
    return Ruta._rutas[clave]!;
  }

  static addConstructorWidgets(
      String clave, Widget Function(String?) constructor) {
    Ruta._constructoresWidgets[clave] = constructor;
  }

  static Widget Function(String?) getConstructorWidgets(String clave) {
    return Ruta._constructoresWidgets[clave]!;
  }

  final String id;
  late final String hacia;
  final Widget Function(String?) constructor;

  Ruta(this.id, String? ruta, this.constructor) {
    this.hacia = '/' + (ruta ?? id);
    Ruta.addRuta(id, this.hacia);

    Ruta.addConstructorWidgets(id, constructor);
  }
}

class PantallasConfig {
  final bool conToken;
  //final bool conItemMenu;
  final bool menuLateral;
  final Widget? itemMenu;

  PantallasConfig({
    this.conToken = true,
    //this.conItemMenu = true,
    this.menuLateral = true,
    this.itemMenu,
  }) {
    if (itemMenu != null) {
      MenuLateral.anyadeItem(itemMenu!);
    }
  }
}
