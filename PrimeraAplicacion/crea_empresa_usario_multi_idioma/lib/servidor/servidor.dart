import 'package:crea_empresa_usario/escoge_opciones.dart';
import 'package:crea_empresa_usario/globales.dart' as globales;
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../listado_empresas/empresa_future.dart';
import 'sesion.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

class CodigoResp {
  static const int ok = 200;
  static const int usuarioNoAutenticado = 401;
  static const int noEcontrado = 404;
  static const int errorServidor = 500;
}

Future<http.Response?> login(
    String nombre, String pwd, BuildContext context) async {
  //  TO-DO objeto que mire el tiempo de carga del sistema
  //  Interrumpe toast si el tiempo de espera es mayor a 0.5s el programa mostrara por pantalla cargando
  //  globales.muestraToast(context, "Cargando...");
  bool esperandoLogin = true;
  // URL del servidor
  String url = globales.servidor + '/login';

  // Obtenemos usuario y la contraseña introducidas
  //String nombre = _usuario.text;
  // Contraseña
  //String pwd = _pwd.text;

  // Encriptamos el usuario y la contraseña juntos si los dos campos estan rellenados
  // TODO AVISAR de campos vacios
  String contra_encrypted = '';
  if (pwd.isNotEmpty && nombre.isNotEmpty) {
    contra_encrypted = sha1.convert(utf8.encode(pwd + nombre)).toString();
  }

  try {
    // Lanzamos la petición Post al servidor con la URL
    // El resultado será un Future y esperamos la respuesta
    var response = await http.post(
      Uri.parse(url),
      // Cabecera para enviar JSON
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Adjuntamos al body los datos en formato JSON
      body: jsonEncode(
          <String, String>{'nombre': nombre, 'pwd': contra_encrypted}),
    );

    int status = response.statusCode;
    switch (status) {
      case CodigoResp.ok:
        break;
      case CodigoResp.usuarioNoAutenticado:
        // Mostramos Alerta avisando del error y redirige
        noEstoyAutenticado(context);
        break;
      case CodigoResp.noEcontrado:
        // Mostramos Alerta avisando del error
        noEncontrado(context);
        break;
      case CodigoResp.errorServidor:
        // Muestra SnackBar
        error500Servidor(context);
        break;
      default:
        globales.debug(response.body);
    }
    return response;
  } on http.ClientException catch (e) {
    // Error no se encuentra servidor
    globales.muestraDialogo(
        context, AppLocalizations.of(context)!.servidorNoDisponible);
  } on Exception catch (e) {
    // Error no especificado
    globales.debug("Error no especificado: " + e.runtimeType.toString());
  }
  return null;
}

Future<bool> cerrarSesion(BuildContext context, {required String token}) async {
  AppLocalizations traducciones = AppLocalizations.of(context)!;

  // La informacion de la empresa
  bool esperando = true;

  Future.delayed(Duration(seconds: 2), () {
    //Si pasan más de 2 segundos
    if (esperando) {
      EnCualquierLugar().muestraSnack(context, traducciones.esperandoAlServidor);
    }
  });

  String url = globales.servidor + '/cerrar_sesion';

  // Lanzamos la peticion Post al servidor
  try {
    var response = await http.post(
      Uri.parse(url),
      // Cabecera para enviar JSON con una autorizacion token
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Adjuntamos al body los datos en formato JSON
      body: jsonEncode(<String, String>{
        'name_token': token,
      }),
    );
    // Hay que tener en cuenta si la contraseña es autogenerada
    // Adjuntar el token en la peticion.
    int status = response.statusCode;

    switch (status) {
      case CodigoResp.ok:
        break;
      case CodigoResp.usuarioNoAutenticado:
        // Mostramos Alerta avisando del error y redirige
        noEstoyAutenticado(context);
        break;
      case CodigoResp.noEcontrado:
        // Mostramos Alerta avisando del error
        noEncontrado(context);
        break;
      case CodigoResp.errorServidor:
        // Muestra SnackBar
        error500Servidor(context);
        break;
      default:
        globales.debug(response.body);
    }

    //Errores de conexión del cliente u otros no especificados
  } on http.ClientException catch (e) {
    globales.muestraDialogo(context, traducciones.servidorNoDisponible);
  } on Exception catch (e) {
    // Error no especificado
    globales.debug("Error no especificado: " + e.runtimeType.toString());
  } finally {
    esperando = false;
  }
  return esperando;
}

Future<bool> anyade(BuildContext context, String url,
    {required String token,
    required String json,
    required String msgOk,
    required String msgError}) async {
  AppLocalizations traducciones = AppLocalizations.of(context)!;

  // La informacion de la empresa
  bool esperando = true;

  // Mostramos un toast si tarda más de dos segundos en responmder el servidor
  Future.delayed(Duration(seconds: 2), () {
    print("hola" + esperando.toString());
    //Si pasan más de 2 segundos
    if (esperando) {
      EnCualquierLugar()
          .muestraSnack(context, traducciones.esperandoRespuestaServidor);
    }
  });

  // Lanzamos la peticion Post al servidor
  try {
    print("--->");
    var response = await http.post(
      Uri.parse(url),
      // Cabecera para enviar JSON con una autorizacion token
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      // Adjuntamos al body los datos en formato JSON
      body: json,
    );
    // Hay que tener en cuenta si la contraseña es autogenerada
    // Adjuntar el token en la peticion.
    int status = response.statusCode;

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    print(status.toString() + ", " + response.body);
    // status correcto?
    if (status == CodigoResp.ok) {
      bool ok = parsed[0]['bOk'].toString().parseBool();
      int cod_error = int.parse(parsed[0]['cod_error']);

      switch (cod_error) {
        case 0:
          return true;
        case -2:
          return false;
          // Aquí solo mostramos aviso
          break;
        default:
          //globales.debug(parsed[0]['msg_error']);
          globales.muestraDialogo(
              context, traducciones.errNoEspecificado(parsed[0]['msg_error']));
        // TODO preparar accion
        // volvemos a escoger opción
      }
      //}

      // Errores posibles
    } else if (status == CodigoResp.usuarioNoAutenticado) {
      // Muestra un diálogo y cambia a la pantalla principal al cerrarlo
      noEstoyAutenticado(context);
    } else if (status == CodigoResp.errorServidor) {
      // TODO redirigir a la pantalla escoge opciones
      globales.muestraDialogo(context, traducciones.codError500);
      //globales.muestraDialogo(context, response.body);
    } else {
      globales.debug(response.body);
    }

    //Errores de conexión del cliente u otros no especificados
  } on http.ClientException catch (e) {
    globales.muestraDialogo(context, traducciones.servidorNoDisponible);
  } on Exception catch (e) {
    // Error no especificado
    globales.debug("Error no especificado: " + e.runtimeType.toString());
  } finally {
    esperando = false;
  }
  return false;
}

Future<http.Response> buscaEmpresas(String queBusco, http.Client client,
    String token, BuildContext context) async {
  // ejemplo tomado y modificado de:
  // https://docs.flutter.dev/cookbook/networking/background-parsing#4-move-this-work-to-a-separate-isolate

  globales.debug("iniciamos");
  // Lanzamos la peticion Post al servidor
  try {
    String url = globales.servidor + '/listado_empresas';
    final http.Response response = await client.post(
      Uri.parse(url),
      // Cabecera para enviar JSON
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Adjuntamos al body los datos en formato JSON
      // que queremos buscar
      body:
          jsonEncode(<String, String>{'emp_busca': queBusco, 'ctoken': token}),
    );

    globales.debug("que tal?");

    int status = response.statusCode;
    switch (status) {
      case CodigoResp.ok:
        break;
      case CodigoResp.usuarioNoAutenticado:
        noEstoyAutenticado(context);
        break;
      case CodigoResp.errorServidor:
        // TODO redirigir a la pantalla escoge opciones
        globales.muestraDialogo(
            context, AppLocalizations.of(context)!.codError500);
        break;
      default:
        globales.debug(response.body);
    }

    globales.debug(status.toString());

    // Utilizamos la función compute para ejecutar _parseEmpresas en un segundo plano.
    return response;

    //Errores de conexión del cliente u otros no especificados
  } on http.ClientException catch (e) {
    throw e;
  }
}
