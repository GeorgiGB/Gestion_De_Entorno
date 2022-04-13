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
    body: jsonEncode(<String, String>{'emp_busca': '', 'ust_token': token}),
  );

  _context = context;
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseEmpresas, response.body);
}

// A function that converts a response body into a List<Photo>.
List<EmpresCod> parseEmpresas(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  if (!parsed[0]['bOk'].toString().parseBool()) {
    String msg = '';
    int cod_error = int.parse(parsed[0]['cod_error']);
    if (cod_error == 401) {
      msg = AppLocalizations.of(_context!)!.codErrorLogin401;
    } else {
      msg = AppLocalizations.of(_context!)!.errNoEspecificado +
          ': ' +
          parsed[0]['cod_error'];
    }
    globales.muestraDialogo(_context!, msg);
    _context = null;
    return [];
  }

  // Eliminamos el primer elemento que contiene la información de si todo es correcto
  parsed.removeAt(0);

  List<EmpresCod> lista =
      parsed.map<EmpresCod>((json) => EmpresCod.fromJson(json)).toList();
  lista = [];
  throw Exception('Some arbitrary error');
  //return lista;
}

dos(nuevoUsuarioState ns) {
  //await Future.delayed(Duration(milliseconds: 250));
  ns.controlesVisibilidad(false);
  print("ocultando");
}

FutureBuilder<List<EmpresCod>> dropDownEmpresas(
    nuevoUsuario widget, nuevoUsuarioState ns, BuildContext cntxt) {
  var ok = true;
  return FutureBuilder<List<EmpresCod>>(
    future: !ns.mostraFormulario.visible
        ? null
        : buscaEmpresas(http.Client(), widget.ust_token, cntxt).onError((error, stackTrace) {
            // Ocultamos el widget mostraFormulario
            if (ns.mostraFormulario.visible) dos(ns);
            return <EmpresCod> [];
          }),
    builder: (context, datos) {
      if (datos.hasError) {
        return Center(
          child: Text(AppLocalizations.of(context)!.servidorNoDisponible),
        );
      } else if (datos.hasData) {
        if (datos.data!.isNotEmpty) {
          // mostramos empresas
          return ListaEmpresas(empresas: datos.data!);
        } else {
          // no se han encontrado empresas
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
        }
      } else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    },
  );
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
