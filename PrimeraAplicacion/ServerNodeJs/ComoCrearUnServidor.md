# Creación de un servidor

## 1. Prearación del servidor

Crearemos una carpeta a la que llamaremos "Nodejs" y para poder empezar a configurar el servidor, lo primero que tenemos que hacer sera instalar los npm necesarios para el correcto funcionamiento del programa.

```node
//  Necesarios
npm install express
npm install cors
npm install pg
npm install jsonwebtoken
npm install body-parser

//  Opcionales
npm install nodemon
```

Una vez instalados todos los npm necesarios nos aparecera un archivo llamado **package.json** en el se encuentran todo lo instalador anteriormente, si hemos instalado **nodemon** tendremos que cambiarle el nombre del script que se encuentra en el apartado "start".

**Nodemon nos permite de forma automática que el servidor vaya reiniciandose cada vez que ocurre un cambio.**

```json
{
"dependencies": {
    //  Dependencias instaladas
  },
"scripts":{
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "node index.js" // Cambiar a nodemon index.js
},
"author": "",
  "license": "ISC",
  "description": ""
}
```

## 2. Configuración básica del servidor

Para iniciar el servidor lo primero que haremos sera crear un archivo al que denominaremos "index.js". En este archivo será donde iniciaremos el servidor. Por lo tanto tendremos que hacer lo siguiente:

Importar todos los npm necesarios para este apartado

```js
//  Creación del servidor
const express = require('express');

//  Inicializacion express
let app = express();

//  Para trabajar Intercambio de Recursos de Origen Cruzado de diferentes servidores
const cors = require('cors');

//  Tratar datos con formato JSON
const bodyParser = require('body-parser');
```

Por tema de orden y no cargar tanto codigo en una misma página, crearemos una carpeta la cual denominaremos como "config". En esta carpeta de encontraran las configuraciones necesarias para **cors** y **pg**.

Dentro de esa carpeta creamos dos nuevos archivos, uno sera "cors.config.js" y otro "db.config.js". Una vez creado los archivos los rellenaremos.

Archivo de cofiguración de cors.config.js

```js
//  Configuración de cors en el archivo cors.config.js
//  Este sera inicializado en el index.js
var corsOptions = {
    origin: '*',
    optionsSuccessStatus: 200, // For legacy browser support
    methods: "POST",
    content_type: "application/json; charset=utf-8"

}
```

Archivo de configuración de db.config.js

```js
//  Configuración de db.config.js
//  Inicializando pg
const { Pool } = require('pg')
// Configuración de la base de datos
const pool = new Pool({
    user: 'tuusuario',// El usuario que usas en el programa de la base de datos
    host: 'tuip',// La ip que le hayas indicado anteriormente en la base de datos. 
    // Si es en local pondras "localhost"
    database: 'Tubasededatos',// El nombre se lo habras indicado en la base de datos
    password: 'tupwd',// La contraseña de la base de datos
    port: 1111,// El puerto lo habras configurado en la base de datos
});
```

### 2.1 Configuración de express

Añadiremos parametros a npm de express para poder iniciar el servidor, si hemos hecho todo lo anterior ahora tendremos que añadirle la configuración.

```js
// En el anterior codigo hemos inicializado a "express" con el nombre de la varible "app"
//Usara los parametros de cors que hemos configurado anteriormente
app.use(cors(corsOptions));
app.use(bodyParser.json());//   Devolvera un middleware este estructurado en json
app.use(express.json())//   Los datos que leera seran en json
app.listen(8080);// Puerto que tiene que escuchar
```

Cuando hablamos de **middleware** nos referimos a los métodos o funciones que se encuentran entre la solicitud y el envío de la respuesta de la aplicación.

Añadiremos un verificador de JWT para mayor seguridad. Crearemos una carpeta aparte que llamaremos "verificarJWT" para tener mejor organización y dentro de esa carpeta crearemos un archivo al cual le pondremos nuestra palabra del servidor.

```js
module.exports = {
    llaveSecreta: "laParaulaSecretaDelServidor"
}
```

### 2.3 Creación JWT

Crearemos un token que nos permita acceder de forma segura a la información de la base de datos, crearemos en el index.js una constante que contenga el "jsonwebtoken" y un token de prueba.

```js
//  Token de prueba
let token;

const jwt = require('jsonwebtoken');

//  token del servidor
llaveSecreta:'llavedeprueba';
```

### Función para comparar tokens válidos y la conexión con la base de datos a través de un login

Crearemos un nuevo archivo al que llamaremos "login.js" en el cual desarrollaremos dos funciones, la primera constara de una función asincrona, al tener que hacer una petición y esperar una respuesta de la base de datos, la función asincrona nos da la capacidad de poder diferir la ejecución de una función y que espere hasta completar la operación.

La segunda función firmara un token el cual ira enlazado al usuario que se haya iniciado sesión y verificara si el token es válido.

La estructura que se nos tiene que quedar es la siguiente.

---

├── Nodejs
│   ├── middleware
│   │   ├── verificarJWT.js
│   ├── config
│   │   ├── cors.config.js
│   │   ├── db.config.js
│   ├── login.js
│   ├── index.js
|   ├── package.json

---

```js
const conexion = require('../config/db.config')// Accedera a la base de datos

// Generar tokens con formato JWT
const jwt = require('jsonwebtoken');
const verificarJWT = require('../middleware/verificarJWT');
const { msg } = require('./globales');

async function login(nombre, pwd){// variables que habremos indicado en la base de datos

        if(fila.bok){
            let cod = fila.iusu_cod;
            //debug.msg("Podemos insertar.")
            //  insertar token en base de usuarios
            let token = getToken(pwd);
            //  Hacemos la petición a la base de datos
            let instoken = await conexion.query("SELECT * FROM insertartoken('"+token+"','"+cod+"')");
            //  Insertamos el token en fila si todo ha ido correcto
            fila.bok = instoken.rows[0].bok;
            //  Entonces crearemos un campo para recibir la respuesta
            if(fila.bok){
                fila.token = token;
            }
            //return instoken;
            //reslogin.token = instoken.rows[0].token;
            debug.msg("otro: "+instoken);
        }
        return fila;
    }

// Funcion comparativa de tokens
// Funcion de generacion de tokens
function getToken(usuario_contra){
    return jwt.sign(
        {username: usuario_contra}, tokenSecret);
        {username: usuario_contra}, verificarJWT.llaveSecreta;
}

// Los exportaremos para poder usarlos mas adelante en el index
module.exports = {
    login:login,
    getToken:getToken
} 

```

## 3. Lanzar una petición con token

Para poder lanzar una petición hacia la base de datos lo primero que tenemos que hacer es hacer un POST para introducir nuestra información.

```js
const jwt = require('jsonwebtoken');
const authToken = require('./login')
const verificarJWT = require('./middleware/verificarJWT');

// constante para verificar el token y sus cabeceras
const authenticateJWT = (req, res, next) => {
    // arrepleguem el JWT d'autorització
    const authHeader = req.headers.authorization;
    debug.msg(authHeader)
    if (authHeader) {
        //  recogemos el jwt
        const token = authHeader.split(' ')[1];
        //  usando el verify accederemos al token y la llaveSecreta
        jwt.verify(token, verificarJWT.llaveSecreta, (err, user) => {
            debug.msg("Entro JWT: "+err);
            if (err) {
                return headers(res).status(403).json([{
                    "msg_error":"No tienes permisos"}]);
            }

            req.user = user;
            next();
        });
    } else {
        debug.msg("VOY A DAR ERROR DE TOKEN")
        headers(res).status(401).json([{
            "msg_error": "Token invalido"}]);
    }
};

//  Iniciar sesion con el usuario
app.post('/login', (req, res)=>{
    
    let usu_nombre = req.body.usu_nombre;
    let usu_pwd = req.body.usu_pwd;
    
    if(!usu_nombre || !usu_pwd){
        headers(res).status(401)
        //.header("Content-Type", "application/json; charset=utf-8")
        .send([{"msg_error":"No se ha introducido el nombre o la contraseña"}])
    }else{
        verificar.login(usu_nombre, usu_pwd).then(response => {
            //debug.msg(response);

            if(response.bok){
                //  Si todo se ha rellenado correctamente
                    headers(res).status(200).json([{"token":response.token}])
                    //  El resultado final se pone en send después de enviar todas las cabeceras.
            }else{
                if(response.icoderror < 0){
                    headers(res).status(500).json([{
                        "bok":response.bok,
                        "cod_error":response.icoderror,
                        "msg_error":response.cerror}]);
                }else{
                    headers(res).status(404).json([{
                    "bok":response.bok,
                    "cod_error":response.icoderror,
                    "msg_error": "Usuario o contraseña no válidos"}]);
                //  El resultado final se pone en send después de enviar todas las cabeceras.  
                }
                
            }
        })
        .catch(err => {
            debug.msg(err)
            headers(res).status(500).json([{"msg_error": "Error de servidor"}]);
            })
    }
});
```
