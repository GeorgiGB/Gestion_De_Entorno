import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/nuevo_usua.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart' as Servidor;
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import 'globales.dart' as globales;
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

  // Lista de comandos
  List<List<Widget>> comandos = [[]];
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

    //  Añadimos los comandos de añadir empresa / usuario
    creaComando2(
      traducciones.sesionActiva,
      [
        ElevatedButton(
          child: Text(traducciones.cerrarSesion),
          onPressed: () {
            _cerrarSesion();
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

  bool cerrandoSesion = false;
  void _cerrarSesion() {
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
