import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:crea_empresa_usario/globales.dart';
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/cabecera_menu.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/navegacion/item_menu_lateral.dart';
import 'package:flutter/material.dart';
import 'package:crea_empresa_usario/colores.dart';
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
///    ItemMenu(Icons.add_business_rounded, Rutas.rutas['EmpresaNueva']!,
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

    // Añade empresa
    ItemMenu(Icons.add_business_rounded, Rutas.rutas['EmpresaNueva']!,
        funcionTraduce: (traduce) {
      return traduce.anyadeEmpresa;
    }),

    // Añade usuario
    ItemMenu(Icons.account_circle_rounded, Rutas.rutas['UsuarioNuevo']!,
        funcionTraduce: (traduce) {
      return traduce.nuevoUsuario;
    }),

    // Configuración
    ItemMenu(Icons.settings_rounded, Rutas.rutas['Configuracion']!,
        funcionTraduce: (traduce) {
      return traduce.configuracion;
    }),
    // Cierra sesion
    ItemMenu(Icons.logout_rounded, MyApp.cierraSesion, necesitaToken: false,
        funcionTraduce: (traduce) {
      return traduce.cerrarSesion;
    }),
  ];

  static anyadeItem(ItemMenu itemMenu) {
    _items.add(itemMenu);
  }

  @override
  Widget build(BuildContext context) {
    final rutaActual = (ModalRoute.of(context)?.settings.name).toString();
    /*for (var i = 1; i < items.length; i++) {
      if (items[i] is ItemMenu) {
        ItemMenu itlt = items[i] as ItemMenu;
        // Si item está seleccionat
        itlt.esSeleccionado(rutaActual);

        /*
        //Si el token es null i necesitaToken se desactivará el item
        itlt.itemTieneToken(token);*/
      }
    }*/
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
