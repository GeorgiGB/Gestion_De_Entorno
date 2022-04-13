import 'package:crea_empresa_usario/nuevo_usua.dart';
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

// Una vez se muestran los campos de formulario esta función no se volverá a ejecutar.
FutureBuilder<List<EmpresCod>> dropDownEmpresas(
    nuevoUsuario widget, nuevoUsuarioState ns, BuildContext cntxt) {
  late String msg_err;

  return FutureBuilder<List<EmpresCod>>(
    future: ns.mostraFormulario.visible
        ? null
        : buscaEmpresas(http.Client(), widget.ust_token, cntxt).onError(
            (error, stackTrace) {
              if (error is ExceptionServidor) {
                if (error.codError == 401) {
                  msg_err = AppLocalizations.of(_context!)!.codErrorLogin401;
                } else {
                  msg_err = AppLocalizations.of(_context!)!.errNoEspecificado +
                      ': ' +
                      error.codError.toString();
                }
              } else {
                msg_err = AppLocalizations.of(cntxt)!.servidorNoDisponible;
              }
              throw error!;
            },
          ),
    builder: (context, datos) {
      if (datos.hasError) {
        globales.muestraDialogoDespuesDe(context, msg_err, 120);
        return Center(
          child: Text(msg_err),
        );
      } else if (datos.hasData) {
        // Tenemos datos?
        if (datos.data!.isEmpty) {
          // No hay empresas en los datos recibidos por el servidor
          String msg =
              AppLocalizations.of(context)!.noSeEncuentraEmpresasDadeAlta;
          return Center(
            child: Text(
              msg,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 14.0),
            ),
          );
        } else {
          // Ja podemos mostrar los campos de formulario
          ns.controlesVisibilidad(true);

          // Ahora creamos el dropDown de Empresas
          return ListaEmpresas(empresas: datos.data!);
        }
      } else {
        // Esperando datos del servidor
        return Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 15),
              Text(AppLocalizations.of(context)!.esperandoAlServidor),
            ],
          ),
        );
      }
    },
  );
}

BuildContext? _context;

Future<List<EmpresCod>> buscaEmpresas(
    http.Client client, String token, BuildContext context) async {
  String url = globales.servidor + '/listado_empresas';
  final response = await client.post(
    Uri.parse(url),
    // Cabecera para enviar JSON
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    // Adjuntamos al body los datos en formato JSON
    body: jsonEncode(<String, String>{'emp_busca': 'xxx', 'ust_token': token}),
  );

  _context = context;
  // Use the compute function to run _parseEmpresas in a separate isolate.
  return compute(_parseEmpresas, response.body);
}

class ExceptionServidor implements Exception {
  int codError;

  ExceptionServidor(this.codError);
}

// A function that converts a response body into a List<EmpresCod>.
List<EmpresCod> _parseEmpresas(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  // ha ido correcto?
  if (parsed[0]['bOk'].toString().parseBool()) {
    // Eliminamos el primer elemento que contiene la información de si todo es correcto
    parsed.removeAt(0);
    return parsed.map<EmpresCod>((json) => EmpresCod.fromJson(json)).toList();
  } else {
    int codError = int.parse(parsed[0]['cod_error']);
    print("lanzo error");
    throw ExceptionServidor(codError);
    /*globales.muestraDialogo(_context!, msg);
    _context = null;
    return [];*/
  }
}

class EmpresCod implements DropDownIntericie {
  final int emp_cod;
  final String emp_nombre;

  const EmpresCod({
    required this.emp_cod,
    required this.emp_nombre,
  });

  factory EmpresCod.fromJson(Map<String, dynamic> json) {
    return EmpresCod(
      emp_cod: json['emp_cod'] as int,
      emp_nombre: json['emp_nombre'] as String,
    );
  }

  Widget
      get widget => //Text(emp_nombre); // Es pot mostrar qualsevol tipus de widget
          Row(children: [Text(emp_cod.toString()), Text(' - ' + emp_nombre)]);

  @override
  String string() {
    return emp_nombre;
  }

  @override
  bool operator ==(dynamic other) {
    return other is String && emp_nombre.contains(other) ||
        other is EmpresCod &&
            other.emp_cod == emp_cod &&
            other.emp_nombre == emp_nombre;
  }
}

class ListaEmpresas extends StatelessWidget {
  ListaEmpresas({Key? key, required this.empresas}) : super(key: key);

  final List<EmpresCod> empresas;

  final citiesSelected = TextEditingController();
  late EmpresCod selectCity;
  @override
  Widget build(BuildContext context) {
    return DropDownField(
      controller: citiesSelected,
      focusNode: FocusNode(),
      hintText: AppLocalizations.of(context)!.selecionaEmpresa,
      enabled: true,
      itemsVisibleInDropdown: 5,
      items: empresas,
      onValueChanged: (value) {
        selectCity = value as EmpresCod;
        print(selectCity.emp_nombre);
      },
    );
  }
}
