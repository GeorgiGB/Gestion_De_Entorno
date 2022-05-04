import 'package:crea_empresa_usario/pantallas/login.dart';
import 'package:flutter/material.dart';

// Fin imports multi-idioma ----------------

vaciaNavegacionYCarga(BuildContext context,
    {required Widget Function(BuildContext) builder}) {
  if (Navigator.canPop(context)) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: builder),
      (Route<dynamic> route) => false,
    );
  } else {
    Navigator.push(context, MaterialPageRoute(builder: builder));
  }
}

aLogin(BuildContext context) {
  vaciaNavegacionYCarga(context, builder: (context) => Login());
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
