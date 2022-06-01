import 'package:crea_empresa_usuario_multi_idioma/navegacion/menu_lateral.dart';
import 'package:crea_empresa_usuario_multi_idioma/navegacion/pantalla.dart';
import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crea_empresa_usuario_multi_idioma/colores.dart';
// Fin imports multi-idioma ----------------

/// Clase que crea un item del menu con un icono a partir un IconData [icon]
///
/// La acción que vaya a realizar [accion] puede ser:
/// * un String que representa cualquiera de las rutas establecida en la clase [Rutas]
/// * o cualquier función que admita como parámetro un [BuildContext].
///
/// El título lo obtiene a partir de la funcion anónima [funcionTraduce]
/// que pasa como parámetro un [AppLocalizations].
///
/// Por defecto viene con el parámetro [necesitaToken] a true, esto significa que
/// si el menu tiene un token se mostrá activo i si no  se desactivará
///
/// Ejemplo para crear un ItemMenu que irá en el [MenuLateral] que necesita de token
///
/// ```dart
///     ItemMenu(Icons.account_circle_rounded, Rutas.UsuarioNuevo,
///        traduce: (traduce) {
///      return traduce.nuevoUsuario;
///    }),
/// ```
///
/// Ejemplo para crear un ItemMenu que ejecuta solo accion, en este caso no necesita el token
///
/// ```dart
///    // Cierra sesion
///    ItemMenu(Icons.logout_rounded, MyApp.cierraSesion, necesitaToken: false,
///         funcionTraduce: (traduce) {
///       return traduce.cerrarSesion;
///    }),
/// ```
///
///
// ignore: must_be_immutable
class ItemMenu extends StatelessWidget {
  ItemMenu(
    this.icon,
    this.accion, {
    Key? key,
    required this.funcionTraduce,
    this.necesitaToken = true,
    this.colorActivo = const Color.fromARGB(255, 218, 243, 255),
    this.colorSeleccionado = PaletaColores.colorVerde,
  }) : super(key: key);

  final dynamic icon;
  final String Function(AppLocalizations) funcionTraduce;
  final dynamic accion;
  final necesitaToken;
  final Color colorActivo;
  final Color colorSeleccionado;

  bool _seleccionat = false;

  /*esSeleccionado(dynamic accio) {
    _seleccionat = this.accion == accio;
  }*/

  @override
  Widget build(BuildContext context) {
    final ModalRoute mr = ModalRoute.of(context)!;
    final rutaActual = mr.settings.name;
    final objArgs = mr.settings.arguments;
    String? _token;

    if (objArgs != null && objArgs is ArgumentsToken) {
      final args = objArgs;
      _token = args.token;
    }

    final _seleccionat = this.accion == rutaActual;

    final bool itemTieneToken = _token != null;

    // el item de menú se encuentra activo si no necesita token la págína
    // que tiene que abrir o si necesita token i se ha obtenido el _token
    bool enabled = !necesitaToken || necesitaToken && itemTieneToken;
    return Card(
      // Color de fondo en funció de si se encuetra activo o no seleccionado
      color: enabled
          ? _seleccionat
              //  Color Seleccionado
              ? colorSeleccionado
              //  Color Activo
              : colorActivo
          //  Color deshabilitado
          : Colors.grey[100],
      child: ListTile(
        enabled: enabled,
        leading: icon is Icon ? icon : Icon(icon),
        title: Text(funcionTraduce(AppLocalizations.of(context)!),
            style: Theme.of(context).textTheme.headline6!.copyWith(
                //Color de texto si está activo o no
                color: enabled ? null : Theme.of(context).disabledColor)),
        selected: _seleccionat,
        onTap: () {
          if (_seleccionat) {
            // Cerramos el menu abierto
            Navigator.pop(context);
          } else {
            //Realizamos la navegación
            if (accion is String) {
              // Siguiente pantalla
              vesA(accion, context,
                  // Pasamos los argumentos
                  arguments: objArgs);
            } else {
              // o la acción que se pase
              accion(context);
            }
          }
        },
      ),
    );
  }
}
