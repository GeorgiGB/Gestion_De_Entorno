import 'package:crea_empresa_usario/colores.dart';
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/pantalla.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/labeled_checkbox.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:crea_empresa_usario/preferencias/preferencias.dart'
    as Preferencias;
import 'package:flutter/material.dart';
import '../globales.dart' as globales;

import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Widget DropdownButton para selecionar idioma
// Fin imports multi-idioma ----------------

class Login extends StatefulWidget {
  static const String id = 'Login';

  Login({Key? key}) : super(key: key) {}
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late AppLocalizations traduce;

  bool guardaSesion = false;

  // Creamos el controlador campo de usuario
  final TextEditingController _usuario = TextEditingController();

  // Creamos el controlador campo de contraseña
  final TextEditingController _pwd = TextEditingController();
  // Widget Focus para enviari el foco al compo contraseña
  final FocusNode _contrasenaFocus = FocusNode();

  // Al realizar el login en el servidor y esperar su respuesta tenemos que saber
  // si estamos esperando la respuesta del servidor y así evitar múltiples peticiones al servidor
  bool esperandoLogin = false;

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
        MyApp.mantenLaSesion(guardaSesion, null);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    traduce = AppLocalizations.of(context)!;

    //traduce = AppLocalizations.of(context)!;
    // TODO poner información en blanco
    // informacion predeterminada que luego se borrara mas adelante
    _usuario.text = "Joselito";
    _pwd.text = "1234";

    return /*Scaffold(
      backgroundColor: Colors.transparent,
     appBar: AppBar(
          // Barra aplicación tiutlo
          title: Text(AppLocalizations.of(context)!.identifica),

          // Añadimos el DropButton de elección de idioma
          actions: [
            LanguageDropDown().getDropDown(context),
          ]),
      body:*/
        SingleChildScrollView(
      //Previene BOTTOM OVERFLOWED

      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //  Campo del nombre de usuario
          TextFormField(
            decoration: InputDecoration(
                hintText: traduce.hintTuNombre,
                labelText: AppLocalizations.of(context)!.usuario),
            cursorColor: PaletaColores.colorMorado,
            controller: _usuario,
            onFieldSubmitted: (String value) {
              // Al pulsar enter ponemos el foco en el campo contraseña
              FocusScope.of(context).requestFocus(_contrasenaFocus);
            },
          ),
          const SizedBox(height: 30),
          //  Campo de la pwd
          TextFormField(
            decoration: InputDecoration(
                hintText: traduce.hintContrasena,
                labelText: AppLocalizations.of(context)!.contrasena),
            cursorColor: PaletaColores.colorMorado,
            controller: _pwd,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            focusNode: _contrasenaFocus,
            onFieldSubmitted: (String value) {
              // al pulsar enter en este campo ya realizamos el login
              _login();
            },
          ),
          const SizedBox(height: 30),

          // Boton acceso y guardar sessión
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Botón para realizar el login
              ElevatedButton(
                child: Text(AppLocalizations.of(context)!.acceso),
                onPressed: () {
                  _login();
                },
                style: ElevatedButton.styleFrom(
                    primary: PaletaColores.colorMorado),
              ),
              // Separación
              const SizedBox(
                width: 20,
              ),

              // Guardamos Sesión?
              LabeledCheckbox(
                label: traduce.guardaSesion,
                chekBoxIzqda: false,
                textStyle: globales.estiloNegrita_16,
                value: guardaSesion,
                onChanged: (bool? value) {
                  setState(() {
                    guardaSesion = value!;
                    MyApp.mantenLaSesion(guardaSesion, null);
                  });
                },
              ),
            ],
          ),
        ],
      ),
      //),
    );
  }

  _login() {
    if (esperandoLogin) {
      EnCualquierLugar().muestraSnack(context, traduce.esperandoAlServidor);
    } else {
      // Obtenemos usuario y la contraseña introducidas
      String nombre = _usuario.text;
      // Contraseña
      String pwd = _pwd.text;

      if (nombre.isEmpty || pwd.isEmpty) {
        // No tiene datos Mostramos avisos
        globales.muestraDialogo(context, traduce.primerRellenaCampos);
      } else {
        esperandoLogin = true;

        Servidor.login(context, nombre, pwd).then((response) {
          if (response != null && response.statusCode == Servidor.ok) {
            final parsed =
                jsonDecode(response.body).cast<Map<String, dynamic>>();

            var token = parsed[0]['token'];

            // Guardamos sesion?
            MyApp.mantenLaSesion(guardaSesion, token);

            // Establecmos el token para uso de la aplicación
            MyApp.setToken(context, token);
            vesA(MyApp.despuesDeLoginVesA, context,
                arguments: ArgumentsToken(token));
          }
        }).whenComplete(() {
          esperandoLogin = false;
        });
      }
    }
  }
}
