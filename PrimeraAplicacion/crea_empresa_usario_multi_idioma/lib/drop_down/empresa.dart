import 'package:flutter/material.dart';

import '../widgets/dropdownfield.dart';

class DropDownEmpresa {
  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  Widget getListEmpresasa() {
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
          items: cities,
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

// creating a list of strings

List<String> cities = [
  "Mumbai",
  "Kolkatta",
  "kurat",
  "LA",
  "Whasington",
  "New Jersey",
  "Allahabad",
  "Jalandar",
  "Vassi"
];
