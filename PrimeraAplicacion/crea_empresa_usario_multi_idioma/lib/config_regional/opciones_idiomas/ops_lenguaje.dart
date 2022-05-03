import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';
import '../model/language_data.dart';
import '../model/locale_constant.dart';

class LanguageDropDown {
  DropdownButton getDropDown(BuildContext context) {
    return DropdownButton<LanguageData>(
      elevation: 15,
      iconSize: 15,
      hint: Text(AppLocalizations.of(context)!.seleccionaIdioma),
      onChanged: (LanguageData? language) {
        changeLanguage(context, language!.lenguajeCodigo);
      },
      items: LanguageData.languageList()
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
                  Text(e.idioma)
                ],
              ),
            ),
          )
          .toList(),
    );
  }
/*
  Locale? _locale(String? languageCode) {
    return languageCode != null && languageCode.isNotEmpty
        ? Locale(languageCode, '')
        : null;
  }*/
}
