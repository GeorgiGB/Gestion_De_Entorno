import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EnCualquierLugar {
  static muestraSnack(BuildContext context, String msg,
      {Duration duration = const Duration(seconds: 2),
      Function? onHide,
      Alignment alignment = Alignment.center,
      Color bgColor = const Color.fromARGB(200, 0, 200, 0)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Función que se ejecutará en el momento que haya
        // pasado el tiempo de duración de mostrar el snackbar
        onVisible: onHide==null? null: () {
          Future.delayed(duration, () async {
            onHide();
          });
        },
        // Necesario Para mostrar un snack bar centrado
        // fondo transparente
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        // no quieros su sombra
        elevation: 0,
        // contenido centrado
        content: Align(
          alignment: alignment,

          // El contenedor
          child: Container(
            padding: const EdgeInsets.all(10.0),

            // Decoración del contenedor
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(10.0),
                right: Radius.circular(10.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),

            // Contenido en una columna
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // El texto ha mostrar
                Text(
                  msg,
                ),
                //),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
