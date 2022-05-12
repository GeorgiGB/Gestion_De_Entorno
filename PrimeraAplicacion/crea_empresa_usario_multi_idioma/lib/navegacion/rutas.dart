import 'package:crea_empresa_usario/pantallas/login.dart';
import 'package:crea_empresa_usario/pantallas/nueva_empr.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/pantallas/opciones_config.dart';
import 'package:flutter/material.dart';

/// Clase que contiene las diferentes rutas de las pantallas que vamos a presentar
/// Junto con los [constructoresWidgets] que será utilizados parar cargar
/// las diferentes pantallas de la aplicación
class Ruta {
  static final Map<String, String> rutas = <String, String>{
    'IniciaLogin': '/Login',
    'EmpresaNueva': '/EmpresaNueva',
    'UsuarioNuevo': '/UsuarioNuevo',
    'Configuracion': 'Configuracion/'
  };

  /// Mapa compuesto por una cadena que identifia a la función constructora de widgets
  /// que se mostraran la pantalla
  ///
  /// ejemplo tomado de: https://github.com/flutter/flutter/issues/17766
  static Map<String, Widget Function(String?)> constructoresWidgets =
      <String, Widget Function(String?)>{
    Ruta.rutas['IniciaLogin']!: (token) => Login(),
    Ruta.rutas['EmpresaNueva']!: (token) => NuevaEmpresa(
          token: token!,
        ),
    Ruta.rutas['UsuarioNuevo']!: (token) => NuevoUsuario(
          token: token!,
        ),
    Ruta.rutas['Configuracion']!: (token) => ConfigOpciones(token: token!),
  };
}
