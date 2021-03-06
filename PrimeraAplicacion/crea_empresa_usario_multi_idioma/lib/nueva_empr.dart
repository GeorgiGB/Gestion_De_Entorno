import 'package:crea_empresa_usario/escoge_opciones.dart';
import 'package:crea_empresa_usario/servidor/anyade.dart';
import 'package:flutter/material.dart';
import 'globales.dart' as globales;
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

  late AppLocalizations traducciones;
  // Hace un check del boton para generar una contraseña automatica
  bool _emp_pwd_auto = true;
  // Cuando pulsamos el boton de crear empresa cambiara de estado
  // Indicando que la empresa se esta creado y asi no poder
  // Pulsar el boton de creacion mas de una vez por error
  bool esperandoNuevaEmpresa = false;
  //  para mostrar/ocultar la contraseña
  bool _contraVisible = false;

  @override
  void initState() {
    _contraVisible = false;
    _emp_pwd_auto = true;
  }

  @override
  Widget build(BuildContext context) {
    traducciones = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(traducciones.empresaNueva),
      ),
      body: SingleChildScrollView(
          //Previene BOTTOM OVERFLOWED
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Campo formulario Nombre de la empresa
              TextFormField(
                decoration: InputDecoration(
                  hintText: traducciones.introduceElNombre,
                  labelText: traducciones.nombreDeLaEmpresa,
                ),
                controller: _emp_nombre,
                onFieldSubmitted: (String value) {
                  // Al pulsar intro pon el foco en el checkbox de contraseña auto generada
                  FocusScope.of(context).requestFocus(_auto_contrasenaFocus);
                },
              ),
              SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(traducciones.generaContrasena),
                  Checkbox(
                      // Mientras este activo
                      // No permitira al usuario escribir una contraseña
                      value: _emp_pwd_auto,
                      focusNode: _auto_contrasenaFocus,
                      onChanged: (bool? value) {
                        autoCheckBox(value!);
                      }),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        avisoContraManual(hasFocus);
                      },
                      // Campo contraseña
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: traducciones.contrasena,
                          hintText: traducciones.introduceLaContrasena,
                          // Icono  para mostrar/ocultar la contraseña
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _contraVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                _contraVisible = !_contraVisible;
                              });
                            },
                          ),
                        ),
                        controller: _emp_pwd,
                        // para mostrar/ocultar la contraseña
                        obscureText: !_contraVisible,
                        enableSuggestions: false,
                        autocorrect: false,

                        // LLamamos a la función de para cargar los filtros de usuario
                        // que nos permitira avanzar a la siguiente página
                        onFieldSubmitted: (String value) {
                          _crearEmpresa();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
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

  _crearEmpresa() {
    String url = globales.servidor + '/crear_empresa';
    if (esperandoNuevaEmpresa) {
      globales.muestraToast(context, traducciones.esperandoAlServidor);
    } else {
      /* 
    Tenemos dos tipos de condiciones ya que se puede acceder de dos formas
    1. Rellenando el campo de nombre y contraseña.
    2. Rellenando el campo de nombre y pulsando el boton de autogenerado.
    
    Por lo tanto tenemos que comprobar si el botón no esta marcado y
    hemos introducido una contraseña. Y al revés, si hemos introducido un nombre 
    y hemos marcado el botón de autogenerado.
    */
      // La informacion de la empresa
      String nom_empresa = _emp_nombre.text;
      String emp_pwd = _emp_pwd.text;

      if (nom_empresa.isEmpty || !_emp_pwd_auto && emp_pwd.isEmpty) {
        // No tiene datos Mostramos avisos
        globales.muestraDialogo(context, traducciones.primerRellenaCampos);
      } else {
        esperandoNuevaEmpresa = true;
        String json = jsonEncode(<String, String>{
          'nombre': nom_empresa,
          'pwd': emp_pwd,
          'auto_pwd': _emp_pwd_auto.toString(),
          'ctoken': widget.token
        });

        //Enviamos al servidor
        anyade(
          context,
          url,
          token: widget.token,
          json: json,
          msgOk: traducciones.laEmpresaHaSidoDadoDeAlta(nom_empresa),
          msgError: traducciones.laEmpresaYaEstaregistrada(nom_empresa),
        ).then((value) => esperandoNuevaEmpresa = value);
      }
    }
  }
}
