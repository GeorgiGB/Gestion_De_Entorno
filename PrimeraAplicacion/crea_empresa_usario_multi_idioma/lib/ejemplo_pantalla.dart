import 'package:flutter/material.dart';
import 'main.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

/// Ejemplo de cómo introducir un [Widget] en la estructura de pantallas
/// de la aplicación.
/// - En el wiget que queramos introducir deberá obligatoriamente un identificador
///   [id] único si no fuera así la aplicación lanzará un error por lo que
///   no estamos obligados a saber el [id] de los demás widgets
///
/// - Ahora, en el [MyApp._inicializaNavegacion] añadimos el siguiente código:
///   ```dart
///     // Inicializamos EjemploPantalla
///        MyApp._addruta(
///            EjemploPantalla.id,
///            Navega(EjemploPantalla.id,
///                titulo: (AppLocalizations traduce) {
///                  return traduce.nuevaEmpresa;
///                },
///                constructor: (token) => EjemploPantalla(token: token!),
///                itemMenu: IconTraduce(
///                  Icons.add_business_rounded,
///                  traduce: (traduce) {
///                    return traduce.ejemploCambiaNombre;
///                  },
///                )));
///   ```
/// - Ahora cambia el nombre de clase **EjemploPantalla** por el nombre de clse que escojas
///
/// ## Más ejemplos en el fichero ComoCrearRutas.md
class EjemploPantalla extends StatefulWidget {
  /// Identificador único, cambia el id, 'EjemploCambiaNombreIdentificador',
  /// por otro más apropiado.
  static const String id = 'EjemploCambiaNombreIdentificador';

  const EjemploPantalla({Key? key, required this.token}) : super(key: key);
  final String? token;
  @override
  State<EjemploPantalla> createState() => _EjemploPantallaState();
}

class _EjemploPantallaState extends State<EjemploPantalla> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            AppLocalizations.of(context)!.ejemploCambiaNombre,
          )
        ],
      )),
    );
  }
}
