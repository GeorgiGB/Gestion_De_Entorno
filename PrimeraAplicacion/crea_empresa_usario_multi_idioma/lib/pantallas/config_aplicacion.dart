import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/pantalla.dart';
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
// Fin imports multi-idioma ----------------

class ConfigAplicacion extends StatefulWidget {
  static const String id = 'ConfigAplicacion';

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
