import 'package:crea_empresa_usario/escoge_opciones.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/preferencias/preferencias.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart' as Servidor;
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import 'globales.dart' as globales;

import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Constantes donde se guarda el idoma escogido y desde donde actualizamos
// la configuración de la aplicación
import 'config_regional/model/locale_constant.dart' as const_reg;
// Construye el DropdownButton para selecionar idioma
import 'config_regional/opciones_idiomas/ops_lenguaje.dart' as op_leng;

// Fin imports multi-idioma ----------------

/// Cargamos preferencias y nos devuelve un Future con la sesion si ha sido guardada
void main() {
  String? sesion;
  cargaPreferencia().then((value) {
    globales.debug('inicio: ' + (value ?? 'nada'));
    sesion = value;
  }).whenComplete(() {
    globales.debug("sesion: " + (sesion == null).toString());
    runApp(MyApp(token: sesion == null || sesion!.isEmpty ? null : sesion));
  });
}

// Necesitamos que el Widget sea stateful para mantener los cambios de idiomas
// si se produce un cambio en la elección de idioma
class MyApp extends StatefulWidget {
  MyApp({Key? key, this.token}) : super(key: key);

  // Método estático disponible para todos las clsses y así realizar el cambió de idioma
  // desde donde queramos
  static void setLocale(BuildContext context, Locale? newLocale) async {
    // buscamos el objeto state para establece la nueva configuración regional
    context.findAncestorStateOfType<_MyAppState>()?.setLocale(newLocale);
  }

  final String? token;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale = null;

  void setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
  }

  // Este método es obligatorio para que se reflejen los cambios en el
  // las dependencias padres
  @override
  void didChangeDependencies() async {
    // Miramos en SharedPreferences
    const_reg.getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  // Widget raíz de la aplicación
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Establecemos la configuración regional del widget raíz
      //que afecta todos los descendientes
      locale: _locale,

      // indicamos las diferentes localizaciónes disponibles
      // se encuentran en: 'package:flutter_gen/gen_l10n/app_localizations.dart'
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // hasta aquí 'package:flutter_gen/gen_l10n/app_localizations.dart'

      // Si queremos que el título de la aplicación realice el cambio
      // de idioma, la aplicación del nombre la debemos realizar
      // en este momento ya que si lo hacemos a traves de
      // title:traducciones.appName,
      // genera un error porque el objeto AppLocalizations devuelto es nulo
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.nombreApp,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home:
          widget.token == null ? Login() : EscogeOpciones(token: widget.token!),
      //home: getPreferencia(MyApp.claveGuardaSesion).whenComplete(() => Login()),

      //home: EscogeOpciones(token: 'a'),

/*
      home: NuevaEmpresa(token: 'k'),
*/
      /*
      home: const NuevoUsuario(token: "k"),
      /*
      */
      home: const FiltrosUsuario(
          token:
              "k",
          empCod: '60 - funcioncrearempresa1',
          emp_cod: 60,
          nombre: "oooo",
          pwd: "wwwwwwwwwww",
          auto_pwd: true),
      */
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late AppLocalizations traducciones;

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
    traducciones = AppLocalizations.of(context)!;
    // TODO poner información en blanco
    // informacion predeterminada que luego se borrara mas adelante
    _usuario.text = "Joselito";
    _pwd.text = "1234";

    return Scaffold(
      appBar: AppBar(
          // Barra aplicación tiutlo
          title: Text(AppLocalizations.of(context)!.identifica),

          // Añadimos el DropButton de elección de idioma
          actions: [
            op_leng.LanguageDropDown().getDropDown(context),
          ]),
      body: SingleChildScrollView(
        //Previene BOTTOM OVERFLOWED
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  hintText: traducciones.hintTuNombre,
                  labelText: AppLocalizations.of(context)!.usuario),
              controller: _usuario,
              onFieldSubmitted: (String value) {
                // Al pulsar enter ponemos el foco en el campo contraseña
                FocusScope.of(context).requestFocus(_contrasenaFocus);
              },
            ),
            SizedBox(height: 30),

            TextFormField(
              decoration: InputDecoration(
                  hintText: traducciones.hintContrasena,
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
            SizedBox(height: 30),
            // Botón para realizar el login
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.acceso),
              onPressed: () {
                _login();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (esperandoLogin) {
      EnCualquierLugar()
          .muestraSnack(context, traducciones.esperandoAlServidor);
    } else {
      //  TO-DO objeto que mire el tiempo de carga del sistema
      //  Interrumpe toast si el tiempo de espera es mayor a 0.5s el programa mostrara por pantalla cargando
      //  globales.muestraToast(context, "Cargando...");

      // Obtenemos usuario y la contraseña introducidas
      String nombre = _usuario.text;
      // Contraseña
      String pwd = _pwd.text;

      if (nombre.isEmpty || pwd.isEmpty) {
        // No tiene datos Mostramos avisos
        globales.muestraDialogo(context, traducciones.primerRellenaCampos);
      } else {
        esperandoLogin = true;
        // URL del servidor
        String url = globales.servidor + '/login';

        // Encriptamos el usuario y la contraseña juntos si los dos campos estan rellenados
        // TODO AVISAR de campos vacios

        Servidor.login(nombre, pwd, context).then((response) {
          if (response!.statusCode == Servidor.CodigoResp.ok) {
            final parsed =
                jsonDecode(response.body).cast<Map<String, dynamic>>();
            vaciaNavegacionYCarga(context,
                builder: (context) =>
                    EscogeOpciones(token: parsed[0]['token']));
          }
        }).whenComplete(() => esperandoLogin = false);
      }
    }
  }
}
