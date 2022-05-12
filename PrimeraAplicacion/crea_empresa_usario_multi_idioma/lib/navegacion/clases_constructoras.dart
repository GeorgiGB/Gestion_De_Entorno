import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/navegacion/rutas.dart';
import 'package:flutter/material.dart';

import 'package:crea_empresa_usario/pantallas/login.dart';
import 'package:crea_empresa_usario/pantallas/nueva_empr.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/pantallas/opciones_config.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

/// Clase utilizada para mostrar la Pantalla de [Login] extiende a la clase [PantallasMenu]
/// con un widget para el título de la [AppBar].
///
/// Necesita el parámetro [AppLocalizations]traduce para poner la traducción adecuada del título
class Identificate extends PantallasMenu {
  Identificate(BuildContext context, {Key? key})
      : super(
            Wrap(
              children: [
                Text(AppLocalizations.of(context)!.iniciaSesion),
                const SizedBox(width: 10),
                const Icon(Icons.login_rounded),
              ],
            ),
            conToken: false,
            menuLateral: false,
            key: key,
            claveConstructor: Ruta.rutas['IniciaLogin']!);
}

/// Clase utilizada para mostrar la Pantalla de [NuevaEmpresa] extiende a la clase [PantallasMenu]
/// Cargará la pantalla de [NuevaEmpresa] porque asi lo indicamos en [claveConstructor]
/// con un widget [Text] para el título
///
/// Por defecto le decimos que incluya un menu lateral y que requiere de [_token]
class EmpresaNueva extends PantallasMenu {
  EmpresaNueva(BuildContext context, {Key? key})
      : super(Text(AppLocalizations.of(context)!.nuevaEmpresa),
            key: key, claveConstructor: Ruta.rutas['EmpresaNueva']!);
}

/// Clase utilizada para mostrar la Pantalla de [NuevoUsuario] extiende a la clase [PantallasMenu]
/// Cargará la pantalla de [NuevoUsuario] porque asi lo indicamos en [claveConstructor]
/// con un widget [Text] para el título
///
/// Por defecto le decimos que incluya un menu lateral y que requiere de [_token]
class UsuarioNuevo extends PantallasMenu {
  UsuarioNuevo(BuildContext context, {Key? key})
      : super(Text(AppLocalizations.of(context)!.nuevoUsuario),
            key: key, claveConstructor: Ruta.rutas['UsuarioNuevo']!);
}

/// Clase utilizada para mostrar la Pantalla de [ConfigOpciones] extiende a la clase [PantallasMenu]
/// Cargará la pantalla de [ConfigOpciones] porque asi lo indicamos en [claveConstructor]
/// con un widget [Text] para el título
///
/// Por defecto le decimos que incluya un menu lateral y que requiere de [_token]
class OpcionesConfig extends PantallasMenu {
  OpcionesConfig(BuildContext context, {Key? key})
      : super(Text(AppLocalizations.of(context)!.configuracion),
            key: key, claveConstructor: Ruta.rutas['Configuracion']!);
}
