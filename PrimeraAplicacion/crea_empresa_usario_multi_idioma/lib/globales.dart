library creacion_empres_usua.globales;

import 'package:flutter/material.dart';
import 'dart:io';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

String defaultLocale = Platform.localeName;
const String _servidor = 'http://localhost:8080';
String get servidor => _servidor;

bool _debug = true;

debug(Object? msg) {
  if (_debug) {
    print(msg.toString());
  }
}

Locale dimeLocal(BuildContext context) {
  return Localizations.localeOf(context);
}

Future<void> muestraDialogo(BuildContext context, String msg,
    [String titulo = '']) async {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              titulo.isEmpty ? AppLocalizations.of(context)!.aviso : titulo),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}

Future<void> muestraDialogoDespuesDe(
    BuildContext context, String msg, int despuesDe_milis) async {
  await Future.delayed(Duration(milliseconds: despuesDe_milis));
  muestraDialogo(context, msg);
}

muestraToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  ));
}

// Pasamos una cadena a boolean
extension BoolParsing on String {
  bool parseBool() {
    return this.toLowerCase() == 'true';
  }
}
