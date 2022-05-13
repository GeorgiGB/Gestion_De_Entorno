# Para crear rutas de navegación y añadirlas al Menu lateral de la aplicación

1. Copia todo el siguiente codigo y guárdalo en un archivo *.dart: *pon_tu_nombre_archivo.dart*
  
    ```dart
    import 'package:flutter/material.dart';
    import 'package:crea_empresa_usario/navegacion/navega.dart';
    import 'package:crea_empresa_usario/navegacion/rutas_pantallas.dart';
    import 'package:crea_empresa_usario/navegacion/item_menu_lateral.dart';
    import 'package:crea_empresa_usario/navegacion/menu_lateral.dart';
    import 'package:crea_empresa_usario/ejemplo_pantalla.dart';
    import 'package:crea_empresa_usario/main.dart';


    // Imports multi-idioma ---------------------
    import 'package:flutter_gen/gen_l10n/app_localizations.dart';
    // Fin imports multi-idioma ----------------

    /// En este fichero se encuentra un plantilla básica que sigue la estructura genérica
    /// para crear una pantalla que mantenga la estructura básica de la aplicación.
    ///
    ///
    /// Más información en [PantallaCambiarNombre] <-- este no se ha de cambiar
    class PantallaCambiarNombre extends PantallasMenu {
      /// Cadena utilizada para crear las rutas de navegación
      /// Debe ser única ya que puede entrar en conflicto con las demás pantallas
      static late final Ruta ruta;
      static late final PantallasConfig cfgPantalla;

      ///añadir la ruta que será utilizada por el parámetro
      /// routes de la clase [MaterialApp] que encontraremos en el fichero main.dart
      /// Método encargado de preparar la navegación
      /// - id: el identificador del elemento de Navegación, debe ser único. Obligatorio
      /// - ruta: la cadena que identifica a la ruta, si no se pone se formará con el id
      /// - conToken: indica si para acceder a esta pantalla necesita el token de sesión. Opcional -> true
      /// - conItemMenu: nos pondrá un item de menú en lel menu lateral. Opcional -> true
      /// - menuLateral: si aparece el menú lateral en la pantalla. Opcional -> true
      static void preparaNavegacion(String id,
          {String? nombreRuta,
          bool conToken = true,
          bool conItemMenu = true,
          bool menuLateral = true}) {
        //
        ruta = Ruta(id, nombreRuta, (token) => CambiarNombre(token: token));
        //Pasamos valores configuración de pantalla
        cfgPantalla = PantallasConfig(
            conToken: conToken,
            conItemMenu: conItemMenu,
            menuLateral: menuLateral,

            // Añade Ejemplo, más opciones sobre [ItemMenu] en su archivo
            // correspondiente
            itemMenu: ItemMenu(Icons.abc_outlined, ruta.hacia,
                necesitaToken: conToken, funcionTraduce: (traduce) {
              return traduce.ejemploCambiaNombre;
            }));
      }

      static Future<T?> voy<T extends Object?>(BuildContext context,
          {Object? arguments}) {
        return vesA(ruta.hacia, context, arguments: arguments);
      }

      PantallaCambiarNombre(BuildContext context, {Key? key})
          : super(Text(AppLocalizations.of(context)!.ejemploCambiaNombre), ruta.id,
                key: key,
                menuLateral: cfgPantalla.menuLateral,
                conToken: cfgPantalla.conToken);
    }

    // Aquí finalizan los elementos básicos de un wiget que siga la estructura básica de la aplicación

    class CambiarNombre extends StatefulWidget {
      const CambiarNombre({Key? key, required this.token}) : super(key: key);
      final String? token;
      @override
      State<CambiarNombre> createState() => _CambiarNombreState();
    }

    class _CambiarNombreState extends State<CambiarNombre> {
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text("Cambia por tu widget")],
          )),
        );
      }
    }

    ```

2. En los nombres de clase donde encuentres *CambiarNombre* pones el nombre de clase que más se acople a lo que quieres hacer excepto en ***Más información en [PantallaCambiarNombre]***
  
3. En el archivo *main.dart* introducimos el "import:" de donde se encuentre el archivo *pon_tu_nombre_archivo.dart*
    ```dart
    import 'package:crea_empresa_usario/pon_tu_nombre_archivo.dart';
    ```
    ahora en el metodo *main()* del mismo archivo *main.dart* 
    ```dart
    void main() {
      ...
      PantallaCambiarNombre.preparaNavegacion('Cambiar Aqui');
      ...
      runApp(MyApp());
    }
    ```
    Recuerda cambiar ***import 'package:crea_empresa_usario/pon_tu_nombre_archivo.dart'*** al package adecuado y cambia también ***PantallaCambiarNombre*** al nombre de clase escogido.

    El método estático *preparaNavegacion()* tiene los siguientes parámetros
    ```dart
    static void preparaNavegacion(String id,
          {String? nombreRuta,
          bool conToken = true,
          bool conItemMenu = true,
          bool menuLateral = true})
    ```
    - id, String obligatorio,  es el identificador utilizado para obtener la ruta a través del método Ruta.getRuta(id).
    - nombreRuta, String si no indicamos nada la ruta se formará a partir del id:
  
        **ruta =  '/' + (nombreRuta?? id)**
    - conToken, bool opcional por defecto *true*, estamos diciendo que está pantalla necesita el token para acceder
    - conItemMenu, bool opcional por defecto *true*, de esta forma introduce un item de menu en el menú lateral.
    - menuLateral =  bool opcional por defecto *true*, decimos que estpantalla tenga un menú lateral.
    
4. En el mismo archivo main.dart hay que poner la ruta en el parámetro routes: del constructor MaterialApp de la siguiente forma:
    ```dart
    ...
    MaterialApp(
      ...
      routes: {
            PantallaCambiarNombre.ruta.hacia: (context) =>
                PantallaCambiarNombre(context),
      ...
      }

    )
    ```

### *Recuerda cambiar los nombres y referencias de clase.
## Esto es todo.