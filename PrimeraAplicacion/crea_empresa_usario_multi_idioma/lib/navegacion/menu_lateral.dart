import 'package:crea_empresa_usuario_multi_idioma/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:crea_empresa_usuario_multi_idioma/globales/globales.dart';
import 'package:crea_empresa_usuario_multi_idioma/main.dart';
import 'package:crea_empresa_usuario_multi_idioma/navegacion/cabecera_menu.dart';
import 'package:crea_empresa_usuario_multi_idioma/navegacion/pantalla.dart';
import 'package:crea_empresa_usuario_multi_idioma/navegacion/item_menu_lateral.dart';
import 'package:crea_empresa_usuario_multi_idioma/navegacion/rutas_pantallas.dart';
import 'package:flutter/material.dart';
import 'package:crea_empresa_usuario_multi_idioma/globales/colores.dart';
// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

// https://material.io/components/navigation-drawer/flutter#using-a-navigation-drawer

/// Clase que gestiona las diferentes opciones que aparecen en el menú lateral.
///
/// Nuestro Navigation Drawer consistirá en una lista
/// de diferentes elementos, entre los que encontramos
/// la cabecera (DrawerHeader) y diferentes elementos
/// de lista (ListTile.), en este caso [ItemMenu] classe que se compone de un widget [Card]
/// que contiene a un [ListTile]
///
/// Los diferentes elementos se presentaran en le orden que son insertdos en la lista
/// que contiene a los diferentes widgets que componen el menú
///
/// Ejemplo de menu
/// ```dart
/// static List<Widget> items = [
///    // Cabecera
///    CabeceraMenu(traduce: (traduce) {
///      return traduce.nombreApp;
///    }),
///
///    // Añade item
///    ItemMenu(Icons.add_business_rounded, Rutas..getRuta('EmpresaNueva'),
///        traduce: (traduce) {
///      return traduce.anyadeEmpresa;
///    }),
///    ...
///  }
/// // En el Widget que qeramos añadir el menu lateral
/// // Donde queramos añadir el menu
/// Scaffold(
///   drawer: MenuLateral(token!),
///   ...
/// );
/// ```
class MenuLateral extends StatelessWidget {
  const MenuLateral({Key? key}) : super(key: key);
  //final String? token;

  static final List<Widget> _items = [
    // Cabecera
    CabeceraMenu(traduce: (traduce) {
      return traduce.nombreApp;
    }),
    // Cierra sesion
    ItemMenu(Icons.logout_rounded, MyApp.cierraSesion, necesitaToken: false,
        funcionTraduce: (traduce) {
      return traduce.cerrarSesion;
    }),
  ];

  static anyadeItem(Widget itemMenu) {
    _items.insert(_items.length - 1, itemMenu);
  }

  @override
  Widget build(BuildContext context) {
    final rutaActual = (ModalRoute.of(context)?.settings.name).toString();
    return Drawer(
      //backgroundColor: Theme.of(context).primaryColorLight,
      child: ListView(
        // Eliminamos el padding del listview
        padding: EdgeInsets.zero,
        children: _items,
      ),
    );
  }
}
