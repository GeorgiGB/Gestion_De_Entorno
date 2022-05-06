import 'package:crea_empresa_usario/navegacion/maindrawer.dart';
import 'package:crea_empresa_usario/pantallas/escoge_opciones.dart';
import 'package:crea_empresa_usario/pantallas/login.dart';
import 'package:crea_empresa_usario/pantallas/nueva_empr.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/pantallas/opciones_config.dart';
import 'package:crea_empresa_usario/pantallas/sesion_activa.dart';
import 'package:crea_empresa_usario/widgets/esperando_servidor.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

class Rutas {
  static String Identificate = '/';
  static String Opciones = '/Opciones';
  static String EmpresaNueva = '/EmpresaNueva';
  static String UsuarioNuevo = '/UsuarioNuevo';
  static String FiltrosUsuario = '/UsuarioNuevo/FiltrosUsuario';
  static String SesionActiva = '/SesionActiva';
  static String Configuracion = '/Configuracion';
}

vaciaNavegacionYCarga(BuildContext context,
    {required Widget Function(BuildContext) builder}) {
  if (Navigator.canPop(context)) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: builder),
      (Route<dynamic> route) => false,
    );
  } else {
    Navigator.push(context, MaterialPageRoute(builder: builder));
  }
}

Widget noLogin(BuildContext context) {
  Future.delayed(
    Duration(milliseconds: 1),
    () {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    },
  );
  return Esperando.esperandoA(
      AppLocalizations.of(context)!.esperandoAlServidor);
}

aLogin(BuildContext context) {
  vesA(Rutas.Identificate, context);
}

aEmpresaNueva(BuildContext context) {
  vesA(Rutas.EmpresaNueva, context);
}

aUsuarioNuevo(BuildContext context) {
  vesA(Rutas.UsuarioNuevo, context);
}

aOpciones(BuildContext context) {
  vesA(Rutas.Opciones, context);
}

vesA(String ruta, BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil(ruta, (route) => false);
}

popAndPush(BuildContext context,
    {required Widget Function(BuildContext) builder}) {
  // Eliminamos la página actual del historial de Navigator
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
  // Cargamos la página de NuevaEmpresa
  Navigator.push(context, MaterialPageRoute(builder: builder));
}

/// Clase abstracta que sirve de base para todas las pantalla muestren o no el
/// menú lateral [menuLateral].
/// Si se muestra el [menuLateral] y no añadimos un token lanzará un error.
/// Requiere que le pasemos el parámetro AppLocalizations [traduce]
abstract class PantallasMenu extends StatelessWidget {
  const PantallasMenu(Widget this.titulo,
      {Key? key, this.token, required this.wgt, this.menuLateral = true})
      : super(key: key);

  /// Titulo a mostrar en el [AppBar]
  final Widget titulo;

  /// Necesario para poder cerrar la sesión
  final String? token;

  /// El widget a cargar que tendrá una [AppBar] con título y opcional el [menuLateral]
  final Widget wgt;

  /// Indica si se va a mostrar el menú lateral.
  final bool menuLateral;

  @override
  Widget build(BuildContext context) {
    // Es la base para las traducciones de los textos localizados
    final AppLocalizations traduce = AppLocalizations.of(context)!;

    // Constuctor del widget
    return Scaffold(
      drawer: menuLateral ? MainDrawer(traduce, token!) : null,
      appBar: AppBar(
        title: titulo,
      ),
      //  Separamos el contenido principal en otro widget
      body: wgt,
    );
  }
}

class Identificate extends Pantallas {
  Identificate({Key? key, required AppLocalizations traduce})
      : super(Text(traduce.identifica), key: key, wgt: Login());
}

/// Clase abstracta que extiende [PantallasMenu] y sirve de base para las
/// pantallas sin menú lateral. Al no tener menú lateral
abstract class Pantallas extends PantallasMenu {
  const Pantallas(Widget titulo, {Key? key, required Widget wgt})
      : super(titulo, key: key, wgt: wgt, menuLateral: false);
}

class Opciones extends PantallasMenu {
  Opciones(BuildContext context,
      {Key? key, required AppLocalizations traduce, required token})
      : super(Text(traduce.escogeOpcion),
            key: key, token: token, wgt: EscogeOpciones(token: token));
}

class EmpresaNueva extends PantallasMenu {
  EmpresaNueva(BuildContext context,
      {Key? key, required AppLocalizations traduce, required token})
      : super(Text(traduce.nuevaEmpresa),
            key: key, token: token, wgt: NuevaEmpresa(token: token));
}

class UsuarioNuevo extends PantallasMenu {
  UsuarioNuevo(BuildContext context,
      {Key? key, required AppLocalizations traduce, required token})
      : super(Text(traduce.nuevoUsuario),
            key: key, token: token, wgt: NuevoUsuario(token: token));
}

class SesionAtcv extends PantallasMenu {
  SesionAtcv(BuildContext context, AppLocalizations traduce,
      {Key? key, required token})
      : super(Text(traduce.sesionActiva),
            key: key, token: token, wgt: SesionActiva(token: token));
}

class OpcionesConfig extends PantallasMenu {
  OpcionesConfig(BuildContext context, AppLocalizations traduce,
      {Key? key, required token})
      : super(Text(traduce.configuracion),
            key: key, token: token, wgt: ConfigOpciones(token: token));
}
