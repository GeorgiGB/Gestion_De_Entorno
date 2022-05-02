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

TextStyle get estiloNegrita_16 =>
    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0);

TextStyle get estiloNegritaRoja_16 => const TextStyle(
    fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16.0);

Locale dimeLocal(BuildContext context) {
  return Localizations.localeOf(context);
}

Future<void> muestraDialogo(BuildContext context, String msg,
    [String titulo = '']) async {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          //Previene BOTTOM OVERFLOWED
          child: AlertDialog(
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
          ),
        );
      });
}

Future<void> muestraDialogoDespuesDe(
    BuildContext context, String msg, int despuesDe_milis) async {
  await Future.delayed(Duration(milliseconds: despuesDe_milis));
  muestraDialogo(context, msg);
}

/* muestraToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    // Necesario Para mostrar un snack bar centrado
    // fondo transparente
    backgroundColor: Color.fromARGB(0, 0, 0, 0),
    duration: Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
    // no quieros su sombra
    elevation: 0,
    // contenido centrado
    content: Align(
      alignment: Alignment.center,

      // El contenedor
      child: Container(
        padding: const EdgeInsets.all(10.0),

        // Decoración del contenedor
        decoration: BoxDecoration(
          color: const Color.fromARGB(200, 0, 200, 0),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(10.0),
            right: Radius.circular(10.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),

        // Contenido en una columna
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // El texto ha mostrar
            Text(
              msg,
              style: estiloNegrita_16,
            ),
            //),
          ],
        ),
      ),
    ),
  ));
}*/

// Pasamos una cadena a boolean
extension BoolParsing on String {
  bool parseBool() {
    return this.toLowerCase() == 'true';
  }
}
