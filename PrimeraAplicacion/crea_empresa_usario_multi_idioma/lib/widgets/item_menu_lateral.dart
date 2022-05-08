import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

class ItemMenuLat extends StatelessWidget {
  ItemMenuLat(
    this.iconData,
    this.accio, {
    Key? key,
    required this.traduce,
  }) : super(key: key);

  final IconData iconData;
  final String Function(AppLocalizations) traduce;
  final dynamic accio;
  bool _seleccionat = false;

  setSelectionat(dynamic accio) {
    _seleccionat = this.accio == accio;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(iconData),
        title: Text(traduce(AppLocalizations.of(context)!),
            style: Theme.of(context).textTheme.headline6),
        selected: _seleccionat,
        onTap: () {
          if (_seleccionat) {
            // Cerramos el menu abierto
            Navigator.pop(context);
          } else {
            //Ejecutamos la accion a realizar
            if (accio is String) {
              // cambiar pantalla
              Navigator.of(context).pushNamed(accio);
            } else {
              // o la acción que se pase
              accio(context);
            }
          }
        },
      ),
    );
  }
}
