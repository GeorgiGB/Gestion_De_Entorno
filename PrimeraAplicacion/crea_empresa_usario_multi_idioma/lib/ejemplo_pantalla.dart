import 'package:flutter/material.dart';
import 'navegacion/navega.dart';
import 'navegacion/rutas_pantallas.dart';
import 'navegacion/item_menu_lateral.dart';
import 'navegacion/menu_lateral.dart';
import 'main.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

/// En este fichero se encuentra un plantilla básica que sigue la estructura genérica
/// para crear una pantalla que mantenga la estructura básica de la aplicación.
///
/// Los pasos a seguir son:
/// Crear una clase que extienda a la clase abstracta [PantallasMenu]
/// que contenga:
/// - Un identificador 'id' [PantallasMenu.id] único con el nombre del widget que
///   queremos cargar como pantalla.
///
/// - Un método éstatico [PantallaCambiarNombre.preparaNavegacion]
///
/// - El método éstatico [PantallaCambiarNombre.voy] quien carga la pantalla
///
/// - Y El constructor de la clase [PantallaCambiarNombre]
///
/// - Añadimos la ruta y la llamada al constructor de la clase [PantallaCambiarNombre] en
///   el parámetro el parámetro routes del constructor de la clase [MaterialApp]
///   que encontraremos en el fichero main.dart
///
/// Con todo esto sólo falta añadir la llamada del Llamar al método estatico [PantallaCambiarNombre.preparaNavegacion]
///
/// Más opciones en [PantallasMenu]
class PantallaCambiarNombre extends PantallasMenu {
  /// Cadena utilizada para crear las rutas de navegación
  /// Debe ser única ya que puede entrar en conflicto con las demás pantallas
  static late final Ruta ruta;
  static late final PantallasConfig cfgPantalla;

  ///añadir la ruta que será utilizada por el parámetro
  /// routes de la clase [MaterialApp] que encontraremos en el fichero main.dart
  /// Método encargado de preparar la navegación
  /// - id: el identificador del elemento de Navegación, debe ser único. Obligatorio
  /// - ruta: la cadena que identifica a la ruta, si no se pone se formará con el id
  /// - conToken: indica si para acceder a esta pantalla necesita el token de sesión. Opcional -> true
  /// - conItemMenu: nos pondrá un item de menú en lel menu lateral. Opcional -> true
  /// - menuLateral: si aparece el menú lateral en la pantalla. Opcional -> true
  static void preparaNavegacion(String id,
      {String? nombreRuta,
      bool conToken = true,
      bool conItemMenu = true,
      bool menuLateral = true}) {
    //
    ruta = Ruta(id, nombreRuta, (token) => CambiarNombre(token: token));
    //Pasamos valores configuración de pantalla
    cfgPantalla = PantallasConfig(
        conToken: conToken,
        conItemMenu: conItemMenu,
        menuLateral: menuLateral,

        // Añade Ejemplo, más opciones sobre [ItemMenu] en su archivo
        // correspondiente
        itemMenu: ItemMenu(Icons.abc_outlined, ruta.hacia,
            necesitaToken: conToken, funcionTraduce: (traduce) {
          return traduce.ejemploCambiaNombre;
        }));
  }

  static Future<T?> voy<T extends Object?>(BuildContext context,
      {Object? arguments}) {
    print('no puede ser');
    return vesA(ruta.hacia, context, arguments: arguments);
  }

  PantallaCambiarNombre(BuildContext context, {Key? key})
      : super(Text(AppLocalizations.of(context)!.ejemploCambiaNombre), ruta.id,
            key: key,
            menuLateral: cfgPantalla.menuLateral,
            conToken: cfgPantalla.conToken);
}

// Aquí finalizan los elementos básicos de un wiget que siga la estructura básica de la aplicación

class CambiarNombre extends StatefulWidget {
  const CambiarNombre({Key? key, required this.token}) : super(key: key);
  final String? token;
  @override
  State<CambiarNombre> createState() => _CambiarNombreState();
}

class _CambiarNombreState extends State<CambiarNombre> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text("Cambia por tu widget")],
      )),
    );
  }
}
