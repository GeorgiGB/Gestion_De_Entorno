import 'package:crea_empresa_usario/navegacion/item_menu_lateral.dart';
import 'package:crea_empresa_usario/navegacion/pantalla.dart';
import 'package:crea_empresa_usario/navegacion/rutas_pantallas.dart';
import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

class IconTraduce {
  /// [Icon]
  late final Icon icon;

  /// Función al que le pasamos un [AppLocalizations] y nos
  /// devuelve  una cadena traducida
  final String Function(AppLocalizations) traduce;

  /// Utilizamos un [icon] y una función anonima [traduce]
  IconTraduce(this.icon, {required this.traduce});

  /// Con un [IconData] y la función anónima [traduce]
  IconTraduce.iconData(IconData iconData, {required this.traduce})
      : icon = Icon(iconData);
}

class Navega {
  late final Ruta ruta;
  late final PantallasConfig cfgPantalla;
  final dynamic titulo;
  final String id;

  static final Map<String, Navega> _navegantes = <String, Navega>{};
  static Navega navegante(String id) => _navegantes[id]!;

  ///añadir la ruta que será utilizada por el parámetro
  /// routes de la clase [MaterialApp] que encontraremos en el fichero main.dart
  /// Método encargado de preparar la navegación
  /// - id: el identificador del elemento de Navegación, debe ser único. Obligatorio
  /// - ruta: la cadena que identifica a la ruta, si no se pone se formará con el id
  /// - conToken: indica si para acceder a esta pantalla necesita el token de sesión. Opcional -> true
  /// - conItemMenu: nos pondrá un item de menú en lel menu lateral. Opcional -> true
  /// - menuLateral: si aparece el menú lateral en la pantalla. Opcional -> true
  Navega(this.id,
      {required this.titulo,
      required Widget Function(String?) constructor,
      String? nombreRuta,
      dynamic? itemMenu,
      bool conToken = true,
      bool menuLateral = true}) {
    //
    // si existe un id previo lanza un error
    assert(() {
      if (_navegantes.keys.contains(id)) {
        throw FlutterError(
          'Este id de navegación: $id, ya está uso.',
        );
      }
      return true;
    }());

    // Añadimos el navegador a los navegantes
    _navegantes[id] = this;

    // Obtenemos la ruta
    ruta = Ruta(id, nombreRuta, constructor);

    //Pasamos valores configuración de pantalla
    cfgPantalla = PantallasConfig(
        conToken: conToken,
        //conItemMenu: conItemMenu,
        menuLateral: menuLateral,

        // Añade Ejemplo, más opciones sobre [ItemMenu] en su archivo
        // correspondiente
        itemMenu: _creaItemIcon(itemMenu, conToken)
        /*ItemMenu(Icons.login_rounded, ruta.hacia,
          necesitaToken: conToken, funcionTraduce: (traduce) {
        return traduce.iniciaSesion;
      }),*/
        );
  }

  Widget? _creaItemIcon(dynamic itemMenu, bool conToken) {
    if (itemMenu != null) {
      if (itemMenu is IconTraduce) {
        return ItemMenu(itemMenu.icon, ruta.hacia,
            necesitaToken: conToken, funcionTraduce: itemMenu.traduce);
      } else if (itemMenu is Widget) {
        return itemMenu;
      }
    }
  }

  PantallasMenu muestraPantalla(BuildContext context, {Key? key}) {
    late Widget titulo;
    final String Function(AppLocalizations) funcionTraduce;
    if (this.titulo is Function /*String Function(AppLocalizations)*/) {
      titulo = Text(this.titulo(AppLocalizations.of(context)));
    } else {
      titulo = this.titulo;
    }
    return PantallasMenu(titulo, ruta.id,
        key: key,
        menuLateral: cfgPantalla.menuLateral,
        conToken: cfgPantalla.conToken);
  }

  Future<T?> voy<T extends Object?>(BuildContext context, {Object? arguments}) {
    return vesA(ruta.hacia, context, arguments: arguments);
  }
}
