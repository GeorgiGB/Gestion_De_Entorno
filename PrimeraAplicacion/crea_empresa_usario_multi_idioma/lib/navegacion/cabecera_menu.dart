import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crea_empresa_usario/colores.dart';
// Fin imports multi-idioma ----------------

/// Este widget crea la cabecera del menú
/// Muestra un título, el icono para cerrar el menu y un desplegable para
/// cambiar de idioma
///
/// El título lo obtiene a partir de la funcion anónima [traduce]
/// que se pasa como parámetro un [AppLocalizations]. De esta forma podemos poner el
/// título que queramos desde el lugar que lo integremos.
///
/// Ejemplo para crear la cabecera lateral:
/// ```dart
/// CabeceraMenuLat(traduce: (traduce) {
///      return traduce.nombreApp;
///    })
/// ```
class CabeceraMenu extends StatelessWidget {
  CabeceraMenu({
    Key? key,
    required this.traduce,
  }) : super(key: key);

  final String Function(AppLocalizations) traduce;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      // Barra lateral
      child: DrawerHeader(
        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 8.0),
        //  En un BoxDecoration indicamos los colores personalizados que queremos que tenga el programa
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: PaletaColores.listaColores1)),
        margin: EdgeInsets.zero,
        child: Stack(children: [
          Positioned(
              child: Text(traduce(AppLocalizations.of(context)!),
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: PaletaColores.colorGrisOscuro))),
          Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                  icon: Icon(Icons.close),
                  color: PaletaColores.colorGrisOscuro,
                  onPressed: () => Navigator.of(context).pop())),
          Positioned(
            bottom: 0,
            right: 0,
            child: LanguageDropDown().getDropDown(context),
          ),
        ]),
      ),
    );
  }
}
