import 'package:crea_empresa_usario/pantallas/escoge_opciones.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/pantallas/filtros_usuario.dart';
import 'package:crea_empresa_usario/pantallas/nueva_empr.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/preferencias/preferencias.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import 'globales.dart' as globales;

import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Constantes donde se guarda el idoma escogido y desde donde actualizamos
// la configuración de la aplicación
import 'config_regional/model/locale_constant.dart' as const_reg;
import 'pantallas/login.dart';

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
  late AppLocalizations _traducc;

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
      onGenerateTitle: (BuildContext context) {
        _traducc = AppLocalizations.of(context)!;
        return _traducc.nombreApp;
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialRoute: '/',
      routes: {
        // La ruta raíz (/) es la primera pantalla
        '/': (context) => Sesion(traducciones: _traducc), //Login(_traducc),
        '/EscogeOpciones': (context) => EscogeOpciones(token: widget.token!),
        '/NuevaEmpresa': (context) => NuevaEmpresa(token: widget.token!),
        '/NuevoUsuario': (context) => NuevoUsuario(token: widget.token!),
        // A esta ruta no se puede acceder por aquí se tiene que acceder a traves de Nuevo usuario
        //'/NuevoUsuario/FiltrosUsuario': (context) => FiltrosUsuario(token: token, empCod: empCod, emp_cod: emp_cod, nombre: nombre, pwd: pwd, auto_pwd: auto_pwd);,
        '/Sesion': (context) => Sesion(traducciones: _traducc), //
      },

      //home:
      //    widget.token == null ? Login() : EscogeOpciones(token: widget.token!),

      //home: Sesion(traducciones: AppLocalizations.of(context)!),
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
