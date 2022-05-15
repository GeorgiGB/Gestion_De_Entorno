import 'package:crea_empresa_usario/config_regional/model/language_data.dart';
import 'package:crea_empresa_usario/config_regional/model/locale_constant.dart';
import 'package:crea_empresa_usario/config_regional/opciones_idiomas/ops_lenguaje.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Para comentar  como funciona las SharedPreferences

//const String prefSelectedLanguageCode = "SelectedLanguageCode";

const String claveSesion = "guardaSesion";
const String mantenSesion = "mantenSesion";
const String guardar = "ok";

Future<String?> cargaPreferencia() async {
  // encadenamos futuros
  // Obtenemos locale
  await getLocale();

  // Obtenemos LenguageData
  LanguageDropDown.languageData = await getLenguajeData();

  // Obtenemos la session y la devolvemos
  return getSesion(claveSesion);
}

Future<String?> setPreferencias(String preferencia, String valor) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(preferencia, valor);
  return valor;
}

Future<bool> removePreferencias(String preferencia) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  return await _prefs.remove(preferencia);
}

Future<String?> getSesion(String preferencia) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String? valor = _prefs.getString(preferencia);
  return valor;
}
