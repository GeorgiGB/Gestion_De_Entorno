import 'package:crea_empresa_usario/pantallas/login.dart';
import 'package:crea_empresa_usario/pantallas/yellow_bird.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'Maindrawer.dart';

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

aLogin(BuildContext context, AppLocalizations traducc) {
  vaciaNavegacionYCarga(context, builder: (context) => Login(traducc));
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
/// Rquiere que le pasemos el parámetro AppLocalizations [traducciones]
abstract class PantallasMenu extends StatelessWidget {
  const PantallasMenu(
      {Key? key,
      required this.traducciones,
      required this.wgt,
      this.menuLateral = true})
      : super(key: key);
  final Widget wgt;

  /// Es la base para las traducciones de los textos localizados
  final AppLocalizations traducciones;

  /// Indica si se va a mostrar el menú lateral.
  final bool menuLateral;

  @override
  Widget build(BuildContext context) {
    // Constuctor del widget
    return Scaffold(
        drawer: menuLateral ? const MainDrawer() : null,
        appBar: AppBar(
          title: Text(traducciones.identifica),
        ),
        //  Separamos el contenido principal en otro widget
        body: wgt);
  }
}

/// Clase abstracta que extiende [PantallasMenu] y sirve de base para las
/// pantallas sin menú lateral
abstract class Pantallas extends PantallasMenu {
  const Pantallas(
      {Key? key, required AppLocalizations traducciones, required Widget wgt})
      : super(
            key: key, traducciones: traducciones, wgt: wgt, menuLateral: false);
}

class Sesion extends Pantallas {
  const Sesion({Key? key, required AppLocalizations traducciones})
      : super(key: key, wgt: const YellowBird(), traducciones: traducciones);
}
