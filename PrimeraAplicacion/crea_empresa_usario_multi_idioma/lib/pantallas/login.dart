import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/pantallas/escoge_opciones.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/preferencias/preferencias.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/labeled_checkbox.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import '../globales.dart' as globales;

import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Widget DropdownButton para selecionar idioma
import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
// Fin imports multi-idioma ----------------

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

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
  Widget build(BuildContext context) {
    traduce = AppLocalizations.of(context)!;

    //traduce = AppLocalizations.of(context)!;
    // TODO poner información en blanco
    // informacion predeterminada que luego se borrara mas adelante
    _usuario.text = "Joselito";
    _pwd.text = "1234";

    return Scaffold(
      /*appBar: AppBar(
          // Barra aplicación tiutlo
          title: Text(AppLocalizations.of(context)!.identifica),

          // Añadimos el DropButton de elección de idioma
          actions: [
            LanguageDropDown().getDropDown(context),
          ]),*/
      body: SingleChildScrollView(
        //Previene BOTTOM OVERFLOWED
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  hintText: traduce.hintTuNombre,
                  labelText: AppLocalizations.of(context)!.usuario),
              controller: _usuario,
              onFieldSubmitted: (String value) {
                // Al pulsar enter ponemos el foco en el campo contraseña
                FocusScope.of(context).requestFocus(_contrasenaFocus);
              },
            ),
            SizedBox(height: 30),

            TextFormField(
              decoration: InputDecoration(
                  hintText: traduce.hintContrasena,
                  labelText: AppLocalizations.of(context)!.contrasena),
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
            SizedBox(height: 30),

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
                  // Mientras este activo
                  // No permitira al usuario escribir una contraseña
                  value: guardaSesion,
                  onChanged: (bool? value) {
                    setState(() {
                      guardaSesion = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _login()  {
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
            MyApp.mantenLaSesion(guardaSesion);

            // Establecmos el token para uso de la aplicación
            MyApp.setToken(context, token);

            aEmpresaNueva(context);
          }
        }).whenComplete(() {
          esperandoLogin = false;
        });
      }
    }
  }
}
