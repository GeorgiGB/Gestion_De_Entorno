// Clase utilizada para pasar el token a las diferentes rutas
import 'package:flutter/material.dart';

import 'rutas.dart';

class ArgumentsToken {
  final String token;
  ArgumentsToken(
    this.token,
  );
}

/// Cómo su nombre indica cargará la pantalla de [Login]
/// utilizando el método [vesA]
aLogin(BuildContext context, {Object? arguments}) {
  //PantallasMenu.abierto = false;
  return vesA(Ruta.rutas['IniciaLogin']!, context, arguments: arguments);
}

/// Cómo su nombre indica cargará la pantalla de [EmpresaNueva]
/// utilizando el método [vesA]
Future<T?> aEmpresaNueva<T extends Object?>(BuildContext context,
    {Object? arguments}) {
  return vesA(Ruta.rutas['EmpresaNueva']!, context, arguments: arguments);
}

/// Cómo su nombre indica cargará la pantalla de [UsuarioNuevo]
/// utilizando el método [vesA]
Future<T?> aUsuarioNuevo<T extends Object?>(BuildContext context,
    {Object? arguments}) {
  return vesA(Ruta.rutas['UsuarioNuevo']!, context, arguments: arguments);
}

/// Metodo que cargará la ruta indicada y vaciará el historial anterior
/// Pasando los argumentos
Future<T?> vesA<T extends Object?>(String ruta, BuildContext context,
    {Object? arguments}) {
  return Navigator.of(context)
      .pushNamedAndRemoveUntil(ruta, (route) => false, arguments: arguments);
}
