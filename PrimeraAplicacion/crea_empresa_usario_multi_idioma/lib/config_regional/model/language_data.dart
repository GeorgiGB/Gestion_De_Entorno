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

  static List<LanguageData> languageList() {
    return <LanguageData>[
      LanguageData("🇺🇸", "English", 'en'),
      LanguageData("🇪🇸", "Español", "es"),
      LanguageData("🇫🇷", "Frances", "fr"),
    ];
  }
}
