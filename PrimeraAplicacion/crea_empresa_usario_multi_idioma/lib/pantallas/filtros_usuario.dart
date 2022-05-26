import 'package:crea_empresa_usario/colores.dart';
import 'package:crea_empresa_usario/navegacion/navega.dart';
import 'package:crea_empresa_usario/navegacion/pantalla.dart' as Navegacion;
import 'package:crea_empresa_usario/pantallas/listado_empresas/empresa_future.dart';
import 'package:crea_empresa_usario/pantallas/nuevo_usua.dart';
import 'package:crea_empresa_usario/servidor/servidor.dart';
import 'package:crea_empresa_usario/widgets/snack_en_cualquier_sitio.dart';
import 'package:flutter/material.dart';
import '../globales.dart' as globales;
import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

class FiltrosUsuario extends StatefulWidget {
  const FiltrosUsuario(
      {Key? key,
      required this.token,
      required this.empCod,
      required this.nombre,
      required this.pwd,
      required this.auto_pwd})
      : super(key: key);
  final String token;
  final EmpresCod empCod;
  final String nombre;
  final String pwd;
  final bool auto_pwd;
  @override
  State<FiltrosUsuario> createState() => _FiltrosUsuarioState();
}

class _FiltrosUsuarioState extends State<FiltrosUsuario> {
  Locale? anteriorLocale;
  final TextEditingController _codigo_filtro = TextEditingController();
  bool esperandoFiltrado = false;
  late AppLocalizations traducciones;

  Filtro? filtroActivo;
  // Lista de filtros
  // En el se encontraran los diferentes filtros que se pueden asociar al usuario.
  late List<Filtro> _users;

  @override
  void initState() {
    super.initState();
    _users = _creaFiltro();
  }

  @override
  Widget build(BuildContext context) {
    traducciones = AppLocalizations.of(context)!;
    Filtro.traducciones = traducciones;

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(traducciones.seleccionaFiltroUsuario),
      ),
      body: SingleChildScrollView(
          //Previene BOTTOM OVERFLOWED
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  campoValor(
                      traducciones.empresa + ": ", widget.empCod.toString())
                ],
              ),
              SizedBox(height: 10),
              Row(children: [
                campoValor(traducciones.nombre + ": ", widget.nombre)
              ]),
              SizedBox(height: 10),
              Row(children: [
                campoValor(traducciones.contrasena + ": ",
                    (widget.auto_pwd ? traducciones.autoGenerada : '*********'))
              ]),
              SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    traducciones.seleccionaFiltro,
                    style: globales.estiloNegrita_16,
                  ),
                ],
              ),
              // Seleccionar tipo de filtro
              DropdownButton<Filtro>(
                isExpanded: true,
                value: filtroActivo ?? _users.first,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (Filtro? filtro) {
                  setState(() {
                    filtroActivo = filtro;
                  });
                },
                items: _users.map<DropdownMenuItem<Filtro>>((Filtro value) {
                  return DropdownMenuItem<Filtro>(
                    value: value,
                    child: Text(value.traducc),
                  );
                }).toList(),
              ),
              // Código de filtro
              SizedBox(height: 30),
              TextFormField(
                decoration: InputDecoration(
                    labelText: traducciones.dimeElCodigoDeFiltro,
                    hintText: traducciones.numeroDeCodigo),
                controller: _codigo_filtro,
                // LLamamos a la datosCompletosr
                onFieldSubmitted: (String value) {
                  _enviar_filtro();
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                child: Text(traducciones.crear),
                onPressed: () {
                  _enviar_filtro();
                },
                style: ElevatedButton.styleFrom(
                      primary: PaletaColores.colorMorado),
                ),
            ],
          )),
    );
  }

  // Future encargado de enviar los datos del nuevo usuario al servidor
  // lo único que controla es si los campos están vacios
  _enviar_filtro() {
    String url = '/crear_usuarios_telemetria';
    //Si estamos esperando el filtro y se vuelve a pulsar login este lo ignorara.
    if (esperandoFiltrado) {
      EnCualquierLugar()
          .muestraSnack(context, traducciones.esperandoAlServidor);
    } else {
      // Datos del filtro
      String? filtrBBDD = filtroActivo == null ? '' : filtroActivo!.filtro_bbdd;
      String codFiltro = _codigo_filtro.text;

      // comprobamos que tengan datos
      if (filtrBBDD.isEmpty || codFiltro.isEmpty) {
        // No tiene datos Mostramos avisos
        globales.muestraDialogo(context, traducciones.primerRellenaCampos);
      } else {
        esperandoFiltrado = true;
        String json = jsonEncode(<String, String>{
          'ctoken': widget.token,
          'emp_cod': widget.empCod.empCod.toString(),
          'nombre': widget.nombre,
          'pwd': widget.pwd,
          'auto_pwd': widget.auto_pwd.toString(),
          'filtro': filtroActivo!.filtro_bbdd,
          'cod_filtro': _codigo_filtro.text
        });

        // Enviamos al servidor
        Servidor.anyade(context, url, widget.token,
            json: json,
            gestionoErrores: [
              BBDD.uniqueViolation,
              BBDD.invalidTextRepresentation
            ]).then((codigo) {
          switch (codigo) {
            case '0':
              EnCualquierLugar().muestraSnack(
                context,
                traducciones.elUsuarioHaSidoDadoDeAlta(widget.nombre),
                duration: Duration(milliseconds: 1250),
                onHide: () {
                  // Cargamos pantalla de escoger opciones
                  Navega.navegante(NuevoUsuario.id).voy(context);
                  //PantallaNuevoUsuario.voy(context);
                },
              );
              break;
            case BBDD.uniqueViolation:
              globales.muestraDialogo(context,
                  traducciones.elUsuarioYaEstaRegistrado(widget.nombre));
              break;
            case BBDD.invalidTextRepresentation:
              globales.muestraDialogo(
                  context, traducciones.numeroNoValido(_codigo_filtro.text));
              break;
          }
        }).whenComplete(() => esperandoFiltrado = false);
      }
    }
  }

  // Passamos un nobre de campo y su valor y devuelve un widget
  // con el nombre del campo en negrita y su valor normal
  RichText campoValor(String campo, String valor) {
    return RichText(
      text: TextSpan(
        //style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(text: campo, style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: valor),
        ],
      ),
    );
  }

  // A partir de aquí controlamos los filtros
  List<Filtro> _creaFiltro() {
    List<Filtro> filtros = [];

    // inicializamos el valor del filtro con el índice de posición
    // el nombre de la traducción y el nombre del filtro que le pasamos a la BBDD
    // Al inicio la lista filtros tiene 0 elementos por tanto e índice de posición es 0
    // al ir insertando elementos el índice de posición aumenta de 1 en 1
    // de esta forma podemos mover un filtro a la posición que queramos
    // que tendrá correcto su índice de posición
    filtros.add(Filtro(filtros.length, TiposFiltros.filtros, ""));
    filtros.add(
        Filtro(filtros.length, TiposFiltros.centroPadre, "ute_centro_padre"));
    filtros.add(Filtro(filtros.length, TiposFiltros.centro, "ute_centro"));
    filtros.add(Filtro(filtros.length, TiposFiltros.pdv, "ute_pdv"));
    filtros
        .add(Filtro(filtros.length, TiposFiltros.jefeDeArea, "ute_jefe_area"));
    filtros.add(Filtro(filtros.length, TiposFiltros.ruta, "ute_ruta"));

    return filtros;
  }
}

// enum filtros utilizado para obtener la traducción
enum TiposFiltros { filtros, centro, centroPadre, pdv, jefeDeArea, ruta }

class Filtro {
  static late AppLocalizations traducciones;

  static String _getTrd(TiposFiltros tf) {
    String trd = "";
    switch (tf) {
      case TiposFiltros.filtros:
        trd = traducciones.filtros;
        break;
      case TiposFiltros.centro:
        trd = traducciones.centro;
        break;
      case TiposFiltros.centroPadre:
        trd = traducciones.centroPadre;
        break;
      case TiposFiltros.pdv:
        trd = traducciones.pdv;
        break;
      case TiposFiltros.jefeDeArea:
        trd = traducciones.jefeDeArea;
        break;
      case TiposFiltros.ruta:
        trd = traducciones.ruta;
        break;
      default:
    }
    return trd;
  }

  Filtro(this.id, this._traducc, this.filtro_bbdd);

  final String filtro_bbdd;
  final int id;
  final TiposFiltros _traducc;
  String get traducc => _getTrd(_traducc);
}
