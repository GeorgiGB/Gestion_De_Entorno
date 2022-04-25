import 'package:crea_empresa_usario/nuevo_usua.dart';
import 'package:flutter/material.dart';
import 'globales.dart' as globales;
import 'nueva_empr.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Constantes donde se guarda el idoma escogido y desde donde actualizamos

class creacion_empre_usua extends StatefulWidget {
  const creacion_empre_usua(
      {Key? key, required this.token, required this.usu_cod})
      : super(key: key);
  final String token;
  final String usu_cod;
  @override
  State<creacion_empre_usua> createState() => _creacion_empre_usuaState();
}

class _creacion_empre_usuaState extends State<creacion_empre_usua> {
  late AppLocalizations traducciones;
  @override
  Widget build(BuildContext context) {
    globales.debug("usu_cod: " + widget.usu_cod.toString());
    traducciones = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(traducciones.escogeOpcionParaCrear),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            traducciones.crea,
          ),
          ElevatedButton(
            child: Text(traducciones.empresa),
            onPressed: () {
              _cargaOpcion(0);
            },
          ),
          ElevatedButton(
            child: Text(traducciones.usuario),
            onPressed: () {
              _cargaOpcion(1);
            },
          ),
        ],
      )),
    );
  }

  // Al elegir un boton lo que hara es mostrar el formulario que nosotros hayamos seleccionado
  _cargaOpcion(int op) {
    globales.debug(widget.token);
    if (op == 0) {
      globales.muestraToast(context, traducciones.cargandoEmpresa);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NuevaEmpresa(
                    token: widget.token,
                  )));
    } else if (op == 1) {
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
