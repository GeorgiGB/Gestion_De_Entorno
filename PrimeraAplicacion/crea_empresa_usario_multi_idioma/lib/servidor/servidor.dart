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

/// Classe que contiene los diferentes tipos de código de respuesta
/// manejados en la aplicación: 200, 401, 404, 500
class CodigoResp {
  /// Respuesta correcta del servidor, 200
  static const int ok = 200;

  /// El usario no está autenticado, 401
  static const int usuarioNoAutenticado = 401;

  /// El usuario no se encuentra en la BBDD
  static const int noEncontrado = 404;

  /// Eror de servidor,500
  static const int errorServidor = 500;
}

/// Para enviar una petición al servidor debemos pasar a esta función
/// los siguientes parámetros: [context], [url], [json]
///
/// Devuelve un [Future<http.Response>]
///
/// * Ejemplo de llamada a esta función si tratar errores:
/// ```dart
/// var json =
///     jsonEncode(<String, String>{'nombre': nombre, 'pwd': contra_encrypted});
/// var url = '/login';
/// var response = await _enviaPeticionAlservidor(context, url, json);
/// ```
///
///
/// *  Ejemplo de llamada a esta función tratando con error [http.ClientException]:
/// ```dart
/// var relanzaClientException = true;
/// var json =
///     jsonEncode(<String, String>{'nombre': nombre, 'pwd': contra_encrypted});
/// var url = '/login';
/// try{
///   var response = await _enviaPeticionAlservidor(context, url, json, relanzaClientException);
/// }on http.ClientException catch(e){
///   ...
/// }
/// ```
///
/// En todas las situaciones devuelve el [response] excepto cuando
/// se produce una [Exception]
///
/// La función mira el [response.statusCode] de forma que si se produce
/// un status:
/// - 200, respuesta correcta
/// - 401, muestra una ventana de alerta indicando que el usuario no está autenticado
/// - 404, muestra una ventana de alerta indicando que no se encuentra el usuario
/// - 500, SnackBar de error de3 servidor,
///

/// Realiza tratamiento de errores try-catch, las funciones que realizan llamadas
/// Si queremos relanzar los errores lo tendremos que indicar a través de los parámetres
/// [relanzaClientException] y [relanzaOtrasExcepciones], de esta forma la función que
/// realiza la llamad debe tratar con las psoibles Excepciones como [http.ClientException]
/// u otras [Exception]
///
Future<http.Response?> _enviaPeticionAlservidor(
    BuildContext context, String url, String json,
    {bool relanzaClientException = false,
    bool relanzaOtrasExcepciones = false,
    bool muestraEspera = true}) async {
  url = globales.servidor + url;
  AppLocalizations traducciones = AppLocalizations.of(context)!;

  // Mostramos un SnackBar si tarda más de dos segundos en responmder el servidor
  Future.delayed(Duration(seconds: 2), () {
    //Si pasan más de 2 segundos
    if (muestraEspera) {
      EnCualquierLugar()
          .muestraSnack(context, traducciones.esperandoRespuestaServidor);
    }
  });

  http.Response? response;
  try {
    response = await http.post(
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
      case CodigoResp.noEncontrado:
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
  } on http.ClientException {
    if (relanzaClientException)
      rethrow;
    else
      globales.muestraDialogo(context, traducciones.servidorNoDisponible);
  } on Exception catch (e) {
    // Error no especificado
    if (relanzaOtrasExcepciones)
      rethrow;
    else
      globales.debug("Error no especificado: " + e.runtimeType.toString());
  }
  muestraEspera = false;
  return response;
}

/// Llamamos a la función con el BuildContext[context] correspondiente, el [usuario]
/// y el [pwd] para identificarnos.
/// Si pasado unos segundos no se ha recibido una respuesta mostrará un mensaje
/// En función de la respuesta del servidor tendremos un mensaje u otro
/// ver [_enviaPeticionAlservidor]
Future<http.Response?> login(
    BuildContext context, String usuario, String pwd) async {
  // Encriptamos el usuario y la contraseña juntos
  String contra_encrypted = '';
  if (pwd.isNotEmpty && usuario.isNotEmpty) {
    contra_encrypted = sha1.convert(utf8.encode(pwd + usuario)).toString();
  }

  var json =
      jsonEncode(<String, String>{'nombre': usuario, 'pwd': contra_encrypted});
  var url = '/login';
  var response = await _enviaPeticionAlservidor(context, url, json);
  return response;
}
/// Pasamos el BuildContext [context] y el [token] para poder cerrar la sesion activa.
/// 
/// Si response és distinto de null la sesion ha sido cerrada correctamente
/// 
/// Devuelve booleano -> response == null
Future<bool> cerrarSesion(BuildContext context, {required String token}) async {
  AppLocalizations traducciones = AppLocalizations.of(context)!;

  var json = jsonEncode(<String, String>{
    'ctoken': token,
  });
  var url = '/cerrar_sesion';

  // Lanzamos la peticion Post al servidor
  http.Response? response = await _enviaPeticionAlservidor(context, url, json);
  return response != null;
}

/// Function intermedia utilizada para añadir información en la BBDD debe contener
/// los siguientes parámetros: BuildContext[context] correspondiente, [url],
/// [json] la información a enviar al servidor en formato json.
/// Devuelve un int con el código de error
Future<int> anyade(BuildContext context, String url,
    {required String json}) async {
  AppLocalizations traducciones = AppLocalizations.of(context)!;

  var _url = url;
  var _json = json;

  // Lanzamos la peticion Post al servidor
  // No capturamos excepciones
  var response = await _enviaPeticionAlservidor(context, _url, _json);
  var codeError = -1;
  // Pero si controlamos si response es null
  if (response != null) {
    int status = response.statusCode;

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    // status correcto?
    if (status == CodigoResp.ok) {
      // Obtenemos el codigo de erro
      codeError = int.parse(parsed[0]['cod_error']);
      return codeError;
    }
  }
  return codeError;
}

/// Función que devuelve el response que en el body contiene una lista de empresas en formato JSON
/// '[{"bOk":"true","status":"200","cod_error":"0"},
///  {"emp_cod":141,"emp_nombre":"Una empresa"},{"emp_cod":142,"emp_nombre":"una empresa"},...}]'
Future<http.Response?> buscaEmpresas(
    String queBusco, String token, BuildContext context) async {
  // Lanzamos la peticion Post al servidor

  try {
    globales.debug("Pedimos lista empresas");
    var json = jsonEncode(
      <String, String>{'emp_busca': queBusco, 'ctoken': token},
    );
    var url = '/listado_empresas';
    var response = await _enviaPeticionAlservidor(context, url, json,
        relanzaClientException: true,
        relanzaOtrasExcepciones: true,
        muestraEspera: false);

    return response;

    //Errores de conexión del cliente u otros no especificados
  } on Exception {
    rethrow;
  }
}
