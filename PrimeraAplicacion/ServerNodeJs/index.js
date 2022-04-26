// Creación del servidor
const express = require('express');

// Para trabajar  Intercambio de Recursos de Origen Cruzado de diferentes servidores
const cors = require('cors');

// Tratar datos con formato JSON
const bodyParser = require('body-parser');

//Verifica si el usuario existe en el sistema
const verificar = require('./comandos/login');

//La conexion con el servidor de empresas
const crear_emp = require('./comandos/empresas');

//La conexion con el servidor de usuarios
const crear_ute = require('./comandos/usuarios_telemetria');

//La conexion con el servidor obtener listado de empresas
const obtener = require('./comandos/obtener');

const debug = require('./comandos/globales');

// Estas credenciales llevan implicitos el usuario y la contraseña
// Viene encriptadas en SHA1 de la aplicación cliente
const administrador = 'admin';


// Generar tokens con formato JWT
const jwt = require('jsonwebtoken');

// Creación ficticia de usuarios
const users = [
    {
        usuario: administrador
    }
];

//  ---------------------------------------------------------

// Middleware
// PASAR A ARCHIVO DE MIDDLEWARE
const verificarJWT = require('./middleware/verificarJWT');
// constante para verificar el token y sus cabeceras
// const authenticateJWT = (req, res, next) => {
//     // arrepleguem el JWT d'autorització
//     const authHeader = req.headers.authorization;
//     debug.msg(authHeader)
//     if (authHeader) {
//         //  recogemos el jwt
//         const token = authHeader.split(' ')[1];
//         debug.msg('token: ' + token);
//          //usando el verify accederemos al token y la llaveSecreta
//         jwt.verify(token, verificarJWT.llaveSecreta, (err, users) => {
//             debug.msg("Entro JWT: " + err);
//             if (err) {
//                 return headers(res).status(403).json([{
//                     "msg_error": "No tienes permisos"
//                 }]);
//             }
//             debug.msg();
//             req.users = users;
//             next();
//         });
//         next();
//     } else {
//         debug.msg("VOY A DAR ERROR DE TOKEN")
//         headers(res).status(401).json([{
//             "msg_error": "Token invalido"
//         }]);
//     }
// };

//  -------------------------------------------------------------

let app = express();
app.set('accesTokenSecret', verificarJWT.llaveSecreta)
var corsOptions = {
    origin: '*',
    optionsSuccessStatus: 200, // For legacy browser support
    methods: "POST",
    content_type: "application/json; charset=utf-8"

}

app.use(cors(corsOptions));
app.use(bodyParser.json());
app.use(express.json())

app.listen(8080);

debug.msg("Servidor ok");

const headers = require('./comandos/cabecera');
const { response } = require('express');

//  Iniciar sesion con el usuario
app.post('/login', (req, res) => {
    verificar.login(req.body).then(response => {

        if (response.bOk) {
            //  Si todo se ha rellenado correctamente
            headers(res).status(200).json(response)
            //  El resultado final se pone en send después de enviar todas las cabeceras.
        } else {
            if (response.icoderror < 0) {
                headers(res).status(500).json(response);
            } else {
                headers(res).status(404).json(response);
                //  El resultado final se pone en send después de enviar todas las cabeceras.  
            }

        }
    })
        .catch(err => {
            debug.msg(err)
            headers(res).status(500).json([{ "msg_error": "Error de servidor" }]);
        })
});


//  Con un post mandaremos al servidor la petición de la creación de una empresa
//  Ahora con la creación del middleware tenemos que introducir el authenticateJWT
//  
app.post('/crear_empresa', (req, res) => {
    debug.msg(req.body);

    // Requerimientos para la creación de una empresa el nombre y la contraseña
    const emp_nombre = req.body.emp_nombre;
    const emp_pwd = req.body.emp_pwd;
    // campo el cual nos indicara si la contraseña a sido solicitada por el servidor
    const auto_pwd = req.body.contrasena_autogenerada;

    // si alguno de los campos esta vacio, este mandara un error y no creara nada
        // Datos correctos
        let token = req.headers.authorization.split(' ')[1];
        crear_emp.crear_empresa(token, emp_nombre, emp_pwd, auto_pwd).then(response => {
            //debug.msg(response);
            //  Si todo esta correcto el usuario accedera
            if (response) {
                headers(res).status(200)
                    // El resultado final se pone en send después de enviar todas las cabeceras.
                    .json(([{ "msg": "Empresa creada correctamente" }]))
            }
        }
        )
            .catch(err => {
                headers(res).status(500).json(([{"msg": "Error de servidor."}]));
            });
    }

);

//  Con un post mandaremos la información necesaria para la creación de un usuario de telemetria
//  Crear usuarios de telemetria
// TODO modificar usuarios telemetria para leer json
app.post('/crear_usuarios_telemetria', (req, res) => {
    debug.msg(req.body);
    crear_ute.crear_usuarios_telemetria(req.body).then(response =>{
        if(response[0].bOk){
            headers(res).status(200).json(response)
                    .json([{ "Usuario_creado": true, "usa_cod": "codigo_devuelto" }])
        }else {
            if (response[0].cod_error < 0) {
                headers(res).status(500).json(response);
            } else if (response[0].cod_error == 401) {
                headers(res).status(401).json(response);
            } else {
                // Error desconocido
                headers(res).status(500).json(response);
            }
        }
    }
        ).catch(err => {
                headers(res).status(500).json("Error de servidor.");
            });
    }

);


//  Iniciar sesion con el usuario
app.post('/listado_empresas', (req, res) => {
    obtener.listado_empresas(req.body).then(response => {
        debug.msg(response)
        if (response[0].bOk) {
            //  Si todo se ha rellenado correctamente
            //  El resultado final se pone en send después de enviar todas las cabeceras.
            headers(res).status(200).json(response)
        } else {
            if (response[0].cod_error < 0) {
                headers(res).status(500).json(response);
            } else if (response[0].cod_error == 401) {
                headers(res).status(401).json(response);
            } else {
                // Error desconocido
                headers(res).status(500).json(response);
            }

        }
    }).catch(err => {
        debug.msg(err)
        headers(res).status(500).json([{ "msg_error": "Error de servidor" }]);
    })
});