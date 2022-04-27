# DOCUMENTACIÓN

---

![DART](https://iconape.com/wp-content/files/pa/370777/svg/370777.svg) ![Flutter](https://cdn.iconscout.com/icon/free/png-256/flutter-3628777-3030139.png)

## Dart & Flutter

```dart
//  Hello World
import 'package:flutter/material.dart';

void main() {
  runApp(
    const Center(
      child: Text(
        'Hello, world!',
        textDirection: TextDirection.ltr,
      ),
    ),
  );
}
```

---

- [Crear paquete dart](https://blog.logrocket.com/how-to-create-dart-packages-for-flutter/)

>flutter create --template=package flutter_pkg

- [Documentación](https://dart.dev/guides)
- [Iconos generales](https://api.flutter.dev/flutter/material/Icons-class.html)

```dart
name: my_awesome_application
flutter:
  uses-material-design: true

Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: const <Widget>[
    Icon(
      Icons.favorite,
      color: Colors.pink,
      size: 24.0,
      semanticLabel: 'Text to announce in accessibility modes',
    ),
  ],
)
```

- [Iconos de botones](https://api.flutter.dev/flutter/material/IconButton-class.html)

```dart
//  Constructor
IconButton(
  {Key? key,
  double? iconSize})
```

- [Flutter Chip Widget](https://codesinsider.com/flutter-chip-example-tutorial/)

```dart
//  Constructor
Chip(
  {Key? key,
  Widget? avatar,
  bool useDeleteButton}
)
//  Below is the example code to add a chip to our flutter application.
Chip(
       label: Text("Flutter"),
    ),
```

- [Flutter Widgets](https://docs.flutter.dev/development/ui/widgets)

- [All Dart Answes](https://www.codegrepper.com/code-examples/dart)

---

![GITHUB](https://www.drk.com.ar/2021/08/github.svg.png)

## Github Comandos

---

- [QuickStart](https://docs.github.com/es/get-started/quickstart)
- [Crear Repositorio](https://www.drk.com.ar/2021/08/github.svg.png)
- [Crear una rama](https://docs.github.com/es/get-started/quickstart/hello-world#creating-a-branch)

---
![JSON](https://byspel.com/wp-content/uploads/2017/06/JSON-Logo.png)

## Json

---

- [JSON Introduction](https://www.w3schools.com/js/js_json_intro.asp)

```js
'{"name":"John","age":30, "car":null}'
```

- [JSON Placeholder](https://jsonplaceholder.typicode.com/)

```js
//  Run this code
fetch('https://jsonplaceholder.typicode.com/todos/1')
  .then(response => response.json())
  .then(json => console.log(json))
//  -----
  {
    "userId": 1,
    "id": 1,
    "title": "delectus aut autem",
    "completed": false
  }
  //  Return this
```

- [JSON Formater](https://jsonformatter.curiousconcept.com/)
- [JSON Viewer](http://jsonviewer.stack.hu/)
- [JSON Stringify](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify)
  
```js
//  JSON.stringify()
JSON.stringify(value[, replacer[, space]])

//  Example
console.log(JSON.stringify({ x: 5, y: 6 }));
//  Expected output: "{"x":5,"y":6}"
```

---
![MARKDOWN](https://cdn.iconscout.com/icon/free/png-256/markdown-3627132-3029540.png)

## Markdown Sintax

```md
"# Esto es un titulo"

Esto es una frase de ejemplo
```

---

- [Documentación](https://www.markdownguide.org/cheat-sheet/)
- [Copiar emojis](https://emojipedia.org/)
- [Emojis alternativa](https://www.markdownguide.org/extended-syntax/#copying-and-pasting-emoji)

---

![NODE JS](https://cdn.iconscout.com/icon/free/png-256/node-js-1174925.png)

## Node JS

---

- [Instalación](https://nodejs.org/es/docs/guides/getting-started-guide/)

```node
var http = require('http');

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end('Hello World!');
}).listen(8080);
```

- [Función Asincrona](https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/async_function)

```node
async function add2(x) {
  const p_a = resolveAfter2Seconds(20);
  const p_b = resolveAfter2Seconds(30);
  return x + await p_a + await p_b;
}
```

- [PG Documentación](https://node-postgres.com/)
  - [Pool](https://node-postgres.com/api/pool)
  - [Client](https://node-postgres.com/api/client)

---
![PGADMIN](https://static.macupdate.com/products/60968/l/pgadmin-4-logo.png?v=1607426731)

## PG Admin / PostgreSQL

---

- [Instalación](https://www.postgresqltutorial.com/postgresql-getting-started/install-postgresql/)
- [Update Example](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-update/)
  
```sql
UPDATE table_name
SET column1 = value1,
    column2 = value2,
    ...
WHERE condition;
```

- [Funciones](https://www.postgresql.org/docs/current/sql-syntax-calling-funcs.html)

```sql
--  Create a function
CREATE FUNCTION concat_lower_or_upper(a text, b text, uppercase boolean DEFAULT false)
RETURNS text
AS
$$
 SELECT CASE
        WHEN $3 THEN UPPER($1 || ' ' || $2)
        ELSE LOWER($1 || ' ' || $2)
        END;
$$
LANGUAGE SQL IMMUTABLE STRICT;
```

```sql
--  Calling a function
SELECT concat_lower_or_upper(a => 'Hello', b => 'World');
 concat_lower_or_upper 
-----------------------
 hello world
(1 row)
```

- [SQL Cheat Sheet](https://www.sqltutorial.org/sql-cheat-sheet/)
- [Inner Join](https://programacionymas.com/blog/como-funciona-inner-left-right-full-join)
- [Error Codes](https://www.postgresql.org/docs/current/errcodes-appendix.html)

---

### Otros

- [Comparar Textos](https://text-compare.com/es/)
- [Deepl](https://www.deepl.com/es/translator)
