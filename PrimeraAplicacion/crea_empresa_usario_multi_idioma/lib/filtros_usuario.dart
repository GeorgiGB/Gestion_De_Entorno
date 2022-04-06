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
      required this.token,
      required this.usa_nombre,
      required this.usa_pwd,
      required this.ute_pwd_auto})
      : super(key: key);
  final String token;
  final String usa_nombre;
  final String usa_pwd;
  final bool ute_pwd_auto;
  @override
  State<filtros_usuario> createState() => _filtros_usuarioState();
}

class _filtros_usuarioState extends State<filtros_usuario> {
  final TextEditingController _codigo_filtro = TextEditingController();
  bool esperandoFiltrado = false;
  late AppLocalizations traducciones;

  late String ute_filtro;
  // Lista de filtros
  // En el se encontraran los diferentes filtros que se pueden asociar al usuario.
  final List<String> _filtros = [];
  @override
  Widget build(BuildContext context) {
    traducciones = AppLocalizations.of(context)!;

    ute_filtro = traducciones.filtros;
    
    // limpiamos la lista fitlros
    _filtros.clear();

    _filtros.add(traducciones.filtros);
    _filtros.add(traducciones.centroPadre);
    _filtros.add(traducciones.centro);
    _filtros.add(traducciones.pdv);
    _filtros.add(traducciones.jefeDeArea);
    _filtros.add(traducciones.ruta);

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
          DropdownButton<String>(
            isExpanded: true,
            value: ute_filtro,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? filtro) {
              setState(() {
                globales.debug(filtro!);
                ute_filtro = filtro;
              });
            },
            items: _filtros.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
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
      // Añadir el nombre del usuario y su contraseña
      String ute_nombre = widget.usa_nombre;
      String ute_pwd = widget.usa_pwd;
      String ute_cod_filtro = _codigo_filtro.text;

      try {
        globales.debug(ute_nombre);
        globales.debug(ute_pwd);
        globales.debug(ute_filtro);

        var response = await http.post(
          Uri.parse(url),
          // Cabecera para enviar JSON con una autorizacion token
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': widget.token
          },
          // Adjuntamos al body los datos en formato JSON
          body: jsonEncode(<String, String>{
            'usa_nombre': widget.usa_nombre.toString(),
            'usa_pwd': widget.usa_pwd.toString(),
            'usa_pwd_auto': widget.ute_pwd_auto.toString(),
            'ute_filtro': ute_filtro,
            'ute_cod_filtro': ute_cod_filtro
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
}
