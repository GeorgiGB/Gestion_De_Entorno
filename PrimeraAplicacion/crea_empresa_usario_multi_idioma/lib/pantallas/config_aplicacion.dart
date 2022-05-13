import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/widgets/labeled_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:crea_empresa_usario/preferencias/preferencias.dart'
    as Preferencias;
import 'package:crea_empresa_usario/navegacion/rutas_pantallas.dart';
import 'package:crea_empresa_usario/navegacion/item_menu_lateral.dart';
import 'package:crea_empresa_usario/ejemplo_pantalla.dart';

import '../globales.dart' as globales;

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Constantes donde se guarda el idoma escogido y desde donde actualizamos

// Imports multi-idioma ---------------------
// Fin imports multi-idioma ----------------

/// En este fichero se encuentra un plantilla básica que sigue la estructura genérica
/// para crear una pantalla que mantenga la estructura básica de la aplicación.
///
///
/// Más información en [PantallaCambiarNombre] <-- este no se ha de cambiar
class PantallaConfigAplicacion extends PantallasMenu {
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
    ruta = Ruta(id, nombreRuta, (token) => ConfigAplicacion(token: token));
    //Pasamos valores configuración de pantalla
    cfgPantalla = PantallasConfig(
        conToken: conToken,
        conItemMenu: conItemMenu,
        menuLateral: menuLateral,

        // Añade Ejemplo, más opciones sobre [ItemMenu] en su archivo
        // correspondiente
        itemMenu: ItemMenu(Icons.settings_rounded, ruta.hacia,
            necesitaToken: conToken, funcionTraduce: (traduce) {
          return traduce.configuracion;
        }));
  }

  static Future<T?> voy<T extends Object?>(BuildContext context,
      {Object? arguments}) {
    return vesA(ruta.hacia, context, arguments: arguments);
  }

  PantallaConfigAplicacion(BuildContext context, {Key? key})
      : super(Text(AppLocalizations.of(context)!.configuracion), ruta.id,
            key: key,
            menuLateral: cfgPantalla.menuLateral,
            conToken: cfgPantalla.conToken);
}

// Aquí finalizan los elementos básicos de un wiget que siga la estructura básica de la aplicación

class ConfigAplicacion extends StatefulWidget {
  ConfigAplicacion({Key? key, token}) : super(key: key) {
    _token = token;
  }
  late final String? _token;

  @override
  State<ConfigAplicacion> createState() => _ConfigAplicacionState();
}

class _ConfigAplicacionState extends State<ConfigAplicacion> {
  late AppLocalizations traduce;
  bool guardaSesion = false;

  // Lista de comandos
  List<List<Widget>> comandos = [[]];

  @override
  void initState() {
    super.initState();
    // Activamos el campo Guardar sesion?
    Preferencias.getSesion(Preferencias.mantenSesion).then((value) {
      // globales.debug(value ?? 'vacio');
      setState(() {
        guardaSesion = value == null
            ? false
            : value.isNotEmpty && value == Preferencias.guardar;
        MyApp.mantenLaSesion(guardaSesion, widget._token);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    traduce = AppLocalizations.of(context)!;

    comandos.clear();
    creaComandos();

    return Scaffold(
      /*appBar: AppBar(
        title: Text(traducciones.escogeOpcion),
      ),*/
      body: ListView.builder(
        //  Construimos la lista de widgets dinámicamente
        //  Aquí viene los diferetes botones de comandos
        padding: const EdgeInsets.only(top: 5),
        itemCount: comandos.length,
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //SizedBox(height: 20),
              Column(children: comandos[index]),
              //Divider(),
            ],
          );
        },
      ),
    );
  }

  creaComandos() {
    //  Añadimos el comando del idioma
    creaComando2(
      traduce.idioma,
      [
        LanguageDropDown().getDropDown(context),
      ],
    );
    //  Añadimos el comando del idioma
    creaComando2(
      traduce.sesion,
      [
        // Guardamos Sesión?
        LabeledCheckbox(
          label: traduce.guardaSesion,
          chekBoxIzqda: false,
          textStyle: globales.estiloNegrita_16,
          enabled: widget._token != null,
          // Mientras este activo
          // No permitira al usuario escribir una contraseña
          value: guardaSesion,
          onChanged: (bool? value) {
            setState(() {
              guardaSesion = value!;

              // Mantenemos sesión?
              MyApp.mantenLaSesion(guardaSesion, widget._token);

              // Guardamos sesión?
              if (guardaSesion && widget._token != null)
                MyApp.setToken(context, widget._token!);
            });
          },
        ),
      ],
    );
  }

  ///  Crea un Widget de comandos con titulos a partir de una lista
  ///  de botones que continene su comando
  creaComando2(String titulo, List<Widget> lista) {
    comandos.add([
      Card(
        margin: EdgeInsets.all(10.0),
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    titulo,
                    style: globales.estiloNegrita_16,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(spacing: 15, children: lista),
              )
            ],
          ),
        ),
      )
    ]);
  }
}
