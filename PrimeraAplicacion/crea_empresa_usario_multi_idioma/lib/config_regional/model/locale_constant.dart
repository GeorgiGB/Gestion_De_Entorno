import 'dart:ui';

import 'package:crea_empresa_usario/config_regional/model/language_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

// Para comentar  como funciona las SharedPreferences

const String prefSelectedLanguageCode = "SelectedLanguageCode";

Future<Locale?> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(prefSelectedLanguageCode, languageCode);
  return _locale(languageCode);
}

Future<Locale?> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String? languageCode = _prefs.getString(prefSelectedLanguageCode);
  return _locale(languageCode);
}

Locale? _locale(String? languageCode) {
  return languageCode != null && languageCode.isNotEmpty
      ? Locale.fromSubtags(languageCode: languageCode)
      : null;
}

void changeLanguage(BuildContext context, LanguageData languageCode) async {
  var _locale = await setLocale(languageCode.lenguajeCodigo);
  changeLanguageData(languageCode.bandera);
  MyApp.setLocale(context, _locale);
}
