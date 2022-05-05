import 'package:crea_empresa_usario/globales.dart' as globales;
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

/// No estoy autenticado muestra aviso y me redirige a la pagina Login()
noEstoyAutenticado(BuildContext context) async {
  var traduce = AppLocalizations.of(context)!;
  globales
      .muestraDialogo(context, traduce.codError401)
      .whenComplete(() => aLogin(context, traduce));
}

error500Servidor(BuildContext context) async {
  EnCualquierLugar()
      .muestraSnack(context, AppLocalizations.of(context)!.codError500);
}

noEncontrado(BuildContext context) async {
  globales.muestraDialogo(
      context, AppLocalizations.of(context)!.codErrorLogin404);
}
