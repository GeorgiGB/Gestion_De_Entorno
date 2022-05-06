import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:crea_empresa_usario/globales.dart';
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

// https://material.io/components/navigation-drawer/flutter#using-a-navigation-drawer

/// Clase que gestiona las diferents opciones que aparecen en el menú lateral
/// La ruta [Rutas.Identificate] no se incluye ya que és la pantalla inicial de
/// login, en su lugar aparece la opción de cerrar sesión
///
/// Cualquier patalla que quiera utilizar el emnú la teral deberá pasar el token
class MainDrawer extends StatelessWidget {
  MainDrawer(this.traduce, this.token, {Key? key})
      : super(
            key:
                key); /* {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (!PantallasMenu.abierto) {
        //print("---> " + (_menu == null).toString());
        PantallasMenu.abierto = true;
        yo.openDrawer();
      }
    });
  }*/
  final AppLocalizations traduce;
  final String token;
  final Widget vacio = const SizedBox();
  late BuildContext cnxt;
  //late final MainDrawer yo;

  void openDrawer() {
    Scaffold.of(cnxt).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    //yo = this;
    Future.delayed(
      Duration(milliseconds: 500),
      () async {
        debug('abrinedo');
        Scaffold.of(context).openDrawer();
      },
    );
    cnxt = context;
    // Nuestro Navigation Drawer consistirá en una lista
    // de diferentes elementos, entre los que encontramos
    // la cabecera (DrawerHeader) y diferentes elementos
    // de lista (ListTile.)

    String currentRoute = (ModalRoute.of(context)?.settings.name).toString();
    return Drawer(
      backgroundColor: Theme.of(context).primaryColor,
      child: ListView(
        // Eliminamos el padding del listview
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
              height: 100,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                child: Stack(children: [
                  Positioned(
                      child: Text(traduce.nombreApp,
                          style: Theme.of(context).textTheme.headline5)),
                  Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                          icon: Icon(Icons.close),
                          color: Colors.white,
                          onPressed: () => Navigator.of(context).pop())),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: LanguageDropDown().getDropDown(context),
                  ),
                ]),
              )),

          // Añade empresa
          ListTile(
            title: Text(traduce.nuevaEmpresa,
                style: Theme.of(context).textTheme.headline6),
            onTap: () {
              Navigator.of(context).pushNamed(Rutas.EmpresaNueva);
            },
          ),

          // Añade usuario
          ListTile(
            title: Text(traduce.nuevoUsuario,
                style: Theme.of(context).textTheme.headline6),
            onTap: () {
              Navigator.of(context).pushNamed(Rutas.UsuarioNuevo);
            },
          ),

          // Configuración
          ListTile(
            title: Text(traduce.configuracion,
                style: Theme.of(context).textTheme.headline6),
            onTap: () {
              Navigator.of(context).pushNamed(Rutas.Configuracion);
            },
          ),

          // Cierra sesion
          ListTile(
            title: Text(traduce.cerrarSesion,
                style: Theme.of(context).textTheme.headline6),
            onTap: () {
              MyApp.cierraSesion(context);
            },
          ),
        ],
      ),
    );
  }
}
