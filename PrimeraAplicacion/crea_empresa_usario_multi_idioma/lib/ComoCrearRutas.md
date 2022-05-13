# Cómo crear rutas de navegación y añadirlas al Menu lateral de la aplicación

1. Copia todo el siguiente codigo y guárdalo en un archivo *.dart:*pon_tu_nombre_archivo.dart*
  
    ```dart
    import 'package:flutter/material.dart';
    import 'main.dart';

    // Imports multi-idioma ---------------------
    import 'package:flutter_gen/gen_l10n/app_localizations.dart';
    // Fin imports multi-idioma ----------------

    /// En este fichero se encuentra un plantilla básica que sigue la estructura genérica
    /// para crear una pantalla que mantenga la estructura básica de la aplicación
    
    class EjemploPantalla extends StatefulWidget {
      /// Identificador único, cambia el id, 'EjemploCambiaNombreIdentificador',
      /// por otro más apropiado.
      static const String id = 'EjemploCambiaNombreIdentificador';

      const EjemploPantalla({Key? key, required this.token}) : super(key: key);
      final String? token;
      @override
      State<EjemploPantalla> createState() => _EjemploPantallaState();
    }

    class _EjemploPantallaState extends State<EjemploPantalla> {
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.ejemploCambiaNombre,
              )
            ],
          )),
        );
      }
    }

    ```

2. En el archivo *main.dart* introducimos el "import:" de donde se encuentre el archivo *pon_tu_nombre_archivo.dart*

    ```dart
    import 'package:crea_empresa_usario/pon_tu_nombre_archivo.dart';
    ```

    Recuerda cambiar ***import 'package:crea_empresa_usario/pon_tu_nombre_archivo.dart'*** al package adecuado.

3. Ahora, en la función privada de alto nivel: [_inicializaNavegacion], del archivo main.dart añadimos el siguiente código

    ```dart
      // Inicializamos EjemploPantalla
        MyApp._addruta(
            Navega(EjemploPantalla.id,
                titulo: (AppLocalizations traduce) {

                  return traduce.nuevaEmpresa;
                },
                constructor: (token) => EjemploPantalla(token: token!),
                itemMenu: IconTraduce(
                  Icons.add_business_rounded,
                  traduce: (traduce) {
                    return traduce.ejemploCambiaNombre;
                  },
                )));
    ```

    Este código hace que  que hará que tengamos una pantalla con:
      - Un AppBar con título
      - El menú lateral
      - El respectivo item de menú con icono, texto y la acción correspondiente para cargar la pantalla.

   *Recuerda Cambiar el nombre de clase **«EjemploPantalla»** por el nombre de la clase que escojas*.

## Parámetros completos para añadir una pantalla a la estructura de la aplicación

1. Método estático ***MyApp._addruta(String id, Navega navegante)*** utilizado para añadir la ruta al parámetro *routes:* del constructor **MaterialApp**

    - **String *id***, el identificador que utiliza el componente de navegación.

    - **Navega *navegante***, el objeto que contien todos los componentes para crear la navegación

2. La classe **Navega** en su constructor los parámetros son:

    ```dart
    Navega(
        // Cadena utilizado para crear un identificado único
        // Si se utiliza el mismo 'id' para crear otro objeto Navega
        // lanzará un error por id duplicado
        id: String,
        {
        // Este parámetro puede ser un [Widget] o una
        // función anónima que devuelve un [String].
        // el tipo de la función és el siguiente [String Function(AppLocalizations)]
        titulo: dynamic,

        // Utilizado conjuntamente con 'nombreRuta' 
        // por el objeto 'routes:' del constructor **MaterialApp**
        required Widget Function(String?) constructor,

        // Opcional si no se utiliza la se creará a partir del 'id'
        // de la siguiente forma «ruta = '/' + (nombreRuta?? id)»
        String? nombreRuta,

        // Acepta un [Widget] o un [IconTraduce] para crear
        // el ítem de menú lateral.
        dynamic? itemMenu,

        // Si la pantalla necesita de un token para cargarse,
        // el ítem de menú se deshabilitará y, si se intenta
        // cargar dicha pantalla, se redirigirá a la pantalla
        // indicada en [MyApp.pantallaControl]
        bool conToken = true,

    ```

3. La Clase ***IconTraduce***, es una clase utilizada para realizar la creación de un item de menú a nivel interno. Dispone de un constructor nombrado, por lo que podemos utilizar el constructor que más sea conveniente.

    ```dart
    class IconTraduce {

      /// [Icon]
      late final Icon icon;

      /// Función al que le pasamos un [AppLocalizations] y nos
      /// devuelve  una cadena traducida
      final String Function(AppLocalizations) traduce;

      /// Utilizamos un [icon] y la función anonima [traduce]
      IconTraduce(this.icon, {required this.traduce});

      /// Con un [IconData] y la función anónima [traduce]
      IconTraduce.iconData(IconData iconData, {required this.traduce})
          : icon = Icon(iconData);
    }
    ```
