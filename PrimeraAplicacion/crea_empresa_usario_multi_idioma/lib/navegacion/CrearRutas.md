# Para crear rutas de navegación

1. Creamos el widget que queremos mostrar por pantalla

2. En la clase Rutas del paquete "package:crea_empresa_usario/navegacion" añadimos encontremos el mapa: Map<String, String> rutas y tenemos que añadir un clave que identifique la nueva ruta que vamos a crear
Rutas.rutas['EmpresaNueva'] = '/EmpresaNueva'

3. A continuación en el mapa de constructores
Map<String, Widget Function(String?)> constructoresWidgets, añadimos una clave que haga referéncia al constructor que necesitará para cargar la pantalla i contendrà la ruta indicada en el punto 2 y el constructor
    * Rutas.rutas['EmpresaNueva']
    * NuevaEmpresa (token: token!)

    combinado de la siguiente forma:

```dart
// El token hace referencia al parámetro
// que le vamos a pasar en este caso un String ja que así está definido en el constructor de la clase [NuevaEmpresa]
Rutas.constructoresWidgets[Rutas.rutas['EmpresaNueva']!]= (token) => NuevaEmpresa(
          token: token!,
        );
```

4. Ahora crearemos una clase que extienda a la clase abstracta PantallasMenu:

```dart
/// Clase utilizada para mostrar la Pantalla de [NuevaEmpresa] extiende a la clase [PantallasMenu]
/// Cargará la pantalla de [NuevaEmpresa] porque asi lo indicamos en [claveConstructor]
/// con un widget [Text] para el título
///
/// Por defecto le decimos que incluya un menu lateral y que requiere de [_token]
///
/// Necesita el parámetro [AppLocalizations]traduce para poner la traducción adecuada del título
///
class EmpresaNueva extends PantallasMenu {
  EmpresaNueva(BuildContext context, AppLocalizations traduce, {Key? key})
      : super(Text(traduce.nuevaEmpresa),
            key: key, claveConstructor: Rutas.rutas['EmpresaNueva']!);
}
```

5. Una vez hechos los pasos anteriores solo queda añadir la ruta en el parametro routes de la clase [MaterialApp] que se encuetra en el archivo main.dart. Esta ruta ha de pasr todos los parámetros que necesita el constructor de PantallasMenu:

```dart
    MaterialApp(
        ...
        routes: {
        ...,
        Rutas.rutas['EmpresaNueva']!: (context) => EmpresaNueva(context, _traduce),...
        },
        ...
    )
```

6. Ahora para poder cargar la pantalla que queremos en la parte de código que queramos utilizaremos el siguiente código

```dart
// Necesitamos pasar un token al constructor argumentos por tanto utilizaremos la clase [ArgumentsToken] para adjuntarle el toke
...
onTap: () {
    vesA(Rutas.rutas['EmpresaNueva']!, context,
        // Pasamos los argumentos
        arguments: ArgumentsToken(token));
    }

// o utilizando la función que se encuetra en el archivo navega.dart
...
onTap: () {
     aEmpresaNueva(context, arguments: ArgumentsToken(token));
```

7. El último paso es crear un ítem de menú para que aparezca en el menú lateral[MenuLateral]  y, en este caso, necesita de token

```dart
MenuLateral.anyadeItem(
    // Añade empresa
    ItemMenu(Icons.add_business_rounded, Rutas.rutas['EmpresaNueva']!,
        funcionTraduce: (traduce) {
      return traduce.anyadeEmpresa;
    })
);

```
