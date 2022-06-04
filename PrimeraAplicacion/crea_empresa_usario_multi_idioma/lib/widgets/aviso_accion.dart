import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

/// Widget utilizado que muestra un mensaje, [msg], asociado a una acción, [accion]
/// que mostrará [aviso] que se mostrará junto con el icon[icon]
///
/// Si estamos [autenticado] y podemos retroceder en el historia se mostrarà un widget
/// para volver hacia atràs
///
class AvisoAccion extends StatelessWidget {
  AvisoAccion(
      {Key? key,
      this.autenticado = false,
      required this.aviso, // mensaje de aviso
      required this.msg, // mensaje a mostrar en la acción a realizar
      required this.icon, // icono  a mostrar en la acción a realizar
      this.accion}) // Función que será llamada al pulsar el widget acccion
      : super(key: key);

  final bool autenticado;
  final String aviso;
  final String msg;
  final Icon icon;

  /// No acepta parámetros
  final Function? accion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Muestro Icono + aviso
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Icono mostrando advertencia
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),

              // El aviso que queremos mostrar
              Text(
                aviso,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 14.0),
              ),
            ],
          ),

          // Genero los widgets con la accion pasada
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: getWidgets(context),
          ),
        ],
      ),
    );
  }

  List<Widget> getWidgets(BuildContext context) {
    List<Widget> widgets = [];

    // Para ir atrás en el historial tenemos que estar autenticados
    if (autenticado) {
      // widget atrás en navegación
      if (Navigator.canPop(context)) {
        widgets.add(
          TextButton.icon(
            label: Text(AppLocalizations.of(context)!.atras),
            icon: const BackButtonIcon(),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      }

      // Widget que muestra el icon, el msg y ejecuta la acción passada
      widgets.add(
        TextButton.icon(
          label: Text(msg),
          icon: icon,
          onPressed: () {
            if (accion != null) accion!();
          },
        ),
      );
    }

    return widgets;
  }
}
