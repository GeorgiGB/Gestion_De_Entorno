# Tabla de errores

| Codigo de error | Motivo
|---|---|
200 | Todo a salido bien
400 | Bad Request
401 | Desautorizado o token no válido
500 | Error de servidor
23505 | unique_violation, ocurre cuando un inserte,update o delete violan una primary key, foreign key, un check, un unico constraint o a unique index
23503 | foreign_key_violation