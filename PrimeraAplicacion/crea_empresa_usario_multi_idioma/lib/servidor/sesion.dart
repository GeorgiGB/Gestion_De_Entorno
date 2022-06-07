import 'dart:io';
import 'package:crea_empresa_usuario_multi_idioma/globales/globales.dart' as globales;
import 'package:crea_empresa_usuario_multi_idioma/navegacion/navega.dart';
import 'package:crea_empresa_usuario_multi_idioma/pantallas/login.dart';
import 'package:crea_empresa_usuario_multi_idioma/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

String defaultLocale = Platform.localeName;
//const String _servidor = 'http://localhost:8080'; //PARA USARLO EN MAQUINA VIRTUAL
//const String _servidor = 'http://127.0.0.1:8080'; PARA USARLO EN MOVIL REAL
const String _servidor ='http://10.0.2.2:8080'; //PARA USARLO EN DISPOSITIVO EMULADO MOVIL
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
