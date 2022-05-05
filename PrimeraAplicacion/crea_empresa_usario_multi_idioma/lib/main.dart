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
  MyApp({Key? key, String? token}) : super(key: key) {
    _token = token;
  }

  // Método estático disponible para todos las classes y así realizar el cambió de idioma
  // desde donde queramos
  static void setLocale(BuildContext context, Locale? newLocale) async {
    // buscamos el objeto state para establece la nueva configuración regional
    context.findAncestorStateOfType<_MyAppState>()?.setLocale(newLocale);
  }

  String? _token;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // funcio utilizada per a recibir el token que servirá para poder trabajar con
  // el servidor
  void _setToken(String? value) => widget._token = value;

  Locale? _locale = null;
  late AppLocalizations _traduce;

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
        _traduce = AppLocalizations.of(context)!;
        return _traduce.nombreApp;
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialRoute: '/',
      routes: {
        // La ruta raíz (/) es la primera pantalla
        Rutas.Raiz: (context) =>
            Identificate(_setToken, traduce: _traduce), //Login(_traducc),
        Rutas.Opciones: (context) => Opciones(_setToken, context,
            traduce: _traduce, token: widget._token),
        Rutas.EmpresaNueva: (context) =>
            EmpresaNueva(context, traduce: _traduce, token: widget._token),
        Rutas.UsuarioNuevo: (context) =>
            UsuarioNuevo(context, traduce: _traduce, token: widget._token),

        // A esta ruta, Rutas.FiltrosUsuario no se puede acceder por aquí,
        // se tiene que acceder a través de la pantalla de Nuevo usuario
        //Rutas.FiltrosUsuario: (context) =>

        Rutas.OpcionesSesion: (context) =>
            OpcionesSesion(_setToken, context, _traduce, widget._token),
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
