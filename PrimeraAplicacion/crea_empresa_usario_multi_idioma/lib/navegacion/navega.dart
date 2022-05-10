import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:crea_empresa_usario/widgets/esperando_servidor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/menu_lateral.dart';
import 'package:crea_empresa_usario/pantallas/login.dart';
import 'package:crea_empresa_usario/pantallas/nueva_empr.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/pantallas/opciones_config.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

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
  //final String? token;

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
              actions: routeSettings.name == Rutas.rutas['IniciaLogin']
                  ? [LanguageDropDown().getDropDown(context)]
                  : null,
            ),

            //  Separamos el contenido principal en otro widget
            body:
                // Obtenemos el constructor de wiggets y le llamamos
                Rutas.constructoresWidgets[widget.claveConstructor]!(_tok),
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
  return vesA(Rutas.rutas['IniciaLogin']!, context, arguments: arguments);
}

/// Cómo su nombre indica cargará la pantalla de [EmpresaNueva]
/// utilizando el método [vesA]
Future<T?> aEmpresaNueva<T extends Object?>(BuildContext context,
    {Object? arguments}) {
  return vesA(Rutas.rutas['EmpresaNueva']!, context, arguments: arguments);
}

/// Cómo su nombre indica cargará la pantalla de [UsuarioNuevo]
/// utilizando el método [vesA]
Future<T?> aUsuarioNuevo<T extends Object?>(BuildContext context,
    {Object? arguments}) {
  return vesA(Rutas.rutas['UsuarioNuevo']!, context, arguments: arguments);
}

/// Metodo que cargará la ruta indicada y vaciará el historial anterior
/// Pasando los argumentos
Future<T?> vesA<T extends Object?>(String ruta, BuildContext context,
    {Object? arguments}) {
  return Navigator.of(context)
      .pushNamedAndRemoveUntil(ruta, (route) => false, arguments: arguments);
}

/// Clase que contiene las diferentes rutas de las pantallas que vamos a presentar
/// Junto con los [constructoresWidgets] que será utilizados parar cargar
/// las diferentes pantallas de la aplicación
class Rutas {
  static final Map<String, String> rutas = <String, String>{
    'IniciaLogin': '/Login',
    'EmpresaNueva': '/EmpresaNueva',
    'UsuarioNuevo': '/UsuarioNuevo',
    'Configuracion': 'Configuracion/'
  };

  /// Mapa compuesto por una cadena que identifia a la función constructora de widgets
  /// que se mostraran la pantalla
  ///
  /// ejemplo tomado de: https://github.com/flutter/flutter/issues/17766
  static Map<String, Widget Function(String?)> constructoresWidgets =
      <String, Widget Function(String?)>{
    Rutas.rutas['IniciaLogin']!: (token) => Login(),
    Rutas.rutas['EmpresaNueva']!: (token) => NuevaEmpresa(
          token: token!,
        ),
    Rutas.rutas['UsuarioNuevo']!: (token) => NuevoUsuario(
          token: token!,
        ),
    Rutas.rutas['Configuracion']!: (token) => ConfigOpciones(token: token!),
  };
}

/// Clase utilizada para mostrar la Pantalla de [Login] extiende a la clase [PantallasMenu]
/// con un widget para el título de la [AppBar].
///
/// Necesita el parámetro [AppLocalizations]traduce para poner la traducción adecuada del título
///
/// Aunque no indiquemos en el parámetro opcional [PantallasMenu.conToken]
/// esta pantalla siempre se carga
class Identificate extends PantallasMenu {
  Identificate(AppLocalizations traduce, {Key? key})
      : super(
            Wrap(
              children: [
                Text(traduce.iniciaSesion),
                SizedBox(width: 10),
                Icon(Icons.login_rounded),
              ],
            ),
            conToken: false,
            menuLateral: false,
            key: key,
            claveConstructor: Rutas.rutas['IniciaLogin']!);
}

/// Clase utilizada para mostrar la Pantalla de [NuevaEmpresa] extiende a la clase [PantallasMenu]
/// Cargará la pantalla de [NuevaEmpresa] porque asi lo indicamos en [claveConstructor]
/// con un widget [Text] para el título
///
/// Por defecto le decimos que incluya un menu lateral y que requiere de [_token]
///
/// Necesita el parámetro [AppLocalizations]traduce para poner la traducción adecuada del título
///
class EmpresaNueva extends PantallasMenu {
  EmpresaNueva(BuildContext context, AppLocalizations traduce, {Key? key})
      : super(Text(traduce.nuevaEmpresa),
            key: key, claveConstructor: Rutas.rutas['EmpresaNueva']!);
}

/// Clase utilizada para mostrar la Pantalla de [NuevoUsuario] extiende a la clase [PantallasMenu]
/// Cargará la pantalla de [NuevoUsuario] porque asi lo indicamos en [claveConstructor]
/// con un widget [Text] para el título
///
/// Por defecto le decimos que incluya un menu lateral y que requiere de [_token]
///
/// Necesita el parámetro [AppLocalizations]traduce para poner la traducción adecuada del título
///
class UsuarioNuevo extends PantallasMenu {
  UsuarioNuevo(BuildContext context, AppLocalizations traduce, {Key? key})
      : super(Text(traduce.nuevoUsuario),
            key: key, claveConstructor: Rutas.rutas['UsuarioNuevo']!);
}

/// Clase utilizada para mostrar la Pantalla de [ConfigOpciones] extiende a la clase [PantallasMenu]
/// Cargará la pantalla de [ConfigOpciones] porque asi lo indicamos en [claveConstructor]
/// con un widget [Text] para el título
///
/// Por defecto le decimos que incluya un menu lateral y que requiere de [_token]
///
/// Necesita el parámetro [AppLocalizations]traduce para poner la traducción adecuada del título
///
class OpcionesConfig extends PantallasMenu {
  OpcionesConfig(BuildContext context, AppLocalizations traduce, {Key? key})
      : super(Text(traduce.configuracion),
            key: key, claveConstructor: Rutas.rutas['Configuracion']!);
}
