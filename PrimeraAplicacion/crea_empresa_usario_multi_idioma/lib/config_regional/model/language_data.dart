import 'package:shared_preferences/shared_preferences.dart';

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
    LanguageData("🇪🇸", "Español", "es"),
    LanguageData("🇬🇧", "English", 'en'),
    LanguageData("🇫🇷", "Frances", "fr"),
  ];

  static LanguageData getLanguageData(String? insignia) {
    if (insignia == null) {
      return languageList.first;
    } else {
      for (var bd in languageList) {
        if (bd.bandera == insignia || bd.lenguajeCodigo == insignia) {
          return bd;
        }
      }
      return languageList.first;
    }
  }

  static LanguageData _lenguage = languageList.first;
  static LanguageData get lenguage => _lenguage;
}

// Para comentar  como funciona las SharedPreferences

const String prefBandera = "SelectedLanguageData";

/// Guardamos en preferéncia la bandra de referencia
/// Si esa bandera no se encuentra en la lista de [LanguageData]
/// devolverá e primer elemento de la lista [LanguageData]
Future<LanguageData> setLenguaje(String bandera) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(prefBandera, bandera);
  return _lenguage(bandera);
}

/// Obtenmos la bandera de las preferéncias.
/// Si esa bandera no se encuentra en la lista de [LanguageData]
/// devolverá e primer elemento de la lista [LanguageData]
Future<LanguageData> getLenguajeData() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String? bandera = _prefs.getString(prefBandera);
  return _lenguage(bandera);
}

LanguageData _lenguage(String? bandera) {
  LanguageData._lenguage = LanguageData.getLanguageData(bandera);
  return LanguageData._lenguage;
}

void changeLanguageData(String bandera) async {
  LanguageData._lenguage = await setLenguaje(bandera);

  //MyApp.setLocale(context, LanguageData._lenguage);
}
