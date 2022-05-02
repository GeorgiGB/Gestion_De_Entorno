import 'package:crea_empresa_usario/globales.dart' as globales;
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

/// No estoy autenticado muestra aviso y me redirige a la pagina Login()
noEstoyAutenticado(BuildContext context) async {
  globales
      .muestraDialogo(context, AppLocalizations.of(context)!.codError401)
      .whenComplete(() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Login(),
        ),
        (Route<dynamic> route) => false);
  });
}

Future<bool> cerrarSesion(BuildContext context, {required String token}) async {
  AppLocalizations traducciones = AppLocalizations.of(context)!;

  // La informacion de la empresa
  bool esperando = true;
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

    globales.debug(response.body);
    //final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

    // status correcto?
    if (status == CodigoResp.r_200) {
      //bool ok = parsed[0]['bOk'].toString().parseBool();
      // hemos añadido la empresa a la BBDD?
      //if (ok) {
      /*
        // Eliminamos todas las rutas de navegación
        // Y cargamos la pantalla de EscogeEmpresaUsuario
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => EscogeOpciones(
                token: token,
              ),
            ),
            (Route<dynamic> route) => false);

        // Mostramos mensaje
        globales.muestraToast(context, msgOk);
        */
      /*globales
                  .muestraDialogo(
                      context,
                      traducciones.elUsuarioHaSidoDadoDeAlta(widget.ute_nombre),
                      traducciones.usuarioAnyadido)
                  .then((value) {});
              // TODO escoger entre mostrar toast o diálogo
              */
      //} else {
      //int cod_error = int.parse(parsed[0]['cod_error']);
      /*if (cod_error == -2) {
          globales.muestraDialogo(context, msgError);
        } else {*/
      //globales.debug(parsed[0]['msg_error']);
      //globales.muestraDialogo(
      //    context, traducciones.errNoEspecificado(parsed[0]['msg_error']));
      //}
      //}

      // Errores posibles
      //} else if (status == CodigoResp.r_401) {
      // TODO redirigir a la pantalla inicial
      //  globales.muestraDialogo(context, traducciones.codError401);
    } else if (status == CodigoResp.r_500) {
      //globales.muestraDialogo(context, traducciones.codError500);
      //globales.muestraDialogo(context, response.body);
    } else {
      //globales.debug(response.body);
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
  Future.delayed(Duration(seconds: 2), () {
    //Si pasan más de 2 segundos
    if (esperando) {
      EnCualquierLugar.muestraSnack(context, traducciones.cargando);
    }
  });
  return esperando;
}
