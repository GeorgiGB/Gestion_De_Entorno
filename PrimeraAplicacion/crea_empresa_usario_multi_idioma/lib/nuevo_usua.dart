//import 'package:crea_empresa_usario/drop_down/empresa.dart';

import 'package:crea_empresa_usario/widgets/dropdownfield.dart';

import 'package:crea_empresa_usario/listado_empresas/empresa_future.dart' as ef;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'globales.dart' as globales;
import 'filtros_usuario.dart';
import 'main.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

class nuevoUsuario extends StatefulWidget {
  const nuevoUsuario({Key? key, required this.ust_token}) : super(key: key);
  final String ust_token;

  @override
  State<nuevoUsuario> createState() => nuevoUsuarioState();
}

class nuevoUsuarioState extends State<nuevoUsuario> {
  final TextEditingController _ute_nombre = TextEditingController();
  final TextEditingController _ute_pwd = TextEditingController();
  final FocusNode _auto_contrasenaFocus = FocusNode();

  late AppLocalizations traducciones;

  bool _ute_pwd_auto = true;
  bool esperandoNuevoUsuario = false;
  bool enviar = false;
  late Visibility _mostrar;
  Visibility get mostraFormulario => _mostrar;

  /*void initState() {
    super.initState();
    // Mostramos un mensaje al finalizar la carga
    // El mostra el mensaje dependerà de la función
    WidgetsBinding.instance?.addPostFrameCallback((_) => ef.dos(context));
  }*/

  @override
  Widget build(BuildContext context) {
    traducciones = AppLocalizations.of(context)!;

    _mostrar = getControlesVsibles();

    return Scaffold(
      appBar: AppBar(
        title: Text(traducciones.nuevoUsuario),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // FutureBuilder<List<EmpresCod>>
          // para seleccionar empresa y asociar el nuevo usuario
          ef.dropDownEmpresas(widget, this, context),
          mostraFormulario,
        ],
      )),
    );
  }

  // Si el checkbox esta activo y el campo contraseña tiene datos
  // Se encargara de limpiar el campo contraseña

  autoCheckBox(bool value) {
    if (value) {
      _ute_pwd.clear();
    }
    setState(() {
      _ute_pwd_auto = value;
    });
  }

  avisoContraManual(bool hasFocus) {
    // Si la casilla esta marcada no permitira la escritura en el campo de la contraseña
    // Y mostrara un aviso
    if (hasFocus && _ute_pwd_auto) {
      FocusScope.of(context).requestFocus(_auto_contrasenaFocus);
      globales.muestraDialogo(context, traducciones.introContraDesmarcaCasilla);
    }
  }

  Future<void>? _crearUsuario() async {
    /* 
    Tenemos dos tipos de condiciones ya que se puede acceder de dos formas
    1. Rellenando el campo de nombre y contraseña.
    2. Rellenando el campo de nombre y pulsando el boton de autogenerado.
    
    Por lo tanto tenemos que comprobar si el botón no esta marcado y
    hemos introducido una contraseña. Y al revés, si hemos introducido un nombre 
    y hemos marcado el botón de autogenerado.
    */
    if ((_ute_nombre.text.isNotEmpty && _ute_pwd.text.isNotEmpty) ||
        (_ute_nombre.text.isNotEmpty && _ute_pwd_auto)) {
      if (esperandoNuevoUsuario) {
        globales.muestraToast(context, traducciones.esperandoAlServidor);
      } else {
        globales.muestraToast(context, traducciones.comprobandoDatos);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => filtros_usuario(
                    ust_token: widget.ust_token,
                    ute_nombre: _ute_nombre.text,
                    ute_pwd: _ute_pwd.text,
                    ute_pwd_auto: _ute_pwd_auto)));
      }
    } else {
      globales.muestraDialogo(context, traducciones.primerRellenaCampos);
    }
    // TO-DO
    // si la respuesta es correcta ya podemos cargar los filtros
    // si no lanzaremos un aviso
  }

  controlesVisibilidad(bool visible) {
    setState(() {
      _visible = visible;
    });
  }

  bool _visible = true;
  Visibility getControlesVsibles() {
    return Visibility(
      visible: _visible,
      // replacement: , widget para volver atrasPonemos
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            traducciones.nombreDelUsuario,
          ),
          TextFormField(
            decoration:
                InputDecoration(hintText: traducciones.introduceElNombre),
            controller: _ute_nombre,
            onFieldSubmitted: (String value) {
              // datos(completos)
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
                          value: _ute_pwd_auto,
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
                    controller: _ute_pwd,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,

                    // LLamamos a la función de creacion de usuario que nos permitira avanzar a la siguiente página
                    onFieldSubmitted: (String value) {
                      _crearUsuario();
                    },
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            child: Text(traducciones.siguiente),
            onPressed: () {
              _crearUsuario();
            },
          ),
        ],
      ),
    );
  }
}
