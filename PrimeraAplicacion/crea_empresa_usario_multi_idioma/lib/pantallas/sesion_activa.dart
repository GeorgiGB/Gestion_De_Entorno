import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import 'package:crea_empresa_usario/preferencias/preferencias.dart'
    as Preferencias;

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main.dart';
// Fin imports multi-idioma ----------------

class SesionActiva extends StatefulWidget {
  const SesionActiva({Key? key}) : super(key: key);

  @override
  State<SesionActiva> createState() => _SesionActivaState();
}

class _SesionActivaState extends State<SesionActiva> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.yellow);
  }
}
