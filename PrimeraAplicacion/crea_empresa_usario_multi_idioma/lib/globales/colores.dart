import 'package:flutter/material.dart';

class PaletaColores {
  // Color azul oscuro
  static const MaterialColor colorAzulOscuro =
      MaterialColor(0xff5938FF, <int, Color>{});

  //  Color verde claro
  static const MaterialColor colorVerde =
      MaterialColor(0xFF37EDB6, <int, Color>{});

  //  Color verde Oscuro
  static const MaterialColor colorMorado =
      MaterialColor(0xFF7600ff, <int, Color>{});

  //  Color rojo
  static const MaterialColor colorRojo =
      MaterialColor(0xFFFF5C68, <int, Color>{});

  //  Color gris oscuro
  static const MaterialColor colorGrisOscuro =
      MaterialColor(0xFF575757, <int, Color>{});

  // Color gris claro
  static const MaterialColor colorGrisClaro =
      MaterialColor(0xFFC6C6C6, <int, Color>{});

  static const MaterialColor colorBlanco =
      MaterialColor(0xFFFFFFFF, <int, Color>{});

  static const List<Color> listaColores = [colorAzulOscuro, colorVerde];
  static const List<Color> listaColores1 = [colorVerde, colorAzulOscuro];
}

PreferredSizeWidget appBarColoreada(String titulo) {
  return AppBar(
    title: Text(titulo, style: const TextStyle()),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: PaletaColores.listaColores,
        ),
      ),
      child: const Align(alignment: Alignment.center),
    ),
  );
}

StatelessWidget drawHeaderColoreado(String titulo) {
  return DrawerHeader(
    child: Text(titulo),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
          colors: PaletaColores.listaColores, tileMode: TileMode.clamp),
    ),
  );
}

// Uso para colores normales??
// Map<int, Color> colorVerde = {
//   900: const Color.fromRGBO(55, 237, 182, 1),
// };
//    MaterialColor azulOscuro = MaterialColor(0xFF5938FF, colorAzul);
//    MaterialColor verdeClaro = MaterialColor(0xFF37EDB6, colorVerde);