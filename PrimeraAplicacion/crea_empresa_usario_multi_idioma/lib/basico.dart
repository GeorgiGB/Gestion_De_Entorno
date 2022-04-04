import 'package:flutter/material.dart';
import 'globales.dart' as globales;

class basico extends StatefulWidget {
  const basico({Key? key, required this.token}) : super(key: key);
  final String token;
  @override
  State<basico> createState() => _basicoState();
}

class _basicoState extends State<basico> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Para cambiar"),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[],
      )),
    );
  }
}
