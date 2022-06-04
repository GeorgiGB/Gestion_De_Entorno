import 'package:crea_empresa_usuario_multi_idioma/globales/colores.dart';
import 'package:crea_empresa_usuario_multi_idioma/navegacion/navega.dart';
import 'package:crea_empresa_usuario_multi_idioma/navegacion/pantalla.dart';
import 'package:flutter/material.dart';
import '../globales/globales.dart' as globales;
import 'filtros_usuario.dart';

import 'listado_empresas/empresa_future.dart';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

class NuevoUsuario extends StatefulWidget {
  static const String id = 'NuevoUsuario';

  NuevoUsuario({Key? key, required token}) : super(key: key) {
    _token = token;
  }
  late String _token;

  @override
  State<NuevoUsuario> createState() => NuevoUsuarioState();
}

class NuevoUsuarioState extends State<NuevoUsuario> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final FocusNode _auto_contrasenaFocus = FocusNode();

  late AppLocalizations traducciones;

  bool _pwd_auto = true;
  bool esperandoNuevoUsuario = false;
  bool enviar = false;
  //  para mostrar/ocultar la contraseña
  bool _contraVisible = false;

  // Este es un widget que controla la visibilidad el cual tiene asociodos
  // los widgets de formulario para dar de alta a un usuario nuevo
  late Visibility _mostrar;
  Visibility get muestraFormulario => _mostrar;

  // variable que hará que se muestren o no los campos de formulario
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _contraVisible = false;
    _pwd_auto = true;
  }

  @override
  Widget build(BuildContext context) {
    traducciones = AppLocalizations.of(context)!;

    _mostrar = getControlesVsibles();

    return /*Scaffold(
      /*appBar: AppBar(
        title: Text(traducciones.nuevoUsuario),
      ),*/
      extendBody: true,
      body:*/
        SingleChildScrollView(
      //Previene BOTTOM OVERFLOWED
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Para poder mostrar el formulario tienen que haber empresas dadas
          // de alta y así poder seleccionar una empresa y asociarla al nuevo usuario
          dropDownEmpresas('', this, context, widget._token),
          // la función está preparada para pasar un string que buscará en el servidor
          SizedBox(height: 30),
          // Widget que contiene los controles de formulario
          muestraFormulario,
        ],
      ),
      //),
      //),
    );
  }

  // Si el checkbox esta activo y el campo contraseña tiene datos
  // Se encargara de limpiar el campo contraseña
  autoCheckBox(bool value) {
    if (value) {
      _pwd.clear();
    }
    setState(() {
      _pwd_auto = value;
    });
  }

  // Recargamos la página desde el estado de inicial
  /*recarga() {
    setState(() {
      _visible = false;
    });
  }*/

  avisoContraManual(bool hasFocus) {
    // Si la casilla de contraseña auto generada está marcada no permitirá
    // la escritura en el campo de la contraseña y mostrará un aviso.
    if (hasFocus && _pwd_auto) {
      FocusScope.of(context).requestFocus(_auto_contrasenaFocus);
      globales.muestraDialogo(context, traducciones.introContraDesmarcaCasilla);
    }
  }

  // Future
  Future<void>? _cargaFiltrosUsuario() async {
    /* 
    Tenemos dos tipos de condiciones ya que se puede acceder de dos formas
    1. Rellenando el campo de nombre y contraseña.
    2. Rellenando el campo de nombre y pulsando el boton de autogenerado.
    
    Por lo tanto tenemos que comprobar si el botón no esta marcado y
    hemos introducido una contraseña. Y al revés, si hemos introducido un nombre 
    y hemos marcado el botón de autogenerado.
    */

    // obtenemos la empresa seleccionada
    EmpresCod? empCod = empreCod;

    if (_nombre.text.isNotEmpty &&
        (_pwd.text.isNotEmpty || _pwd_auto) &&
        empCod != null) {
      ArgumentosFiltroUsuario afu = ArgumentosFiltroUsuario(
          widget._token, empCod, _nombre.text, _pwd.text, _pwd_auto);
      Navega.navegante(FiltrosUsuario.id)
          .voyPuedoVolver(context, arguments: afu);
    } else {
      // Mostramos avisos
      globales.muestraDialogo(context, traducciones.primerRellenaCampos);
    }
  }

  controlesVisibilidad(bool visible) async {
    // para que tenga efecto debemos crea un future
    // de forma que el hilo principal haga su camino
    await Future.delayed(Duration(milliseconds: 1));
    if (!_visible) {
      setState(() {
        _visible = visible;
      });
    }
  }

  Visibility getControlesVsibles() {
    return Visibility(
      visible: _visible,
      replacement: const SizedBox(height: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Campo formulario Nombre de usuario
          TextFormField(
            decoration: InputDecoration(
                labelText: traducciones.nombreDelUsuario,
                hintText: traducciones.introduceElNombre),
            controller: _nombre,
            onFieldSubmitted: (String value) {
              // Al pulsar intro pon el foco en el checkbox de contraseña auto generada
              FocusScope.of(context).requestFocus(_auto_contrasenaFocus);
            },
          ),
          SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(traducciones.contrasenaAutogenerada),
              // checkbox de contraseña auto generada
              Checkbox(
                // Mientras este activo
                // No permitirá al usuario escribir una contraseña
                value: _pwd_auto,
                focusNode: _auto_contrasenaFocus,
                onChanged: (bool? value) {
                  autoCheckBox(value!);
                },
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Focus(
                  onFocusChange: (hasFocus) {
                    avisoContraManual(hasFocus);
                  },
                  // Campo contraseña
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: traducciones.contrasena,
                      hintText: traducciones.introduceLaContrasena,
                      // Icono  para mostrar/ocultar la contraseña
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _contraVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _contraVisible = !_contraVisible;
                          });
                        },
                      ),
                    ),
                    controller: _pwd,
                    // para mostrar/ocultar la contraseña
                    obscureText: !_contraVisible,
                    enableSuggestions: false,
                    autocorrect: false,

                    // LLamamos a la función de para cargar los filtros de usuario
                    // que nos permitira avanzar a la siguiente página
                    onFieldSubmitted: (String value) {
                      _cargaFiltrosUsuario();
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          ElevatedButton(
            child: Text(traducciones.siguiente),
            onPressed: () {
              // LLamamos a la función de para cargar los filtros de usuario
              // que nos permitira avanzar a la siguiente página
              _cargaFiltrosUsuario();
            },
            style: ElevatedButton.styleFrom(primary: PaletaColores.colorMorado),
          ),
        ],
      ),
    );
  }
}
