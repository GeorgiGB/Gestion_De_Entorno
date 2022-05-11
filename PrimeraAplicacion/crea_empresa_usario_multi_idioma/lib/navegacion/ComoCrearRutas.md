# Para crear rutas de navegación y añadirlas al Menu lateral de la aplicación

1. Creamos el widget que queremos mostrar por pantalla

1. En esta misma carpeta, está el archivo "rutas.dart", que contiene la clase [Ruta] con la variable rutas que és un Map<String, String>. Tenemos que añadir un clave que identifique la nueva ruta que vamos a crear:
   ```dart
    static final Map<String, String> rutas = <String, String>{
        ...,
        Rutas.rutas['EmpresaNueva'] = '/EmpresaNueva',
        ...
    }
   ```

1. A continuación en el mismo archivo, "rutas.dart", encontramos un mapa de constructores de Widgets "constructoresWidgets" Map<String, Widget Function(String?)>, al cual le tenemos que añadir una clave que haga referéncia al constructor que necesitará para cargar la pantalla y que contendrá la ruta indicada en el punto 2 y el constructor del Widget:

    ```dart
    // El token hace referencia al parámetro
    // que le vamos a pasar en este caso un String ja que así está definido en el constructor de la clase [NuevaEmpresa]
    static Map<String, Widget Function(String?)> constructoresWidgets =
        <String, Widget Function(String?)>{
            ...
            Rutas.rutas['EmpresaNueva']!: (token) => NuevaEmpresa( token: token!),
            ...
        }
    ```

1. En el fichero clases_constructoras.dart crearemos una nueva clase que extienda a la clase abstracta PantallasMenu que está en el fichero navega.dart:

    ```dart
    /// Clase utilizada para mostrar la Pantalla de [NuevaEmpresa] extiende a la clase abstracta [PantallasMenu]
    /// Cargará la pantalla de [NuevaEmpresa] porque asi lo indicamos en [claveConstructor]
    /// con un widget [Text] para el título
    ///
    /// Por defecto le decimos que incluya un menu lateral y que requiere de [_token]
    ///
    /// Para otras opciones ver la clase abstract [PantallasMenu]
    ...
    class EmpresaNueva extends PantallasMenu {
    EmpresaNueva(BuildContext context,  {Key? key})
        : super(Text(traduce.nuevaEmpresa),
                key: key, claveConstructor: Rutas.rutas['EmpresaNueva']!);
    }
    ...
    ```

1. Una vez hechos los pasos anteriores solo queda añadir la ruta en el parametro routes de la clase [MaterialApp] que se encuentra en el archivo main.dart. Esta ruta ha de pasar todos los parámetros que necesita el constructor de la nueva clase [EmpresaNueva] creada en el archivo "./navegacion/clases_constructoras.dart"

    ```dart
        MaterialApp(
            ...
            routes: {
            ...,
            Rutas.rutas['EmpresaNueva']!: (context) => EmpresaNueva(context),...
            },
            ...
        )
    ```

1. Ahora para poder cargar la pantalla que queremos, en este caso EmpresaNueva, en el archivo llamadas_constructores.dart, crearemos una funcion que llame al constructor en cuestion
    ```dart
    ... 
    /// Cómo su nombre indica cargará la pantalla de [EmpresaNueva]
    {Object? arguments}) Future<T?> aEmpresaNueva<T extends Object?>(BuildContext context,
        {Object? arguments}) {
    return vesA(Rutas.rutas['EmpresaNueva']!, context, arguments: arguments);
    }
    ...
    /// utilizando el método genérico [vesA]:
    /// Future<T?> vesA<T extends Object?>(String ruta, BuildContext context,
    ```
1. Ya podemos realizar cargar la pantalla [EmpresaNueva] desde cualquier parte del código con alguna de estás dos formas:

    ```dart
    // Como el constructo necesita el token, la funcion vesA o al constructor argumentos por tanto utilizaremos la clase [ArgumentsToken] para adjuntarle el toke
    ...
    onTap: () {
        vesA(Rutas.rutas['EmpresaNueva']!, context,
            // Pasamos los argumentos
            arguments: ArgumentsToken(token));
        }

    // o utilizando la función aEmpresaNueva
    ...
    onTap: () {
        aEmpresaNueva(context, arguments: ArgumentsToken(token));
    ```

    // ambas funciones estan en el archivo llamadas_constructores.dart

1. El último paso es crear un ítem de menú para que aparezca en el MenuLateral, lo haremos añadiendo un [ItemMenu] a través de la funció estática [MenuLateral.anyadeItem(ItemMenu)] que encontramos en el archivo menu_lateral.art

    ```dart
    ...
    MenuLateral.anyadeItem(
        // Añade empresa
        ItemMenu(Icons.add_business_rounded, Rutas.rutas['EmpresaNueva']!,
            funcionTraduce: (traduce) {
        return traduce.anyadeEmpresa;
        })
    );
    ...
    ```
    o directamente en la variable privada estática [MenuLatera._items]:
    ```dart
    static final List<Widget> _items = [
        ...
        // Añade empresa
        ItemMenu(Icons.add_business_rounded, Rutas.rutas['EmpresaNueva']!,
            funcionTraduce: (traduce) {
        return traduce.anyadeEmpresa;
        }),
        ...
    ```
    Para más opciones del [ItemMenu] mirar en el archivo item_menu_lateral.dart que es donde se encuentra el constructor de [ItemMenu]
