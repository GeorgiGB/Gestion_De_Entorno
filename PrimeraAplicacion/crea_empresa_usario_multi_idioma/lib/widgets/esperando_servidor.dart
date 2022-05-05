import 'package:flutter/material.dart';

class Esperando {
  static esperandoA(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 15),
          Text(
            label,
            style: const TextStyle(
                color: Colors.black,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                fontSize: 16.0),
          ),
        ],
      ),
    );
    ;
  }
}


/*

Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 15),
              Text(AppLocalizations.of(context)!.esperandoAlServidor),
            ],
          ),
        );

*/