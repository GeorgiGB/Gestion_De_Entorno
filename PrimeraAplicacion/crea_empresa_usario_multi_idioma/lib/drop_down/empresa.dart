import 'package:crea_empresa_usario/globales.dart' as globales;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import '../widgets/dropdownfield.dart';

Future<List<EmpresCod>> fetchPhotos(String token) async {
  String url = globales.servidor + '/listado_empresas';
  final response = await http.post(
    Uri.parse(url),
    // Cabecera para enviar JSON
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    // Adjuntamos al body los datos en formato JSON
    body: jsonEncode(<String, String>{'emp_busca': 'a', 'ust_token': token}),
  );

  /*final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));*/

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parsePhotos, response.body);
}

// A function that converts a response body into a List<Photo>.
List<EmpresCod> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  parsed.removeAt(0);
  globales.debug(parsed);
  return parsed.map<EmpresCod>((json) => EmpresCod.fromJson(json)).toList();
}

class EmpresCod {
  final int emp_cod;
  final String emp_nombre;

  const EmpresCod({
    required this.emp_cod,
    required this.emp_nombre,
  });

  factory EmpresCod.fromJson(Map<String, dynamic> json) {
    globales.debug("------------a");
    return EmpresCod(
      emp_cod: json['emp_cod'] as int,
      emp_nombre: json['emp_nombre'] as String,
    );
  }
}

class DropDownEmpresa {
  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  Widget getListEmpresasa({required String token}) {
    globales.debug('llamadon al servidor por lo tanto un future');
    return Column();
  }

  Widget getListEmpresas({required List<String> items}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          "DropDown & Testfield",
          style: TextStyle(fontSize: 20.0),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 20.0,
        ),

        // lets create a dummy list that we need to show
        DropDownField(
          controller: citiesSelected,
          hintText: "Select any City",
          enabled: true,
          itemsVisibleInDropdown: 5,
          items: items,
          onValueChanged: (value) {
            selectCity = value;
          },
        ),
        SizedBox(height: 20.0),
        Text(
          selectCity,
          style: TextStyle(fontSize: 20.0),
          textAlign: TextAlign.center,
        ),
      ],
    );

    /*return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 50,
          color: Colors.amber[colorCodes[index]],
          child: Center(child: Text('Entry ${entries[index]}')),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );*/
  }
}

String selectCity = "";
final citiesSelected = TextEditingController();

 /*DropDownEmpresa().getListEmpresas(items: <String>[
            "Saludo",
            "Kolkatta",
            "kurat",
            "LA",
            "Whasington",
            "New Jersey",
            "Allahabad",
            "Jalandar",
            "Vassi"
          ]),*/