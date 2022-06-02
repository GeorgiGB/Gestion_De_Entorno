import 'dart:io';
<<<<<<< HEAD
import 'package:crea_empresa_usario/globales/globales.dart' as globales;
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/navegacion/pantalla.dart';
import 'package:crea_empresa_usario/pantallas/login.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
=======
import 'package:crea_empresa_usuario_multi_idioma/globales.dart' as globales;
import 'package:crea_empresa_usuario_multi_idioma/main.dart';
import 'package:crea_empresa_usuario_multi_idioma/navegacion/navega.dart';
import 'package:crea_empresa_usuario_multi_idioma/navegacion/pantalla.dart';
import 'package:crea_empresa_usuario_multi_idioma/pantallas/login.dart';
import 'package:crea_empresa_usuario_multi_idioma/servidor/servidor.dart';
import 'package:crea_empresa_usuario_multi_idioma/widgets/snack_en_cualquier_sitio.dart';
>>>>>>> 763b3dd56f7b95df1737b9377b63ba108200c0d6
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

String defaultLocale = Platform.localeName;
<<<<<<< HEAD
const String _servidor = 'http://localhost:8080'; //PARA USARLO EN MAQUINA VIRTUAL
//const String _servidor = 'http://127.0.0.1:55969'; //PARA USARLO EN MOVIL REAL
//const String _servidor = 'http://10.0.2.2:8080'; //PARA USARLO EN DISPOSITIVO EMULADO MOVIL
=======
//const String _servidor = 'http://localhost:8080'; PARA USARLO EN MAQUINA VIRTUAL
//const String _servidor = 'http://127.0.0.1:8080'; PARA USARLO EN MOVIL REAL
const String _servidor =
    'http://10.0.2.2:8080'; //PARA USARLO EN DISPOSITIVO EMULADO MOVIL
>>>>>>> 763b3dd56f7b95df1737b9377b63ba108200c0d6
String get servidor => _servidor;

/// No estoy autenticado muestra aviso y me redirige a la pagina Login()
noEstoyAutenticado(BuildContext context) async {
  var traduce = AppLocalizations.of(context)!;
  globales
      .muestraDialogo(context, traduce.status_401)
      .whenComplete(() => Navega.navegante(Login.id).voy(context));
}

error500Servidor(BuildContext context) async {
  EnCualquierLugar()
      .muestraSnack(context, AppLocalizations.of(context)!.status_500);
}

usuarioContrasenyaNoValido(BuildContext context) async {
  globales.muestraDialogo(
      context, AppLocalizations.of(context)!.usarioOContrasenyaNoValido);
}
