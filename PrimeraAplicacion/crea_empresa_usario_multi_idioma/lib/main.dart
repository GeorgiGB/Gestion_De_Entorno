import 'package:crea_empresa_usario/nueva_empr.dart';
import 'package:crea_empresa_usario/nuevo_usua.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:flutter/material.dart';
import 'filtros_usuario.dart';
import 'globales.dart' as globales;
import 'escoge_opciones.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Constantes donde se guarda el idoma escogido y desde donde actualizamos
// la configuración de la aplicación
import 'config_regional/model/locale_constant.dart' as const_reg;
// Construye el DropdownButton para selecionar idioma
import 'config_regional/opciones_idiomas/ops_lenguaje.dart' as op_leng;

// Fin imports multi-idioma ----------------

void main() {
  runApp(MyApp());
}

// Necesitamos que el Widget sea stateful para mantener los cambios de idiomas
// si se produce un cambio en la elección de idioma
class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  // Método estático disponible para todos las clsses y así realizar el cambió de idioma
  // desde donde queramos
  static void setLocale(BuildContext context, Locale? newLocale) async {
    // buscamos el objeto state para establece la nueva configuración regional
    context.findAncestorStateOfType<_MyAppState>()?.setLocale(newLocale);
  }

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
      // title: AppLocalizations.of(context)!.appName,
      // genera un error porque el objeto AppLocalizations devuelto es nulo
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.nombreApp,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      //home: Login(),

      home: EscogeOpciones(token: 'a'),

/*
      home: NuevaEmpresa(
          token:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Ijc4ODcxODZiMzM3NDk5NzFkZTUxNTg1OTUzMmRlZjE1ZjRiMjEwZWIiLCJpYXQiOjE2NTEwNzA5MzJ9.mVW-YnXFcnUFxoL1xY3AZgkuZDikktyfKqPHpTTqVCo'),
*/
      /*  
        home: const NuevoUsuario(
            ust_token:
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Ijc4ODcxODZiMzM3NDk5NzFkZTUxNTg1OTUzMmRlZjE1ZjRiMjEwZWIiLCJpYXQiOjE2NDkzNDUyMzV9.olI-c3Zzl-QsCIgSDmhJ5QY71O7eL2d1mhDOrQSkP2k"),
  */
      /*
      home: const filtros_usuario(
          ust_token:
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Ijc4ODcxODZiMzM3NDk5NzFkZTUxNTg1OTUzMmRlZjE1ZjRiMjEwZWIiLCJpYXQiOjE2NDkzNDUyMzV9.olI-c3Zzl-QsCIgSDmhJ5QY71O7eL2d1mhDOrQSkP2k",
          empCod: '60 - funcioncrearempresa1',
          ute_emp_cod: 60,
          ute_nombre: "oooo",
          ute_pwd: "wwwwwwwwwww",
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
      body: Center(
        // Centramos contenido
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context)!.usuario),
            TextFormField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.hintTuNombre,
              ),
              controller: _usuario,
              onFieldSubmitted: (String value) {
                // Al pulsar enter ponemos el foco en el campo contraseña
                FocusScope.of(context).requestFocus(_contrasenaFocus);
              },
            ),
            Text(AppLocalizations.of(context)!.contrasena),

            TextFormField(
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.hintContrasena),
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
      globales.muestraToast(
          context, AppLocalizations.of(context)!.esperandoAlServidor);
    } else {
      //  TO-DO objeto que mire el tiempo de carga del sistema
      //  Interrumpe toast si el tiempo de espera es mayor a 0.5s el programa mostrara por pantalla cargando
      //  globales.muestraToast(context, "Cargando...");
      esperandoLogin = true;
      // URL del servidor
      String url = globales.servidor + '/login';

      // Obtenemos usuario y la contraseña introducidas
      String nombre = _usuario.text;
      // Contraseña
      String pwd = _pwd.text;

      // Encriptamos el usuario y la contraseña juntos si los dos campos estan rellenados
      String contra_encrypted = '';
      if (pwd.isNotEmpty && nombre.isNotEmpty) {
        contra_encrypted = sha1.convert(utf8.encode(pwd + nombre)).toString();
      }
      globales.debug(contra_encrypted);
      try {
        // Lanzamos la petición Post al servidor con la URL
        // El resultado será un Future y esperamos la respuesta
        var response = await http.post(
          Uri.parse(url),
          // Cabecera para enviar JSON
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          // Adjuntamos al body los datos en formato JSON
          body: jsonEncode(<String, String>{
            'nombre': nombre,
            'pwd': contra_encrypted
          }),
        );

        globales.debug(response.statusCode);
        globales.debug(response.body);

        int status = response.statusCode;
        //Si todo ha salido correcto el programa continuara
        if (status == CodigoResp.r_200) {
          _cargaCreaEmprUsuario(response);
        } else if (status == CodigoResp.r_401) {
          // Mostramos Alerta avisando del error
          globales.muestraDialogo(
              context, AppLocalizations.of(context)!.codError401);
        } else if (status == CodigoResp.r_404) {
          // Mostramos Alerta avisando del error
          globales.muestraDialogo(
              context, AppLocalizations.of(context)!.codErrorLogin404);
        } else if (status == CodigoResp.r_500) {
          // Si no se introduce alguno de los campos saldra un aviso
          globales.muestraDialogo(
              context, AppLocalizations.of(context)!.codError500);
        } else {
          // Mostramos en  terminal que error envia
          globales.debug('Code:\n' +
              response.statusCode.toString() +
              '\n' +
              response.body.toString());
        }
      } on http.ClientException catch (e) {
        // Error no se encuentra servidor
        globales.muestraDialogo(
            context, AppLocalizations.of(context)!.servidorNoDisponible);
      } on Exception catch (e) {
        // Error no especificado
        globales.debug("Error no especificado: " + e.runtimeType.toString());
      }
      esperandoLogin = false;
    }
  }

  _cargaCreaEmprUsuario(http.Response response) {
    // La petición tiene éxito. Obtenemos los resultados
    // a partir del json Mapa de elementos contenidos en el body
    Map lista = json.decode(response.body);

    // Pasamos a la pantalla creación empresa usuario
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EscogeOpciones(
          token: lista['token'].toString(),
        ),
      ),
    );
  }
}
