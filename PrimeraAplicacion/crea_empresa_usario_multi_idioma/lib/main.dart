import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/navegacion/pantalla.dart';
import 'package:crea_empresa_usario/pantallas/login.dart';
import 'package:crea_empresa_usario/pantallas/nueva_empr.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/preferencias/preferencias.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:crea_empresa_usario/pantallas/config_aplicacion.dart';
import 'package:flutter/material.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Constantes donde se guarda el idoma escogido y desde donde actualizamos
// la configuración de la aplicación
import 'config_regional/model/locale_constant.dart' as const_reg;
// Fin imports multi-idioma ----------------

void main() {
  String? sesion = null;

  cargaPreferencia().then((value) {
    sesion = value;
  }).whenComplete(() {
    // Preparamos  la estructura de navegación
    _inicializaNavegacion();

    // Cargamos la aplicación
    runApp(MyApp(token: sesion));
  });
}

/// Aquí és donde debemos añadir el código de inicialización de la ruta de la
/// pantalla que queramos añadir a la estructura de la aplicación
///
/// El orden de inicialización se corresponde con el orden
/// de aparición en le menú lateral
///
/// Mas información en el archivo ***[ComoCrearRutas.md]***
void _inicializaNavegacion() {
  // Inicializamos Login
  MyApp._addruta(Navega(
    Login.id,
    titulo: (AppLocalizations traduce) {
      return traduce.iniciaSesion;
    },
    constructor: (String? token) => Login(),
    conToken: false,
    menuLateral: false,
  ));

  // Inicializamos NuevaEmpresa
  MyApp._addruta(Navega(NuevaEmpresa.id,
      titulo: (AppLocalizations traduce) {
        return traduce.nuevaEmpresa;
      },
      constructor: (token) => NuevaEmpresa(token: token!),
      itemMenu: IconTraduce.iconData(
        Icons.add_business_rounded,
        traduce: (traduce) {
          return traduce.anyadeEmpresa;
        },
      )));

  // Inicializamos NuevoUsuario
  MyApp._addruta(Navega(NuevoUsuario.id,
      titulo: (AppLocalizations traduce) {
        return traduce.nuevoUsuario;
      },
      constructor: (token) => NuevoUsuario(token: token!),
      itemMenu: IconTraduce.iconData(
        Icons.add_business_rounded,
        traduce: (traduce) {
          return traduce.anyadeUsuario;
        },
      )));

  // Inicializamos pantalla de configuración
  MyApp._addruta(Navega(ConfigAplicacion.id,
      titulo: (AppLocalizations traduce) {
        return traduce.configuracion;
      },
      constructor: (token) => ConfigAplicacion(token: token!),
      itemMenu: IconTraduce.iconData(
        Icons.add_business_rounded,
        traduce: (traduce) {
          return traduce.configuracion;
        },
      )));
}

// Necesitamos que el Widget sea stateful para mantener los cambios de idiomas
// si se produce un cambio en la elección de idioma
class MyApp extends StatefulWidget {
  /// Al cargar por primera vez la siguiente pantalla a la [pantallaControl] o si
  /// guardamos la sesión e iniciamos la aplicación el [MenuLateral] se mostrará abierto
  static const bool menuAbierto = true;

  /// Pantalla que se cargará cuando se inicia la aplicación y no se ha guardado
  /// la sesión o cuando se cierra la sesión
  static Navega get pantallaControl => Navega.navegante(Login.id);

  /// A qué página voy después de identificarme
  static late final String despuesDeLoginVesA =
      Navega.navegante(NuevaEmpresa.id).ruta.hacia;

  /// variable Privada donde guardamos el token de sesión
  String? _token;

  /// boolean para evitar múltiples llamas al método [MyApp.cierraSesion] en el momento que esperamos
  /// la contestación del servidor una vez llamado a este mismo método
  static bool _cerrandoSesion = false;

  /// Mapa de rutas utilizado por el parámetro [MaterialApp.routes]
  static final Map<String, WidgetBuilder> _rutasPantalla = {};

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
        MyApp.pantallaControl.voy(context);
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
      Navega.navegante(Login.id).voy(context);
    }
  }

  /// Este método añade la clave ruta y el WidgetBuilder
  /// al Mapa de [MaterialApp.routes]
  static void _addruta(Navega navegante) {
    String id = navegante.id;
    // la ruta
    _rutasPantalla[Navega.navegante(id).ruta.hacia] =
        // el WidgetBuilder
        (context) => Navega.navegante(id).muestraPantalla(context);
  }

  /// Constructor
  MyApp({Key? key, String? token}) : super(key: key) {
    _token = token;
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
      initialRoute: Navega.navegante(Login.id)
          .ruta
          .hacia, //Ruta.getRuta(PantallaLogin.id),
      routes: (() {
        // creamos un mapa de rutas de forma
        // que podamos añadir otro tipo de rutas
        Map<String, WidgetBuilder> r = {
          // Aquí podemos añadir otras rutas
          // String: (context) => WidgetBuilder(context),
        };

        // Añadimos las rutas con pantalla
        r.addAll(MyApp._rutasPantalla);

        // Devolvemos el mapa de rutas
        return r;
      })(),
    );
    //},
    //);
  }
}
