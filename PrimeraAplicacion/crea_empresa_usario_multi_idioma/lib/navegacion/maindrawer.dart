import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:crea_empresa_usario/globales.dart';
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/cabecera.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/widgets/item_menu_lateral.dart';
import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

// https://material.io/components/navigation-drawer/flutter#using-a-navigation-drawer

/// Clase que gestiona las diferents opciones que aparecen en el menú lateral.
///
/// Cualquier patalla que quiera utilizar el emnú la teral deberá pasar el token
///
/// Nuestro Navigation Drawer consistirá en una lista
/// de diferentes elementos, entre los que encontramos
/// la cabecera (DrawerHeader) y diferentes elementos
/// de lista (ListTile.)
class MainDrawer extends StatelessWidget {
  const MainDrawer(this.token, {Key? key}) : super(key: key);
  final String token;

  static List<Widget> items = [
    // Cabecera
    CabeceraMenuLat(traduce: (traduce) {
      return traduce.nombreApp;
    }),

    // Añade empresa
    ItemMenuLat(Icons.add_business_rounded, Rutas.EmpresaNueva,
        traduce: (traduce) {
      return traduce.anyadeEmpresa;
    }),

    // Añade usuario
    ItemMenuLat(Icons.account_circle_rounded, Rutas.UsuarioNuevo,
        traduce: (traduce) {
      return traduce.nuevoUsuario;
    }),

    // Configuración
    ItemMenuLat(Icons.settings_rounded, Rutas.Configuracion,
        traduce: (traduce) {
      return traduce.configuracion;
    }),
    // Cierra sesion
    ItemMenuLat(Icons.logout_rounded, MyApp.cierraSesion, traduce: (traduce) {
      return traduce.cerrarSesion;
    }),
  ];

  @override
  Widget build(BuildContext context) {
    final rutaActual = (ModalRoute.of(context)?.settings.name).toString();
    for (var i = 1; i < items.length; i++) {
      ItemMenuLat itlt = items[i] as ItemMenuLat;
      itlt.setSelectionat(rutaActual);
    }
    return Drawer(
      //backgroundColor: Theme.of(context).primaryColorLight,
      child: ListView(
        // Eliminamos el padding del listview
        padding: EdgeInsets.zero,
        children: items,
      ),
    );
  }
}
