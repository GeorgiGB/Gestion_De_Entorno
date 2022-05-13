import 'package:crea_empresa_usario/excepciones_personalizadas/excepciones.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/navegacion/pantalla.dart';
import 'package:crea_empresa_usario/pantallas/nueva_empr.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/aviso_accion.dart';
import 'package:crea_empresa_usario/widgets/dropdownfield.dart';
import 'package:crea_empresa_usario/widgets/esperando_servidor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

import '../../globales.dart' as globales;

// Qué empresa ha sido seleccionada?
EmpresCod? get empreCod => ListaEmpresas._empresaSeleccionada;

/// Función utilizada para obtener la lista de empresas del servidor
/// En caso de no haber empresas dadas de alta muestra un mensaje y la opción
/// de dar de alta una empresa o volver atrás
/// Si falla la conexión muestra un mensaje y un botón para volver atrás
/// Una vez se muestran los campos de formulario esta función no se volverá a ejecutar.
/// Necesita la referencia del Widget [NuevoUsuarioState] donde se encuetra para
FutureBuilder<List<EmpresCod>> dropDownEmpresas(
    String queBusco, NuevoUsuarioState ns, BuildContext context, String token) {
  late String msgErr = '';
  BuildContext _context = context;
  AppLocalizations traduce = AppLocalizations.of(_context)!;
  final String _token = token;

  return FutureBuilder<List<EmpresCod>>(
    // Future que gestiona la petición del listado de empresas al servidor
    future: ns.muestraFormulario.visible
        ? null
        : Servidor.buscaEmpresas(queBusco, _token, _context)

            // En caso de error en el servidor capturamos el mensaje pertinente.
            .onError(
            (error, stackTrace) {
              if (error is ExceptionServidor) {
                if (error.codError == Servidor.usuarioNoAutenticado) {
                  // No estoy auternticado
                  msgErr = traduce.status_401;
                  // noEstoyAutenticado(cntxt);
                } else {
                  msgErr = traduce
                      .errNoEspecificado(': ' + error.codError.toString());
                }
              } else {
                msgErr = traduce.servidorNoDisponible;
              }
              throw error!;
            },
          )
            // ejemplo tomado y modificado de:
            // https://docs.flutter.dev/cookbook/networking/background-parsing#4-move-this-work-to-a-separate-isolate

            // si es correcto devolvemos u listado de empresas
            // Utilizamos la función compute para ejecutar _parseEmpresas en un segundo plano.
            .then((response) => compute(_parseEmpresas, response)),

    // Este future en función del error de la conexión o del servidor realiza
    // varios intentos antes de llamar a este método anónimo y crear los widgets a mostrar
    builder: (context, datos) {
      if (datos.hasError) {
        // en caso de error
        bool autenticado = (datos.error is ExceptionServidor) &&
            (datos.error as ExceptionServidor).codError !=
                Servidor.usuarioNoAutenticado;

        if (autenticado && msgErr.isNotEmpty) {
          // tenemos que darle un retraso ya que mostrar el diálogo
          // mientras se está construyendo provoca un error
          globales.muestraDialogoDespuesDe(context, msgErr, 0);

          // Mostramos mensaje
          //globales.muestraToast(context, msgOk);
        }

        // En caso de error mostramos un aviso acción para recargar página
        return AvisoAccion(
          autenticado: autenticado,
          aviso: msgErr.isEmpty ? traduce.esperandoRespuestaServidor : msgErr,
          msg: traduce.recarga,
          icon: const Icon(Icons.refresh_rounded),
          // Recargamos la página de NuevoUsuario
          accion: () => Navega.navegante(NuevoUsuario.id)
              .voy(context), //PantallaNuevoUsuario.voy(context),
        );
      } else if (datos.hasData) {
        // Tenemos datos?
        if (datos.data!.isEmpty) {
          // No hay empresas en los datos recibidos por el servidor
          return AvisoAccion(
            // No hay empresas dadas de alta -> cargamos la pantalla de EmpresNueva
            accion: () => {Navega.navegante(NuevaEmpresa.id).voy(context)},
            aviso: traduce.noSeEncuentraEmpresasDadeAlta,
            msg: traduce.anyadeEmpresa,
            icon: const Icon(Icons.add_business_rounded),
          );
        } else {
          // Tenemos datos y
          // ya podemos mostrar los campos de formulario
          ns.controlesVisibilidad(true);

          // y ahora creamos el dropDown de Empresas
          return ListaEmpresas(empresas: datos.data!);
        }
      } else {
        // Esperando datos del servidor
        return Esperando.esperandoA(
            AppLocalizations.of(context)!.esperandoAlServidor);
      }
    },
  );
}

// Funcion utilizada para convertir el cuerpo de la resuesta enviada
// por el servidor en una List<EmpresCod>.
List<EmpresCod> _parseEmpresas(http.Response? response) {
  if (response == null) {
    throw ExceptionServidor(Servidor.errorServidor);
  } else {
    // Qué status ha llegado en el response?
    final int status = response.statusCode;
    switch (status) {

      // ha ido correcto?
      case Servidor.ok:
        // globales.debug("hola");
        final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
        // Eliminamos el primer elemento que contiene la información de si todo es correcto
        // Pues la lista de empresas empieza después del primer elemento
        parsed.removeAt(0);
        return parsed
            .map<EmpresCod>((json) => EmpresCod.fromJson(json))
            .toList();

      // Respuestas que contiene errores o respuestaas no contempladas
      default:
        throw ExceptionServidor(status);
    }
  }
}

// Clase que utilizamos para crear cada elemento de la lista de Empresas
class EmpresCod implements DropDownIntericie {
  final int empCod;
  final String empNombre;

  const EmpresCod({
    required this.empCod,
    required this.empNombre,
  });

  factory EmpresCod.fromJson(Map<String, dynamic> json) {
    return EmpresCod(
      empCod: json['emp_cod'] as int,
      empNombre: json['emp_nombre'] as String,
    );
  }

  Widget
      get widget => //Text(emp_nombre); // Es pot mostrar qualsevol tipus de widget
          Row(children: [Text(empCod.toString()), Text(' - ' + empNombre)]);

  @override
  String string() {
    return empCod.toString() + " - " + empNombre;
  }

  @override
  String toString() {
    return empCod.toString() + " - " + empNombre;
  }

  @override
  bool operator ==(dynamic other) {
    return other is String && toString().contains(other) ||
        other is EmpresCod &&
            other.empCod == empCod &&
            other.empNombre == empNombre;
  }

  @override
  int get hashCode => hashValues(empCod, empNombre);
}

class ListaEmpresas extends StatelessWidget {
  ListaEmpresas({Key? key, required this.empresas}) : super(key: key);

  final List<EmpresCod> empresas;

  final controladorEmpresa = TextEditingController();
  static EmpresCod? _empresaSeleccionada;

  @override
  Widget build(BuildContext context) {
    // TODO poner etiqueta Empresa encima del DropDownField
    return DropDownField(
      traducciones: AppLocalizations.of(context)!,
      controller: controladorEmpresa,
      focusNode: FocusNode(),
      hintText: AppLocalizations.of(context)!.empresa,
      labelText: AppLocalizations.of(context)!.selecionaEmpresa,
      enabled: true,
      itemsVisibleInDropdown: 5,
      items: empresas,
      onValueChanged: (value) {
        _empresaSeleccionada = value as EmpresCod;
      },
    );
  }
}
