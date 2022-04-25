import 'package:flutter/material.dart';
import 'globales.dart' as globales;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

class NuevaEmpresa extends StatefulWidget {
  const NuevaEmpresa({Key? key, required this.token}) : super(key: key);
  final String token;
  @override
  State<NuevaEmpresa> createState() => _NuevaEmpresaState();
}

class _NuevaEmpresaState extends State<NuevaEmpresa> {
  final TextEditingController _emp_nombre = TextEditingController();
  final TextEditingController _emp_pwd = TextEditingController();
  final FocusNode _auto_contrasenaFocus = FocusNode();
  // Hace un check del boton para generar una contraseña automatica
  bool _emp_pwd_auto = true;
  // Cuando pulsamos el boton de crear empresa cambiara de estado
  // Indicando que la empresa se esta creado y asi no poder
  // Pulsar el boton de creacion mas de una vez por error
  bool esperandoNuevaEmpresa = false;
  late AppLocalizations traducciones;

  @override
  Widget build(BuildContext context) {
    traducciones = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(traducciones.empresaNueva),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            traducciones.nombreDeLaEmpresa,
          ),
          TextFormField(
            decoration:
                InputDecoration(hintText: traducciones.introduceElNombre),
            controller: _emp_nombre,
            onFieldSubmitted: (String value) {
              // Cuando pulsas enter pasas al siguiente campo
              FocusScope.of(context).requestFocus(_auto_contrasenaFocus);
            },
          ),
          Text(
            traducciones.contrasena,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(traducciones.generaContrasena),
                    ),
                    Expanded(
                      //
                      child: Checkbox(
                          // Mientras este activo
                          // No permitira al usuario escribir una contraseña
                          value: _emp_pwd_auto,
                          focusNode: _auto_contrasenaFocus,
                          onChanged: (bool? value) {
                            autoCheckBox(value!);
                          }),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Focus(
                  onFocusChange: (hasFocus) {
                    avisoContraManual(hasFocus);
                  },
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: traducciones.introduceLaContrasena),
                    controller: _emp_pwd,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,

                    // LLamamos a la funcion para mandar a la empresa
                    onFieldSubmitted: (String value) {
                      _crearEmpresa();
                    },
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            child: Text(traducciones.crear),
            onPressed: () {
              _crearEmpresa();
            },
          ),
        ],
      )),
    );
  }

  // Si el checkbox esta activo y el campo contraseña tiene datos
  // Se encargara de limpiar el campo contraseña

  autoCheckBox(bool value) {
    if (value) {
      _emp_pwd.clear();
    }
    setState(() {
      _emp_pwd_auto = value;
    });
  }

  // Si la casilla esta marcada no permitira la escritura en el campo de la contraseña
  // Y mostrara un aviso
  // globalizar funcion
  avisoContraManual(bool hasFocus) {
    if (hasFocus && _emp_pwd_auto) {
      FocusScope.of(context).requestFocus(_auto_contrasenaFocus);
      globales.muestraDialogo(context, traducciones.introContraDesmarcaCasilla);
    }
  }

  Future<void>? _crearEmpresa() async {
    String url = globales.servidor + '/crear_empresa';
    /* 
    Tenemos dos tipos de condiciones ya que se puede acceder de dos formas
    1. Rellenando el campo de nombre y contraseña.
    2. Rellenando el campo de nombre y pulsando el boton de autogenerado.
    
    Por lo tanto tenemos que comprobar si el botón no esta marcado y
    hemos introducido una contraseña. Y al revés, si hemos introducido un nombre 
    y hemos marcado el botón de autogenerado.
    */
    if ((_emp_nombre.text.isNotEmpty && _emp_pwd.text.isNotEmpty) ||
        (_emp_nombre.text.isNotEmpty && _emp_pwd_auto)) {
      if (esperandoNuevaEmpresa) {
        globales.muestraToast(context, traducciones.esperandoAlServidor);
      } else {
        globales.muestraToast(context, traducciones.empresaCreadaCorrectamente);
        esperandoNuevaEmpresa = true;
        // La informacion de la empresa
        String nom_empresa = _emp_nombre.text;
        String emp_pwd = _emp_pwd.text;
        try {
          // Añadir el nombre de la empresa y su contraseña
          globales.debug(_emp_nombre.text);
          globales.debug(_emp_pwd.text);
          globales.debug(widget.token);

          // Lanzamos la peticion Post al servidor
          var response = await http.post(
            Uri.parse(url),
            // Cabecera para enviar JSON con una autorizacion token
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer ' + widget.token
            },
            // Adjuntamos al body los datos en formato JSON
            body: jsonEncode(<String, String>{
              'emp_nombre': nom_empresa,
              'contrasena_autogenerada': _emp_pwd_auto.toString(),
              'emp_pwd': emp_pwd
            }),
          );
          // Hay que tener en cuenta si la contraseña es autogenerada
          // Adjuntar el token en la peticion.
          int status = response.statusCode;

          List<dynamic> lista = json.decode(response.body);
          if (status == 200) {
            globales.debug('Empresa_creada:' + lista[0]["msg"].toString());
          } else if (status == 403) {
            globales.muestraDialogo(context, lista[0]["msg_error"]);
          } else if (status == 500) {
            globales.muestraDialogo(context, response.body);
          } else {
            globales.debug(response.body);
          }

          esperandoNuevaEmpresa = false;
        } on http.ClientException catch (e) {
          globales.muestraDialogo(context, traducciones.servidorNoDisponible);
        } on Exception catch (e) {
          // Error no especificado
          globales.debug("Error no especificado: " + e.runtimeType.toString());
        }
      }
    } else {
      globales.muestraDialogo(context, traducciones.primerRellenaCampos);
    }
  }
}
