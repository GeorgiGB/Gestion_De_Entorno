import 'package:crea_empresa_usario/ejemplo_pantalla.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/navegacion/rutas_pantallas.dart';
import 'package:crea_empresa_usario/pantallas/login.dart';
import 'package:crea_empresa_usario/pantallas/nueva_empr.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/preferencias/preferencias.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:crea_empresa_usario/pantallas/config_aplicacion.dart';
import 'package:flutter/material.dart';
import 'globales.dart' as globales;

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Constantes donde se guarda el idoma escogido y desde donde actualizamos
// la configuración de la aplicación
import 'config_regional/model/locale_constant.dart' as const_reg;
// Fin imports multi-idioma ----------------

void main() {
  // Preparamos  la estructur

  // el orden de inicialización se corresponde con el orden
  // de aparición en le menú lateral

  PantallaNuevaEmpresa.preparaNavegacion('NuevaEmpresa');
  PantallaLogin.preparaNavegacion('Login',
      conToken: false, menuLateral: false, conItemMenu: false);
  PantallaNuevoUsuario.preparaNavegacion('NuevoUsuario');
  PantallaConfigAplicacion.preparaNavegacion('ConfigOpciones');

  runApp(MyApp());
}

// Necesitamos que el Widget sea stateful para mantener los cambios de idiomas
// si se produce un cambio en la elección de idioma
class MyApp extends StatefulWidget {
  /// A qué página voy después de identificarme
  static late final String despuesDeLoginVesA = PantallaNuevaEmpresa.ruta.hacia;
  static const bool menuAbierto = true;
  String? _token;

  /// Constructor
  MyApp({Key? key, String? token}) : super(key: key) {
    _token = token;
  }

  /// Método estático disponible para todos las classes y así realizar
  /// el cambio de idioma desde donde queramos
  static void setLocale(BuildContext context, Locale? newLocale) async {
    // buscamos el objeto state para establece la nueva configuración regional
    context.findAncestorStateOfType<_MyAppState>()?.setLocale(newLocale);
  }

  /// Metodo estático que necesita de un [BuildContext] válido para establecer
  /// el token
  static setToken(BuildContext context, String token) {
    // globales.debug("token es nulo " + (token == null).toString());
    MyApp mapp = context.findAncestorWidgetOfExactType<MyApp>() as MyApp;
    mapp._token = token;
  }

  /// Guardamos los datos de la sesión para la próxima vez que se abra la aplicación
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

  /// boolean para evitar que cuando estamos cerrando sesión se ignore una nueva llamada
  static bool _cerrandoSesion = false;

  /// Cerramos sesion
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
        PantallaLogin.voy(context);
      });
    }
  }

  /// Si la ruta solicitada necesita token y no exite el token
  /// Enviamos la pantalla de [Login]
  static void rutaSinToken(BuildContext context) {
    MyApp mapp = context.findAncestorWidgetOfExactType<MyApp>() as MyApp;
    if (mapp._token != null) {
      vesA(ModalRoute.of(context)!.settings.name!, context,
          arguments: ArgumentsToken(mapp._token!));
    } else {
      PantallaLogin.voy(context);
    }
  }

  @override
  _MyAppState createState() => _MyAppState();
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
          initialRoute:
              PantallaLogin.ruta.hacia, //Ruta.getRuta(PantallaLogin.id),
          routes: {
            PantallaConfigAplicacion.ruta.hacia: (context) =>
                PantallaConfigAplicacion(context),
            PantallaLogin.ruta.hacia: (context) => PantallaLogin(context),
            PantallaNuevaEmpresa.ruta.hacia: (context) =>
                PantallaNuevaEmpresa(context),
            PantallaNuevoUsuario.ruta.hacia: (context) =>
                PantallaNuevoUsuario(context),
          },
        );
      },

      /**/
    );
  }
}
