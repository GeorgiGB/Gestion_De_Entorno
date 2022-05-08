import 'package:crea_empresa_usario/globales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';
import '../model/language_data.dart';
import '../model/locale_constant.dart';

class LanguageDropDown {
  static LanguageData? languageData;

  DropdownButton getDropDown(BuildContext context) {
    return DropdownButton<LanguageData>(
      elevation: 15,
      iconSize: 15,
      hint: _getHint(context),
      onChanged: (LanguageData? language) {
        changeLanguage(context, language!);
      },
      items: LanguageData.languageList
          .map<DropdownMenuItem<LanguageData>>(
            (e) => DropdownMenuItem<LanguageData>(
              value: e,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    e.bandera,
                    style: TextStyle(fontSize: 15),
                  ),
                  //Text(e.idioma)
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _getHint(BuildContext context) {
    LanguageData? ld = LanguageData.lenguage ?? languageData;
    return ld == null
        ? Text(AppLocalizations.of(context)!.seleccionaIdioma)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                LanguageData.lenguage!.bandera,
                style: TextStyle(fontSize: 20),
              ),
              /*Text(' '),
              Text(LanguageData.lenguage!.idioma),*/
            ],
          );
  }
}
