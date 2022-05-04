import 'package:crea_empresa_usario/navegacion/maindrawer.dart';
import 'package:crea_empresa_usario/pantallas/escoge_opciones.dart';
import 'package:crea_empresa_usario/pantallas/login.dart';
import 'package:crea_empresa_usario/pantallas/nueva_empr.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/pantallas/yellow_bird.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

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
  return Container();
}

aLogin(BuildContext context, AppLocalizations traducc) {
  //vaciaNavegacionYCarga(context, builder: (context) => Login(traducc));
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
/// Rquiere que le pasemos el parámetro AppLocalizations [traduce]
abstract class PantallasMenu extends StatelessWidget {
  const PantallasMenu(Widget this.titulo,
      {Key? key,
      required this.traduce,
      required this.wgt,
      this.menuLateral = true})
      : super(key: key);

  /// Titulo a mostrar en el [AppBar]
  final Widget titulo;

  /// El widget a cargar que tendrá una [AppBar] con título y opcional el [menuLateral]
  final Widget wgt;

  /// Es la base para las traducciones de los textos localizados
  final AppLocalizations traduce;

  /// Indica si se va a mostrar el menú lateral.
  final bool menuLateral;

  @override
  Widget build(BuildContext context) {
    // Constuctor del widget
    return Scaffold(
      drawer: menuLateral ? const MainDrawer() : null,
      appBar: AppBar(
        title: titulo,
      ),
      //  Separamos el contenido principal en otro widget
      body: wgt,
    );
  }
}

/// Clase abstracta que extiende [PantallasMenu] y sirve de base para las
/// pantallas sin menú lateral
abstract class Pantallas extends PantallasMenu {
  const Pantallas(Widget titulo,
      {Key? key, required AppLocalizations traduce, required Widget wgt})
      : super(titulo, key: key, traduce: traduce, wgt: wgt, menuLateral: false);
}

class Identificate extends Pantallas {
  Identificate(Function(String?) hola,
      {Key? key, required AppLocalizations traduce})
      : super(Text(traduce.identifica),
            traduce: traduce, wgt: Login(traduce, hola));
}

class Opciones extends PantallasMenu {
  Opciones(Function(String) hola, BuildContext context,
      {Key? key, required AppLocalizations traduce, required token})
      : super(Text(traduce.escogeOpcion),
            traduce: traduce,
            wgt: token == null
                ? noLogin(context)
                : EscogeOpciones(token: token));
}

class EmpresaNueva extends PantallasMenu {
  EmpresaNueva(BuildContext context,
      {Key? key, required AppLocalizations traduce, required token})
      : super(Text(traduce.nuevaEmpresa),
            traduce: traduce,
            wgt: token == null ? noLogin(context) : NuevaEmpresa(token: token));
}

class UsuarioNuevo extends PantallasMenu {
  UsuarioNuevo(BuildContext context,
      {Key? key, required AppLocalizations traduce, required token})
      : super(Text(traduce.nuevoUsuario),
            traduce: traduce,
            wgt: token == null ? noLogin(context) : NuevoUsuario(token: token));
}

class Sesion extends Pantallas {
  const Sesion({Key? key, required AppLocalizations traduce})
      : super(const Text("Pardal groc"),
            key: key, wgt: const YellowBird(), traduce: traduce);
}
