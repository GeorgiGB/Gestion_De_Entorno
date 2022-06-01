import 'package:crea_empresa_usuario_multi_idioma/servidor/servidor.dart';

import '../globales.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

Future<void> obtenerCodigoPlaceHolder() async {
  String url = 'https://jsonplaceholder.typicode.com/posts';

  // Lanzamos la petición GET al servidor con la URL
  // El resultado será un Future
  var response = await http.get(Uri.parse(url));

  // En la resolución del Future tendremos el resultado de la petición

  if (response.statusCode == Servidor.ok) {
    // La petición tiene éxito. Obtenemos los resultados
    // a partir de la lista de elementos contenida en el body
    //Map codigosJson = json.decode(response.body);
    List<dynamic> lista = json.decode(response.body);
    // Recorremos lista
    int contador = 0;
    for (var item in lista) {
      int? uid = item['userId'];
      int? id = item['id'];
      String? title = item['title'];
      String? body = item['body'];
      if (id == null) {
        debug(uid!);
        debug(id!);
        debug(title!);
        debug(body!);
        debug("     ----------");
        debug("");
        contador++;
      }
    }
    debug(lista.length.toString() + " : " + contador.toString());
  }
}

Future<void> placeHolderObtenerCodigoUsers() async {
  String url = 'https://jsonplaceholder.typicode.com/users';

  // Lanzamos la petición GET al servidor con la URL
  // El resultado será un Future
  var response = await http.get(Uri.parse(url));
  debug("cabecera: ");
  debug(response.headers.toString());

  // En la resolución del Future tendremos el resultado de la petición

  if (response.statusCode == Servidor.ok) {
    // La petición tiene éxito. Obtenemos los resultados
    // a partir de la lista de elementos contenida en el body
    //Map codigosJson = json.decode(response.body);
    List<dynamic> lista = json.decode(response.body);
    List<Usuario> listaUsuarios = creaUsers(lista);
    /*for (var usuario in listaUsuarios) {
      debug(usuario);
      debug('   -------');
      debug("");
    }*/

    debug(lista.length.toString() + " : " + listaUsuarios.length.toString());

    if (listaUsuarios.isNotEmpty) {
      Usuario usuario = listaUsuarios[0];
      debug("id: " + usuario.id.toString() + ", username: " + usuario.username);
      debug("\t" + usuario.company.toString());
    }
  }
}

List<Usuario> creaUsers(List<dynamic> lista) {
  List<Usuario> listaUsuarios = <Usuario>[];
  // Recorremos lista
  int contador = 0;
  for (var item in lista) {
    // Objeto Usuario
    Usuario usuarioItem = Usuario(id: item['id'], username: item['username']);
    usuarioItem.name = item['name'];
    usuarioItem.email = item['email'];

    var addrsItem = item['address'];

    // Objeto Address
    if (addrsItem != null) {
      Address address = Address();
      usuarioItem.address = address;
      address.street = addrsItem['street'];
      address.suite = addrsItem['suite'];
      address.city = addrsItem['city'];
      address.zipcode = addrsItem['zipcode'];

      //Objeto geo
      var geoItem = addrsItem['geo'];
      //debug(geoItem['lat'].runtimeType.toString());
      if (geoItem != null) {
        address.geo = Geo(
            lat: double.parse(geoItem['lat']),
            lng: double.parse(geoItem['lng']));
      }
    }

    usuarioItem.phone = item['phone'];
    usuarioItem.website = item['website'];

    //Objeto Company
    var companyItem = item['company'];
    if (companyItem != null) {
      Company company = Company(name: companyItem['name']);
      usuarioItem.company = company;
      company.catchPhrase = companyItem['catchPhrase'];
      company.bs = companyItem['bs'];
    }

    listaUsuarios.add(usuarioItem);
  }
  debug(lista.length.toString() + " : " + contador.toString());
  return listaUsuarios;
}

class Usuario {
  Usuario({required this.id, required this.username});
  final int id;
  String? name;
  String username;
  String? email;
  Address? address;
  String? phone;
  String? website;
  Company? company;

  @override
  String toString() {
    return "Usuario{id:" +
        id.toString() +
        ", name:" +
        name! +
        ", username: " +
        username +
        ", email: " +
        email! +
        ", " +
        address.toString() +
        ", phone: " +
        phone! +
        ", website: " +
        website! +
        ", " +
        company.toString() +
        "}";
  }
}

class Address {
  Address();
  String? street;
  String? suite;
  String? city;
  String? zipcode;
  Geo? geo;

  @override
  String toString() {
    return "Address{ street: " +
        street! +
        ", suite: " +
        suite! +
        ", city: " +
        city! +
        ", zipcode: " +
        zipcode! +
        ", " +
        geo.toString() +
        "}";
  }
}

class Geo {
  Geo({required this.lat, required this.lng});
  double lat;
  double lng;

  @override
  String toString() {
    return "Geo{ lat: " + lat.toString() + ", lng: " + lng.toString() + "}";
  }
}

class Company {
  Company({required this.name});
  String name;
  String? catchPhrase;
  String? bs;

  @override
  String toString() {
    return "Company{ name: " +
        name +
        ", catchPhrase: " +
        catchPhrase! +
        ", bs: " +
        bs! +
        "}";
  }
}
