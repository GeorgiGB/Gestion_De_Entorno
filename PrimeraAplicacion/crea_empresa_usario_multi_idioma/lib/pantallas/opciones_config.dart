import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/widgets/labeled_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:crea_empresa_usario/preferencias/preferencias.dart'
    as Preferencias;

import '../globales.dart' as globales;

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Constantes donde se guarda el idoma escogido y desde donde actualizamos

class ConfigOpciones extends StatefulWidget {
  const ConfigOpciones({Key? key, required this.token}) : super(key: key);
  final String token;

  @override
  State<ConfigOpciones> createState() => _ConfigOpcionesState();
}

class _ConfigOpcionesState extends State<ConfigOpciones> {
  late AppLocalizations traduce;
  bool guardaSesion = false;

  // Lista de comandos
  List<List<Widget>> comandos = [[]];

  @override
  void initState() {
    // Activamos el campo Guardar sesion?
    Preferencias.getSesion(Preferencias.mantenSesion).then((value) {
      globales.debug(value ?? 'vacio');
      setState(() {
        guardaSesion = value == null
            ? false
            : value.isNotEmpty && value == Preferencias.guardar;
        MyApp.guardaSesion(guardaSesion ? widget.token : null);
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
        padding: EdgeInsets.only(top: 5),
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
          // Mientras este activo
          // No permitira al usuario escribir una contraseña
          value: guardaSesion,
          onChanged: (bool? value) {
            setState(() {
              guardaSesion = value!;
              // Guardamos sesión?
              MyApp.guardaSesion(guardaSesion ? widget.token : null);
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
              //  Botones Empresa y Usuarios
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

  /// Al pulsar en un botón lo que hará es mostrar el formulario que hayamos seleccionado
  _cargaOpcion(int op) {
    globales.debug(widget.token);
    if (op == 0) {
      // Pantalla NuevaEmpresa
      aEmpresaNueva(context);
    } else if (op == 1) {
      // Pantalla NuevoUsuario
      aUsuarioNuevo(context);
    }
  }
}
