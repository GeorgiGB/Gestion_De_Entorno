import 'package:crea_empresa_usario/globales.dart' as globales;
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'sesion.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

class BBDD {
  /// Uusario o contraseña encontrado o no válido
  static const userOrPwdNotFound = '-404';

  /// Elemento ya contenido en la BBDD
  static const uniqueViolation = '-23505';

  static const foreignKeyViolation = '-23503';

  /// Elemento con caracters no válidos
  static const invalidTextRepresentation = '-22P02';
}

/// Classe que contiene los diferentes tipos de código de respuesta
/// manejados en la aplicación: 200, 401, 404, 500
class Servidor {
  /// Respuesta correcta del servidor, 200
  static const int ok = 200;

  /// El usario no está autenticado, 401
  static const int usuarioNoAutenticado = 401;

  /// El usuario no se encuentra en la BBDD
  static const int recursoNoEncontrado = 404;

  /// Eror de servidor,500
  static const int errorServidor = 500;

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
  static Future<http.Response?> enviaPeticionAlservidor(
      BuildContext context, String url, String json,
      {String? token,
      bool relanzaClientException = false,
      bool relanzaOtrasExcepciones = false,
      bool muestraEspera = true,
      List<String> gestionoErrores = const []}) async {
    url = globales.servidor + url;
    AppLocalizations traduce = AppLocalizations.of(context)!;

    // Mostramos un SnackBar si tarda más de dos segundos en responmder el servidor
    Future.delayed(Duration(seconds: 2), () {
      //Si pasan más de 2 segundos
      if (muestraEspera) {
        EnCualquierLugar()
            .muestraSnack(context, traduce.esperandoRespuestaServidor);
      }
    });

    http.Response? response;
    try {
      // Headers de la peticion
      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8'
      };

      // Añadimos el token a la cabecera?
      if (token != null) {
        headers['Authorization'] = 'Bearer ' + token;
      }

      // Lanzamos la petrición
      response = await http.post(
        Uri.parse(url),

        // Cabeceras
        headers: headers,

        // Adjuntamos al body los datos en formato JSON
        body: json,
      );

      _gestionInicialResponse(context, response,
          gestionoErrores: gestionoErrores);

      //Errores de conexión del cliente u otros no especificados
    } on http.ClientException {
      if (relanzaClientException)
        rethrow;
      else
        globales.muestraDialogo(context, traduce.servidorNoDisponible);
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

  static void _gestionInicialResponse(
      BuildContext context, http.Response response,
      {List<String> gestionoErrores = const []}) {
    AppLocalizations traduce = AppLocalizations.of(context)!;
    int status = response.statusCode;
    globales.debug('status: ' + status.toString());
    globales.debug(response.body + '\n -------- \n');
    switch (status) {
      case Servidor.ok:
        // El que llama gestiona la acción
        break;
      case Servidor.usuarioNoAutenticado:
        // Mostramos Alerta avisando del error y redirige
        noEstoyAutenticado(context);
        break;

      // Aquí podemos encontrar diferentes respuestas
      // unas las trataremos aquí otras no
      case Servidor.recursoNoEncontrado:
        final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
        final strErr = parsed[0]['msg_error'];
        final codErr = parsed[0]['cod_error'];

        // Miro si es un error gestionado
        bool gestionado = false;
        for (var error in gestionoErrores) {
          gestionado = error == codErr;
          if (gestionado) break;
        }

        // Si no está gestionado muestro la alerta correspondiente
        print(gestionado.toString() + ', ' + codErr);
        if (!gestionado) {
          switch (codErr) {

            // No se encuetra
            case BBDD.userOrPwdNotFound:
              // Mostramos Alerta avisando del error
              usuarioContrasenyaNoValido(context);
              break;

            // Para todos los demas Recurso no encontrado
            default:
              globales.muestraDialogo(context, traduce.status_404);
              break;
          }
        }

        break;

      //
      case Servidor.errorServidor:
        // Muestra SnackBar
        error500Servidor(context);
        break;

      // Otros errores no contemplado y que no se deberían producir
      default:
        globales.debug(response.body);
    }
  }

  /// Llamamos a la función con el BuildContext[context] correspondiente, el [usuario]
  /// y el [pwd] para identificarnos.
  /// Si pasado unos segundos no se ha recibido una respuesta mostrará un mensaje
  /// En función de la respuesta del servidor tendremos un mensaje u otro
  /// ver [enviaPeticionAlservidor]
  static Future<http.Response?> login(
      BuildContext context, String usuario, String pwd) async {
    // Encriptamos el usuario y la contraseña juntos
    String contra_encrypted = '';
    if (pwd.isNotEmpty && usuario.isNotEmpty) {
      contra_encrypted = sha1.convert(utf8.encode(pwd + usuario)).toString();
    }

    var json = jsonEncode(
        <String, String>{'nombre': usuario, 'pwd': contra_encrypted});
    var url = '/login';

    // Lanzamos la peticion Post al servidor, no capturamos excepciones
    var response = await enviaPeticionAlservidor(context, url, json);
    return response;
  }

  /// Pasamos el BuildContext [context] y el [token] para poder cerrar la sesion activa.
  ///
  /// Si response és distinto de null la sesion ha sido cerrada correctamente
  ///
  /// Devuelve booleano -> response == null
  static Future<bool> cerrarSesion(BuildContext context,
      {required String token}) async {
    AppLocalizations traduce = AppLocalizations.of(context)!;

    var json = '';
    /* jsonEncode(<String, String>{
      'ctoken': token,
    });*/
    var url = '/cerrar_sesion';

    // globales.debug(token);

    // Lanzamos la peticion Post al servidor, no capturamos excepciones
    http.Response? response =
        await enviaPeticionAlservidor(context, url, json, token: token);
    return response != null;
  }

  /// Function intermedia utilizada para añadir información en la BBDD debe contener
  /// los siguientes parámetros: BuildContext[context] correspondiente, [url],
  /// [json] la información a enviar al servidor en formato json.
  /// Devuelve un int con el código de error que el tratamiento lo realiza la funcion
  /// que ha realizado la llamada.
  static Future<String> anyade(BuildContext context, String url, String token,
      {required String json, List<String> gestionoErrores = const []}) async {
    AppLocalizations traduce = AppLocalizations.of(context)!;

    // Lanzamos la peticion Post al servidor, no capturamos excepciones
    var response = await enviaPeticionAlservidor(context, url, json,
        token: token, gestionoErrores: gestionoErrores);

    // -1 significa error de servidor que es tratado al realizar la petición
    var codeError = '-1';

    // Pero si controlamos si response es null
    globales.debug('response: ' + (response != null).toString());
    if (response != null) {
      int status = response.statusCode;

      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

      codeError = parsed[0]['cod_error'];
      return codeError;
    }
    return codeError;
  }

  /// Función que devuelve un response, el body contiene una lista de empresas en formato JSON
  /// '[{"bOk":"true","status":"200","cod_error":"0"},
  ///  {"emp_cod":141,"emp_nombre":"Una empresa"},{"emp_cod":142,"emp_nombre":"una empresa"},...}]'
  ///
  /// Relance las excepciones por tanto, no va mostrar los mensajes de excepciones.
  /// El tratemiento de las excepciones se debe encargar la función que ha realizado la llamada
  static Future<http.Response?> buscaEmpresas(
      String queBusco, String token, BuildContext context) async {
    try {
      //Creamos el json
      var json = jsonEncode(
        <String, String>{'emp_busca': queBusco},
      );
      var url = '/listado_empresas';

      // Lanzamos la peticion Post al servidor y que relance las excepciones
      // por tanto, no se van a mostrar los mensajes de excepciones, ya se encarga
      // la funcion que ha realizado la llamado
      var response = await enviaPeticionAlservidor(context, url, json,
          token: token,
          relanzaClientException: true,
          relanzaOtrasExcepciones: true,
          muestraEspera: false);

      return response;

      //Errores de conexión del cliente u otros no especificados
    } on Exception {
      rethrow;
    }
  }
}
