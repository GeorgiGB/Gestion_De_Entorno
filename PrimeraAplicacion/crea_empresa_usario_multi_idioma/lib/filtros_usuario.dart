import 'package:flutter/material.dart';
import 'globales.dart' as globales;
import 'package:http/http.dart' as http;
import 'dart:convert';

// Imports multi-idioma ---------------------
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Fin imports multi-idioma ----------------

class filtros_usuario extends StatefulWidget {
  const filtros_usuario(
      {Key? key,
      required this.ust_token,
      required this.ute_nombre,
      required this.ute_pwd,
      required this.ute_pwd_auto})
      : super(key: key);
  final String ust_token;
  final String ute_nombre;
  final String ute_pwd;
  final bool ute_pwd_auto;
  @override
  State<filtros_usuario> createState() => _filtros_usuarioState();
}

class _filtros_usuarioState extends State<filtros_usuario> {
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
        title: Text(traducciones.filtrosDeUsuario),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            traducciones.seleccionaFiltro,
          ),
          DropdownButton<Filtro>(
            isExpanded: true,
            value: filtroActivo?? _users.first,
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
          Text(
            traducciones.dimeElCodigoDeFiltro,
          ),
          TextFormField(
            decoration: InputDecoration(hintText: traducciones.numeroDeCodigo),
            controller: _codigo_filtro,
            // LLamamos a la datosCompletosr
            onFieldSubmitted: (String value) {
              _enviar_filtro();
            },
          ),
          ElevatedButton(
            child: Text(traducciones.crear),
            onPressed: () {
              _enviar_filtro();
            },
          ),
        ],
      )),
    );
  }

  Future<void>? _enviar_filtro() async {
    String url = globales.servidor + '/crear_usuarios_telemetria';
    //Si estamos esperando el filtro y se vuelve a pulsar login este lo ignorara.
    if (esperandoFiltrado) {
      globales.muestraToast(context, traducciones.esperandoAlServidor);
    } else {
      esperandoFiltrado = true;

      try {
        var response = await http.post(
          Uri.parse(url),
          // Cabecera para enviar JSON con una autorizacion token
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': widget.ust_token
          },
          // Adjuntamos al body los datos en formato JSON
          body: jsonEncode(<String, String>{
            'usa_nombre': widget.ute_nombre.toString(),
            'usa_pwd': widget.ute_pwd.toString(),
            'usa_pwd_auto': widget.ute_pwd_auto.toString(),
            'ute_filtro': filtroActivo!.filtro_bbdd,
            'ute_cod_filtro': _codigo_filtro.text
          }),
        );
        // Hay que tener en cuenta si la contraseña es autogenerada
        // Adjuntar el token en la peticion.
        int status = response.statusCode;

        if (status == 200) {
          List<dynamic> lista = json.decode(response.body);
          var datos = lista[0];
          //Esto devolveria la correcta creacion del usuario
          globales
              .debug('Usuario_creado:' + datos["Usuario_creado"].toString());
          //Aqui se mostraran los usa_cod creados para la telemetria
          globales.debug('usa_cod: ' + datos["usa_cod"].toString());
        } else if (status == 500) {
          globales.muestraDialogo(context, response.body);
        } else {
          globales.debug(response.body);
        }

        esperandoFiltrado = false;
      } on http.ClientException catch (e) {
        globales.muestraDialogo(context, traducciones.servidorNoDisponible);
      } on Exception catch (e) {
        // Error no especificado
        globales.debug("Error no especificado: " + e.runtimeType.toString());
      }

      // Hay que tener en cuenta si la contraseña es autogenerada
      // Adjuntar el token en la peticion.
      return Future.delayed(Duration(seconds: 2), () {
        esperandoFiltrado = false;
        globales.muestraToast(context, traducciones.cargando);
      });
    }
  }

  // A partir de aquí controlamos los filtros
  List<Filtro> _creaFiltro() {
    List<Filtro> filtros = [];

    // inicializamos el valor del filtro con el índice de posición
    // elnombre de la traducción
    // y el nombre del filtro que le pasamos a la BBDD
    filtros.add(Filtro(filtros.length, TiposFiltros.filtros, ""));
    filtros
        .add(Filtro(filtros.length, TiposFiltros.centroPadre, "centro_padre"));
    filtros.add(Filtro(filtros.length, TiposFiltros.centro, "centro"));
    filtros.add(Filtro(filtros.length, TiposFiltros.pdv, "pdv"));
    filtros.add(Filtro(filtros.length, TiposFiltros.jefeDeArea, "jefe_area"));
    filtros.add(Filtro(filtros.length, TiposFiltros.ruta, "ruta"));

    return filtros;
  }
}

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
