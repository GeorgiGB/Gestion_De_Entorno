import 'package:flutter/material.dart';

// https://material.io/components/navigation-drawer/flutter#using-a-navigation-drawer

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Nuestro Navigation Drawer consistirá en una lista
    // de diferentes elementos, entre los que encontramos
    // la cabecera (DrawerHeader) y diferentes elementos
    // de lista (ListTile.)
    return Drawer(
      backgroundColor: Theme.of(context).primaryColor,
      child: ListView(
        // Eliminamos el padding del listview
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
              height: 100,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                child: Stack(children: [
                  Positioned(
                      child: Text('Usuario',
                          style: Theme.of(context).textTheme.headline4)),
                  Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                          icon: Icon(Icons.close),
                          color: Colors.white,
                          onPressed: () => Navigator.of(context).pop())),
                ]),
              )),
          ListTile(
            title:
                Text('Pagina 1', style: Theme.of(context).textTheme.headline6),
            
            onTap: () {
              // Obtenemos la ruta actual
              String currentRoute =
                  (ModalRoute.of(context)?.settings.name).toString();
              if (currentRoute != '/pagina_1') {
                Navigator.of(context).pushNamed('/pagina_1');
              }
            },
          ),
          ListTile(
            title:
                Text('Pagina 2', style: Theme.of(context).textTheme.headline6),
            onTap: () {
              String currentRoute =
                  (ModalRoute.of(context)?.settings.name).toString();
              if (currentRoute != '/pagina_2') {
                Navigator.of(context).pushNamed('/pagina_2');
              }
            },
          ),
          ListTile(
            title:
                Text('Página 3', style: Theme.of(context).textTheme.headline6),
            onTap: () {
              String currentRoute =
                  (ModalRoute.of(context)?.settings.name).toString();
              if (currentRoute != '/pagina_3') {
                Navigator.of(context).pushNamed('/pagina_3');
              }
            },
          ),
          ListTile(
            title:
                Text('Créditos', style: Theme.of(context).textTheme.headline6),
            onTap: () {
              String currentRoute =
                  (ModalRoute.of(context)?.settings.name).toString();
              if (currentRoute != '/creditos') {
                Navigator.of(context).pushNamed('/creditos');
              }
            },
          ),
          ListTile(
            title: Text('Cerrar Sesion',
                style: Theme.of(context).textTheme.headline6),
            onTap: () {
              String currentRoute =
                  (ModalRoute.of(context)?.settings.name).toString();
              if (currentRoute != '/') {
                // Cerramos el menú lateral
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/');
              }
            },
          ),
        ],
      ),
    );
  }
}
