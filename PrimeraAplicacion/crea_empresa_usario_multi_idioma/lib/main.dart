import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/pantallas/login.dart';
import 'package:crea_empresa_usario/preferencias/preferencias.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import 'globales.dart' as globales;

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Constantes donde se guarda el idoma escogido y desde donde actualizamos
// la configuración de la aplicación
import 'config_regional/model/locale_constant.dart' as const_reg;
// Fin imports multi-idioma ----------------

/// Cargamos preferencias y nos devuelve un Future con la sesion si ha sido guardada
void main() {
  runApp(MyApp());
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

  static setToken(BuildContext context, String token) {
    // globales.debug("token es nulo " + (token == null).toString());
    MyApp mapp = context.findAncestorWidgetOfExactType<MyApp>() as MyApp;
    mapp._token = token;
  }

  //static

  static mantenLaSesion(bool si, String? token) {
    if (si) {
      if (token != null) setPreferencias(claveSesion, token);
      setPreferencias(mantenSesion, guardar);
    } else {
      // borro la clave de sesión
      removePreferencias(claveSesion);

      // y desactivamos el checkbox de mantener sesión
      removePreferencias(mantenSesion);
    }
  }

  static bool _cerrandoSesion = false;
  static void cierraSesion(BuildContext context) {
    final AppLocalizations traduce = AppLocalizations.of(context)!;
    MyApp mapp = context.findAncestorWidgetOfExactType<MyApp>() as MyApp;

    //guardaSesion(null);
    if (_cerrandoSesion) {
      EnCualquierLugar()
          .muestraSnack(context, traduce.esperandoRespuestaServidor);
    } else {
      _cerrandoSesion = true;
      Servidor.cerrarSesion(context, token: mapp._token!).whenComplete(() {
        _cerrandoSesion = false;
        mapp._token = null;

        aLogin(context);
      });
    }
  }

  @override
  _MyAppState createState() => _MyAppState();

  static void rutaSinToken(BuildContext context) {
    MyApp mapp = context.findAncestorWidgetOfExactType<MyApp>() as MyApp;
    if (mapp._token != null) {
      vesA(ModalRoute.of(context)!.settings.name!, context,
          arguments: ArgumentsToken(mapp._token!));
    } else {
      aLogin(context);
    }
  }
}

class _MyAppState extends State<MyApp> {
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

  String rutaInicial = Rutas.rutas['IniciaLogin']!;

  // Widget raíz de la aplicación
  @override
  Widget build(BuildContext context) {
    //widget._token;
    return FutureBuilder(
      // Cargamos las preferencias de sesión
      future: cargaPreferencia().then((value) {
        //PantallasMenu.abierto = false;

        // si el token no se guarda el valor es nulo
        // pero si existe el token lo debemos pasar
        widget._token = value != null ? value : widget._token;
      }),

      builder: (context, datos) {
        //sesion = datos.hasData? datos.data as String:null;
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
          initialRoute: Rutas.rutas['IniciaLogin']!,
          routes: {
            Rutas.rutas['IniciaLogin']!: (context) => Identificate(_traduce),
            Rutas.rutas['EmpresaNueva']!: (context) =>
                EmpresaNueva(context, _traduce),
            Rutas.rutas['UsuarioNuevo']!: (context) =>
                UsuarioNuevo(context, _traduce),
            Rutas.rutas['Configuracion']!: (context) =>
                OpcionesConfig(context, _traduce),
          },

          // La ruta inicial es Login  y la hacemos sin transición
          /*onGenerateRoute: (settings) {
              if (settings.name == rutaInicial) {
                return PageRouteBuilder(
                  pageBuilder: (_, __, ___) => Login(token: widget._token),
                );
              }

              return null;
            }*/
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
      },

      /**/
    );
  }
}
