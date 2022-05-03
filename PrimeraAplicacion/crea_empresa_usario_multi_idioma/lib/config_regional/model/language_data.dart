import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class LanguageData {
  final String bandera;
  final String idioma;
  final String lenguajeCodigo;

  LanguageData(this.bandera, this.idioma, this.lenguajeCodigo);
  // para obtener las banderas podemos ir a:
  // https://emojipedia.org/flags/
  // y buscamos la cadena de caracteres correspondientes a la bandera

  // Lista para rellenar con los datos:
  //  flag:bandera, name: nombre_idioma, lenguajeCodigo: codigo lenguaje

  static final List<LanguageData> languageList = <LanguageData>[
    LanguageData("🇺🇸", "English", 'en'),
    LanguageData("🇪🇸", "Español", "es"),
    LanguageData("🇫🇷", "Frances", "fr"),
  ];

  static LanguageData? getLanguageData(String? insignia) {
    LanguageData? ld = null;
    if (insignia == null) {
      ld = languageList.first;
    } else {
      if (insignia != null) {
        for (var bd in languageList) {
          if (bd.bandera == insignia || bd.lenguajeCodigo == insignia) {
            ld = bd;
            break;
          }
        }
      }
      return ld;
    }
  }

  static LanguageData? _lenguage = languageList.first;
  static LanguageData? get lenguage => _lenguage;
}

// Para comentar  como funciona las SharedPreferences

const String prefBandera = "SelectedLanguageData";

Future<LanguageData?> setLenguaje(String bandera) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(prefBandera, bandera);
  return _lenguage(bandera);
}

Future<LanguageData?> getLenguajeData() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String? bandera = _prefs.getString(prefBandera);
  return _lenguage(bandera);
}

LanguageData? _lenguage(String? bandera) {
  LanguageData._lenguage = LanguageData.getLanguageData(bandera);
  return bandera != null && bandera.isNotEmpty
      ? LanguageData.getLanguageData(bandera)
      : null;
}

void changeLanguageData(String bandera) async {
  LanguageData._lenguage = await setLenguaje(bandera);

  //MyApp.setLocale(context, LanguageData._lenguage);
}
