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

Future<http.Response> _enviaPeticionAlservidor(
    BuildContext context, String url, String json) async {
  url = globales.servidor + url;
  var response = await http.post(
    Uri.parse(url),
    // Cabecera para enviar JSON con una autorizacion token
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    // Adjuntamos al body los datos en formato JSON
    body: json,
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
  return response;
}

Future<http.Response?> login(
    String nombre, String pwd, BuildContext context) async {
  // Encriptamos el usuario y la contraseña juntos
  String contra_encrypted = '';
  if (pwd.isNotEmpty && nombre.isNotEmpty) {
    contra_encrypted = sha1.convert(utf8.encode(pwd + nombre)).toString();
  }

  try {
    globales.debug(" Nos identificamosidentificando");
    var json =
        jsonEncode(<String, String>{'nombre': nombre, 'pwd': contra_encrypted});
    var url = '/login';
    var response = await _enviaPeticionAlservidor(context, url, json);

    return response;

    //Errores de conexión del cliente u otros no especificados
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
      EnCualquierLugar()
          .muestraSnack(context, traducciones.esperandoAlServidor);
    }
  });

  // Lanzamos la peticion Post al servidor
  try {
    var json = jsonEncode(<String, String>{
      'ctoken': token,
    });
    var url = '/cerrar_sesion';
    var response = await _enviaPeticionAlservidor(context, url, json);
    globales.debug("cerrando");

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

Future<int> anyade(BuildContext context, String url,
    {required String token,
    required String json,
    required String msgOk,
    required String msgError}) async {
  AppLocalizations traducciones = AppLocalizations.of(context)!;

  // La informacion de la empresa
  bool esperando = true;

  // Mostramos un toast si tarda más de dos segundos en responmder el servidor
  Future.delayed(Duration(seconds: 2), () {
    //Si pasan más de 2 segundos
    if (esperando) {
      EnCualquierLugar()
          .muestraSnack(context, traducciones.esperandoRespuestaServidor);
    }
  });

  // Lanzamos la peticion Post al servidor
  try {
    var _url = url;
    globales.debug(_url);
    var _json = json;
    var response = await _enviaPeticionAlservidor(context, _url, _json);

    int status = response.statusCode;

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    // status correcto?
    if (status == CodigoResp.ok) {
      bool ok = parsed[0]['bOk'].toString().parseBool();
      int codEerror = int.parse(parsed[0]['cod_error']);
      return codEerror;
      /*switch (codEerror) {
        case 0:
          return 0;
        case -2:
          globales.muestraDialogo(context, msgError);
          return false;
      }*/
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
  return -1;
}

Future<http.Response> buscaEmpresas(String queBusco, http.Client client,
    String token, BuildContext context) async {
  // Lanzamos la peticion Post al servidor

  try {
    globales.debug("Pedimos lista empresas");
    var json = jsonEncode(
      <String, String>{'emp_busca': queBusco, 'ctoken': token},
    );
    var url = '/listado_empresas';
    var response = await _enviaPeticionAlservidor(context, url, json);

    return response;

    //Errores de conexión del cliente u otros no especificados
  } on http.ClientException catch (e) {
    // Error no se encuentra servidor
    throw e;
  }
}
