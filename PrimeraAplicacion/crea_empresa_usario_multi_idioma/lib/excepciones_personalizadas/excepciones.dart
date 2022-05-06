class ExceptionServidor implements Exception {
  int codError;
  ExceptionServidor(this.codError);
}

class ExceptionMenuLateral implements Exception {
  String msgErr;
  ExceptionMenuLateral(this.msgErr);
  /*@override
  String get message => toString();*/

  @override
  String toString() {
    return msgErr;
  }
}
