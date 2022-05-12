import 'package:crea_empresa_usario/colores.dart';
import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:crea_empresa_usario/widgets/esperando_servidor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/pantallas/login.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

import 'rutas.dart';
import 'menu_lateral.dart';

/// Clase abstracta que sirve de base para todas las pantalla muestren o no el
/// menú lateral [menuLateral]. Todas las pantallas mostrarán un [AppBar]
/// En caso de necesitar un token y no pasarlo nos redirige a la pantalla [Login]
///
///
/// La primera vez que se carga cualquier pantalla después de identificarnos
/// se mostrará el menú abierto
///
/// Los parámetros que se pasan són:
/// * [_token] por defecto null
/// * [conToken] por defecto su valor es true
/// * [claveConstructor] Obligatorio, es la clave para utilizar el constructor de la pantalla a mostrar.
/// * [menuLateral] booleano para indicar que queremos mostrar un menú lateral por defeto suvalor es true
///
class PantallasMenu extends StatefulWidget {
  PantallasMenu(this.titulo,
      {Key? key,
      this.conToken = true,
      required this.claveConstructor,
      this.menuLateral = true})
      : super(key: key);

  /// Utilizado para saber si ya hemos mostrado el menú lateral la primera vez
  /// que se carga una pantalla después de identificarnos y que contenga el menú lateral
  /// Al cerrar la sesión esta variable se pone a false desde la classe [MyApp]
  static bool abierto = false;

  /// Titulo a mostrar en el [AppBar]
  final Widget titulo;

  /// Necesario si la pantalla a cargar necesita token
  /// por defecto es null

  /// Indica si se va a mostrar el menú lateral.
  /// Por defecto true
  final bool menuLateral;

  /// Indica si se necesita un token la pantalla que vamos a cargar.
  ///  Por defecto true
  final bool conToken;

  /// Clave obligatoria para identificar al constructor de widget que mostrá la pantalla
  final String claveConstructor;

  ArgumentsToken? args;

  @override
  State<StatefulWidget> createState() => _PantallasMenuState();
}

class _PantallasMenuState extends State<PantallasMenu> {
  bool vesAlogin = false;
  // _scaffoldKey para obtener, posteriormente, el currentcontext
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _tok;

  @override
  void initState() {
    super.initState();
    //Añadimos una llamada al finalizar el estado inicial del widget
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // Añadimo una llamada cuando finaliza la creación
      // del widget y se presenta por pantalla
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        // El widget ya tiene creado el estado final y se presenta por pantall
        if (vesAlogin) {
          if (_scaffoldKey.currentContext != null) {
            // No hemos podido obtener el token nos vamos al wiget principal MyApp
            // y que decida
            MyApp.rutaSinToken(context);
          }
        } else if (widget.menuLateral &&
            !PantallasMenu.abierto &&
            _scaffoldKey.currentState != null) {
          // La primera vez que se carga cualquier pantalla después de identificarnos
          // se mostrará el menú abierto si tiene menulateral
          PantallasMenu.abierto = true;
          _scaffoldKey.currentState!.openDrawer();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenmos los argumentos que se pasan al cargar la ruta
    RouteSettings routeSettings = ModalRoute.of(context)!.settings;
    final objArgs = routeSettings.arguments;
    if (objArgs != null) {
      widget.args = objArgs as ArgumentsToken;
      _tok = widget.args!.token;
    }

    // si es un widget con token se ha de poner
    vesAlogin = widget.conToken && _tok == null;

    return vesAlogin

        // Necesita token y no tiene, cargamos un container
        // indicando que esperamos la carga
        ? Esperando.esperandoA(
            AppLocalizations.of(context)!.cargando,
            key: _scaffoldKey,
          )

        // Ahora podemos cargar la pantalla a mostrar;
        : Scaffold(
            key: _scaffoldKey,
            drawer: widget.menuLateral ? MenuLateral() : null,
            appBar: AppBar(
              title: widget.titulo,
              actions: routeSettings.name == Ruta.rutas['IniciaLogin']
                  ? [LanguageDropDown().getDropDown(context)]
                  : null,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                    gradient:
                        LinearGradient(colors: PaletaColores.listaColores)),
              ),
            ),

            //  Separamos el contenido principal en otro widget
            body:
                // Obtenemos el constructor de wiggets y le llamamos
                Ruta.constructoresWidgets[widget.claveConstructor]!(_tok),
          );
  }
}

// Clase utilizada para pasar el token a las diferentes rutas
class ArgumentsToken {
  final String token;
  ArgumentsToken(
    this.token,
  );
}

/// Cómo su nombre indica cargará la pantalla de [Login]
/// utilizando el método [vesA]
aLogin(BuildContext context, {Object? arguments}) {
  //PantallasMenu.abierto = false;
  return vesA(Ruta.rutas['IniciaLogin']!, context, arguments: arguments);
}

/// Cómo su nombre indica cargará la pantalla de [EmpresaNueva]
/// utilizando el método [vesA]
Future<T?> aEmpresaNueva<T extends Object?>(BuildContext context,
    {Object? arguments}) {
  return vesA(Ruta.rutas['EmpresaNueva']!, context, arguments: arguments);
}

/// Cómo su nombre indica cargará la pantalla de [UsuarioNuevo]
/// utilizando el método [vesA]
Future<T?> aUsuarioNuevo<T extends Object?>(BuildContext context,
    {Object? arguments}) {
  return vesA(Ruta.rutas['UsuarioNuevo']!, context, arguments: arguments);
}

/// Metodo que cargará la ruta indicada y vaciará el historial anterior
/// Pasando los argumentos
Future<T?> vesA<T extends Object?>(String ruta, BuildContext context,
    {Object? arguments}) {
  return Navigator.of(context)
      .pushNamedAndRemoveUntil(ruta, (route) => false, arguments: arguments);
}
