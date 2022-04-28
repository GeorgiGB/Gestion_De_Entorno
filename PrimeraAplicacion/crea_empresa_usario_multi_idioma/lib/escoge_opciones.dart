import 'package:crea_empresa_usario/nuevo_usua.dart';
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
  @override
  Widget build(BuildContext context) {
    traducciones = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(traducciones.escogeOpcion),
      ),
      body: SingleChildScrollView(
          //Previene BOTTOM OVERFLOWED
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    traducciones.anyade,
                    style: globales.estiloNegrita_16,
                  ),
                ],
              ),
              SizedBox(height: 15),
              // Botones Empresa y Usuarios
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    child: Text(traducciones.empresa),
                    onPressed: () {
                      _cargaOpcion(0);
                    },
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                    child: Text(traducciones.usuario),
                    onPressed: () {
                      _cargaOpcion(1);
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    traducciones.sesionActiva,
                    style: globales.estiloNegrita_16,
                  ),
                ],
              ),
              SizedBox(height: 15),
              // Botones Empresa y Usuarios
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    child: Text(traducciones.empresa),
                    onPressed: () {
                      _cerrarSesion();
                    },
                  ),
                ],
              ),
            ],
          )),
    );
  }

  // Al pulsar en un botón lo que hará es mostrar el formulario que hayamos seleccionado
  _cargaOpcion(int op) {
    globales.debug(widget.token);
    if (op == 0) {
      // Pantalla NuevaEmpresa
      globales.muestraToast(context, traducciones.cargandoEmpresa);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NuevaEmpresa(
                    token: widget.token,
                  )));
    } else if (op == 1) {
      // Pantalla NuevoUsuario
      globales.muestraToast(context, traducciones.cargandoUsuario);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NuevoUsuario(
            ust_token: widget.token,
          ),
        ),
      );
    }
  }

}

void _cerrarSesion() {
}
