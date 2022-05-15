import 'package:crea_empresa_usario/globales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../model/language_data.dart';
import '../model/locale_constant.dart';

class LanguageDropDown {
  static late LanguageData languageData;

  DropdownButton getDropDown(BuildContext context) {
    return DropdownButton<LanguageData>(
      elevation: 15,
      iconSize: 15,
      hint: _getHint(context),
      onChanged: (LanguageData? language) {
        changeLanguage(context, language!);
        // no lamamos a setLocale() por que el
        // método changeLanguage() ya lo hace internamente
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
    LanguageData ld = LanguageDropDown.languageData;
    /*ld ??= LanguageData.getLanguageData(
        dimeLocal(context).languageCode.toString());*/
    return /*ld == null
        ? Text(AppLocalizations.of(context)!.seleccionaIdioma)
        : */
        Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(
          ld.bandera,
          style: TextStyle(fontSize: 20),
        ),
        /*Text(' '),
              Text(ld.idioma),*/
      ],
    );
  }
}
