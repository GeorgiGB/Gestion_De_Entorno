import 'package:crea_empresa_usario/main.dart';
import 'package:flutter/material.dart';
import '../escoge_opciones.dart';

// Fin imports multi-idioma ----------------

vaciaNavegacionYCarga(BuildContext context,
    {required Widget Function(BuildContext) builder}) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: builder),
    (Route<dynamic> route) => false,
  );
}

aLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
      (Route<dynamic> route) => false);
}

popAndPush(BuildContext context,
    {required Widget Function(BuildContext) builder}) {
  // Eliminamos la página actual del historial de Navigator
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
  // Cargamos la página de NuevaEmpresa
  Navigator.push(context, MaterialPageRoute(builder: builder));
}
