import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

class CabeceraMenuLat extends StatelessWidget {
  CabeceraMenuLat({
    Key? key,
    required this.traduce,
  }) : super(key: key);

  final String Function(AppLocalizations) traduce;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: DrawerHeader(
        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        margin: EdgeInsets.zero,
        child: Stack(children: [
          Positioned(
              child: Text(traduce(AppLocalizations.of(context)!),
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Colors.white))),
          Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                  icon: Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).pop())),
          Positioned(
            bottom: 0,
            right: 0,
            child: LanguageDropDown().getDropDown(context),
          ),
        ]),
      ),
    );
  }
}
