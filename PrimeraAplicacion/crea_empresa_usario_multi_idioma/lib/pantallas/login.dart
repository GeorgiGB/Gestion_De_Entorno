import 'package:crea_empresa_usario/colores.dart';
import 'package:crea_empresa_usario/main.dart';
import 'package:crea_empresa_usario/navegacion/item_menu_lateral.dart';
import 'package:crea_empresa_usario/navegacion/menu_lateral.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/navegacion/rutas_pantallas.dart';
import 'package:crea_empresa_usario/pantallas/nueva_empr.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/labeled_checkbox.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:crea_empresa_usario/ejemplo_pantalla.dart';
import 'package:flutter/material.dart';
import '../globales.dart' as globales;

import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Widget DropdownButton para selecionar idioma
// Fin imports multi-idioma ----------------

import 'package:crea_empresa_usario/ejemplo_pantalla.dart';

/// Clase encargada de preparar la navegación y estructura básica del wiget [Login]
///
/// Más opciones en [PantallaCambiarNombre]

class PantallaLogin extends PantallasMenu {
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
    ruta = Ruta(id, nombreRuta, (token) => Login());
    print(ruta.id);
    //Pasamos valores configuración de pantalla
    cfgPantalla = PantallasConfig(
        conToken: conToken,
        conItemMenu: conItemMenu,
        menuLateral: menuLateral,

        // Añade Ejemplo, más opciones sobre [ItemMenu] en su archivo
        // correspondiente
        itemMenu: ItemMenu(Icons.login_rounded, ruta.hacia,
            necesitaToken: conToken, funcionTraduce: (traduce) {
          return traduce.iniciaSesion;
        }));
  }

  static Future<T?> voy<T extends Object?>(BuildContext context,
      {Object? arguments}) {
    return vesA(ruta.hacia, context, arguments: arguments);
  }

  PantallaLogin(BuildContext context, {Key? key})
      : super(Text(AppLocalizations.of(context)!.iniciaSesion), ruta.id,
            key: key,
            menuLateral: cfgPantalla.menuLateral,
            conToken: cfgPantalla.conToken);
}

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key) {}
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late AppLocalizations traduce;

  bool guardaSesion = false;

  // Creamos el controlador campo de usuario
  final TextEditingController _usuario = TextEditingController();

  // Creamos el controlador campo de contraseña
  final TextEditingController _pwd = TextEditingController();
  // Widget Focus para enviari el foco al compo contraseña
  final FocusNode _contrasenaFocus = FocusNode();

  // Al realizar el login en el servidor y esperar su respuesta tenemos que saber
  // si estamos esperando la respuesta del servidor y así evitar múltiples peticiones al servidor
  bool esperandoLogin = false;

  @override
  Widget build(BuildContext context) {
    traduce = AppLocalizations.of(context)!;

    //traduce = AppLocalizations.of(context)!;
    // TODO poner información en blanco
    // informacion predeterminada que luego se borrara mas adelante
    _usuario.text = "Joselito";
    _pwd.text = "1234";

    return Scaffold(
      /*appBar: AppBar(
          // Barra aplicación tiutlo
          title: Text(AppLocalizations.of(context)!.identifica),

          // Añadimos el DropButton de elección de idioma
          actions: [
            LanguageDropDown().getDropDown(context),
          ]),*/
      body: SingleChildScrollView(
        //Previene BOTTOM OVERFLOWED
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  hintText: traduce.hintTuNombre,
                  labelText: AppLocalizations.of(context)!.usuario),
              controller: _usuario,
              onFieldSubmitted: (String value) {
                // Al pulsar enter ponemos el foco en el campo contraseña
                FocusScope.of(context).requestFocus(_contrasenaFocus);
              },
            ),
            const SizedBox(height: 30),

            TextFormField(
              decoration: InputDecoration(
                  hintText: traduce.hintContrasena,
                  labelText: AppLocalizations.of(context)!.contrasena),
              controller: _pwd,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              focusNode: _contrasenaFocus,
              onFieldSubmitted: (String value) {
                // al pulsar enter en este campo ya realizamos el login
                _login();
              },
            ),
            const SizedBox(height: 30),

            // Boton acceso y guardar sessión
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Botón para realizar el login
                ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.acceso),
                  onPressed: () {
                    _login();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: PaletaColores.colorMorado),
                ),
                // Separación
                const SizedBox(
                  width: 20,
                ),

                // Guardamos Sesión?
                LabeledCheckbox(
                  label: traduce.guardaSesion,
                  chekBoxIzqda: false,
                  textStyle: globales.estiloNegrita_16,
                  // Mientras este activo
                  // No permitira al usuario escribir una contraseña
                  value: guardaSesion,
                  onChanged: (bool? value) {
                    setState(() {
                      guardaSesion = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _login() {
    if (esperandoLogin) {
      EnCualquierLugar().muestraSnack(context, traduce.esperandoAlServidor);
    } else {
      // Obtenemos usuario y la contraseña introducidas
      String nombre = _usuario.text;
      // Contraseña
      String pwd = _pwd.text;

      if (nombre.isEmpty || pwd.isEmpty) {
        // No tiene datos Mostramos avisos
        globales.muestraDialogo(context, traduce.primerRellenaCampos);
      } else {
        esperandoLogin = true;

        Servidor.login(context, nombre, pwd).then((response) {
          if (response != null && response.statusCode == Servidor.ok) {
            final parsed =
                jsonDecode(response.body).cast<Map<String, dynamic>>();

            var token = parsed[0]['token'];

            // Guardamos sesion?
            MyApp.mantenLaSesion(guardaSesion, token);

            // Establecmos el token para uso de la aplicación
            MyApp.setToken(context, token);
            print("hola");
            vesA(MyApp.despuesDeLoginVesA, context,
                arguments: ArgumentsToken(token));
          }
        }).whenComplete(() {
          esperandoLogin = false;
        });
      }
    }
  }
}
