import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/preferencias/preferencias.dart'
    as Preferencias;
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/labeled_checkbox.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import '../globales.dart' as globales;
import 'nueva_empr.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Constantes donde se guarda el idoma escogido y desde donde actualizamos

class EscogeOpciones extends StatefulWidget {
  const EscogeOpciones({Key? key, required this.token}) : super(key: key);
  final String token;
  @override
  State<EscogeOpciones> createState() => _EscogeOpcionesState();
}

class _EscogeOpcionesState extends State<EscogeOpciones> {
  late AppLocalizations traducciones;

  /*Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }*/

  bool isChecked = false;

  // Lista de comandos
  List<List<Widget>> comandos = [[]];

  @override
  void initState() {
    // Activamos el campo Guardar sesion?
    Preferencias.getSesion(Preferencias.mantenSesion).then((value) {
      setState(() {
        isChecked = value == null
            ? false
            : value.isNotEmpty && value == Preferencias.guardar;
        _guardaSesion(isChecked);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    traducciones = AppLocalizations.of(context)!;

    comandos.clear();
    creaComandos();

    return Scaffold(
      appBar: AppBar(
        title: Text(traducciones.escogeOpcion),
      ),
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
//  Añadimos los comandos de añadir empresa / usuario
    creaComando2(
      traducciones.anyade,
      [
        ElevatedButton(
          child: Text(traducciones.empresa),
          onPressed: () {
            //  Acción a realizar
            _cargaOpcion(0);
          },
        ),
        ElevatedButton(
          child: Text(traducciones.usuario),
          onPressed: () {
            //  Acción a realizar
            _cargaOpcion(1);
          },
        ),
      ],
    );

    //  Añadimos el comando de cerrar sessión
    creaComando2(
      traducciones.sesionActiva,
      [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Guardamos Sesión?
            //Text("Guardar"),
            LabeledCheckbox(
                label: "Guardar",
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                // Mientras este activo
                // No permitira al usuario escribir una contraseña
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value!;
                    Preferencias.setPreferencias(Preferencias.mantenSesion,
                        isChecked ? Preferencias.guardar : '');
                    _guardaSesion(isChecked);
                  });
                }),
            // Fina guardar sesión
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
              child: Text(traducciones.cerrarSesion),
              onPressed: () {
                _cerrarSesion();
              },
            ),
          ],
        ),
      ],
    );
    //  Añadimos el comando del idioma
    creaComando2(
      traducciones.idioma,
      [
        LanguageDropDown().getDropDown(context),
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
      // EnCualquierLugar.muestraSnack(context, traducciones.cargandoEmpresa);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NuevaEmpresa(
                    token: widget.token,
                  )));
    } else if (op == 1) {
      // Pantalla NuevoUsuario
      // EnCualquierLugar.muestraSnack(context, traducciones.cargandoUsuario);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NuevoUsuario(
            token: widget.token,
          ),
        ),
      );
    }
  }

  void _guardaSesion(bool guarda) {
    Preferencias.setPreferencias(
        Preferencias.claveSesion, guarda ? widget.token : '');
  }

  bool cerrandoSesion = false;
  void _cerrarSesion() {
    _guardaSesion(false);
    if (cerrandoSesion) {
      EnCualquierLugar()
          .muestraSnack(context, traducciones.esperandoRespuestaServidor);
    } else {
      cerrandoSesion = true;
      Servidor.cerrarSesion(context, token: widget.token)
          .whenComplete(() => aLogin(context));
    }
  }
}
