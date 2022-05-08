import 'package:crea_empresa_usario/excepciones_personalizadas/excepciones.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/pantallas/nueva_empr.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/esperando_servidor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

import '../globales.dart' as globales;
import '../widgets/dropdownfield.dart';

// Qué empresa ha sido seleccionada?
EmpresCod? get empreCod => ListaEmpresas._empresaSeleccionada;

/// Función utilizada para obtener la lista de empresas del servidor
/// En caso de no haber empresas dadas de alta  muestra un mensaje y la opción
/// de dar de alta una empresa o volver atrás
/// Si falla la conexión muestra un mensaje y un botón para volver atrás
/// Una vez se muestran los campos de formulario esta función no se volverá a ejecutar.
FutureBuilder<List<EmpresCod>> dropDownEmpresas(
    String queBusco, NuevoUsuarioState ns) {
  late String msgErr = '';
  BuildContext cntxt = ns.context;
  NuevoUsuario widget = ns.widget;

  return FutureBuilder<List<EmpresCod>>(
    // Future que gestiona la petición del listado de empresas al servidor
    future: ns.muestraFormulario.visible
        ? null
        : Servidor.buscaEmpresas(queBusco, widget.token, cntxt)

            // En caso de error en el servidor capturamos el mensaje pertinente.

            .onError(
            (error, stackTrace) {
              // globales.debug("-> Estoy en error: " + error.toString());
              if (error is ExceptionServidor) {
                if (error.codError == Servidor.usuarioNoAutenticado) {
                  // No estoy auternticado
                  msgErr = AppLocalizations.of(cntxt)!.status_401;
                  // noEstoyAutenticado(cntxt);
                } else {
                  msgErr = AppLocalizations.of(cntxt)!
                      .errNoEspecificado(': ' + error.codError.toString());
                }
              } else {
                msgErr = AppLocalizations.of(cntxt)!.servidorNoDisponible;
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
        // globales.debug("Te pille: " + msgErr);
        // en caso de error
        bool autenticado = (datos.error is ExceptionServidor) &&
            (datos.error as ExceptionServidor).codError !=
                Servidor.usuarioNoAutenticado;
        // globales.debug("Me pillaste");

        if (autenticado && msgErr.isNotEmpty) {
          // tenemos que darle un retraso ya que mostrar el diálogo
          // mientras se está construyendo provoca un error
          globales.muestraDialogoDespuesDe(context, msgErr, 0);

          // Mostramos mensaje
          //globales.muestraToast(context, msgOk);
        }

        return AvisoAccion(
          autenticado: autenticado,
          aviso: msgErr.isEmpty
              ? AppLocalizations.of(cntxt)!.esperandoRespuestaServidor
              : msgErr,
          msg: AppLocalizations.of(cntxt)!.recarga,
          icon: const Icon(Icons.refresh_rounded),
          // Recargamos la página de NuevoUsuario
          accion: () => {ns.recarga()},
        );
      } else if (datos.hasData) {
        // Tenemos datos?
        if (datos.data!.isEmpty) {
          // No hay empresas en los datos recibidos por el servidor
          return AvisoAccion(
            aviso: AppLocalizations.of(cntxt)!.noSeEncuentraEmpresasDadeAlta,
            msg: AppLocalizations.of(cntxt)!.anyadeEmpresa,
            icon: const Icon(Icons.add_business_rounded),
            accion: () => {
              popAndPush(context,
                  builder: (context) => NuevaEmpresa(token: widget.token)),
              // Eliminamos la página actual del historial de Navigator
              /*if (Navigator.canPop(context)) {Navigator.pop(context)},
              // Cargamos la página de NuevaEmpresa
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NuevaEmpresa(token: widget.token),
                ),
              )*/
            },
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

/// Widget utilizado para mostrar avisos y generar acciones
/// Tiene un widget que se muestra si hay posibilidad de ir atrás en la navegación
class AvisoAccion extends StatelessWidget {
  AvisoAccion(
      {Key? key,
      this.autenticado = true,
      required this.aviso, // mensaje de aviso
      required this.msg, // mensaje a mostrar en la acción a realizar
      required this.icon, // icono  a mostrar en la acción a realizar
      this.accion}) // Función que será llamada al pulsar el widget acccion
      : super(key: key);
  final bool autenticado;
  final String aviso;
  final String msg;
  final Icon icon;
  final Function? accion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Muestro Icono + aviso
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              Text(
                aviso,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 14.0),
              ),
            ],
          ),
          // Genero los widgets con la accion pasada
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: getWidgets(context),
          ),
        ],
      ),
    );
  }

  List<Widget> getWidgets(BuildContext context) {
    List<Widget> widgets = [];
    if (autenticado) {
      // widget atrás en navegación
      if (Navigator.canPop(context)) {
        widgets.add(
          TextButton.icon(
            label: Text(AppLocalizations.of(context)!.atras),
            icon: const BackButtonIcon(),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      }

      // Widget accion
      widgets.add(
        TextButton.icon(
          label: Text(msg),
          icon: icon,
          onPressed: () {
            if (accion != null) accion!();
          },
        ),
      );
    }

    return widgets;
  }
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
