import 'package:flutter/material.dart';
import '../escoge_opciones.dart';

// Fin imports multi-idioma ----------------

cargaEscogeOpciones(BuildContext context, String token) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => EscogeOpciones(
          token: token,
        ),
      ),
      (Route<dynamic> route) => false);
}
