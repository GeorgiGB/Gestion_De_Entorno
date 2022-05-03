//  Creación del servidor
const express = require('express');

//  Para trabajar Intercambio de Recursos de Origen Cruzado de diferentes servidores
const cors = require('cors');

//  Tratar datos con formato JSON
const bodyParser = require('body-parser');

//  Verifica si el usuario existe en el sistema
const verificar = require('./comandos/login');

//  La conexion con el servidor de empresas
const crear_emp = require('./comandos/empresas');

//  La conexion con el servidor de usuarios
const crear_ute = require('./comandos/usuarios_telemetria');

//  La conexion con el servidor obtener listado de empresas
const obtener = require('./comandos/obtener');

//  Cambiara el estado del token del usuario
const cerrar = require('./comandos/cerrar_sesion');

//  Puede mandar mensajes a la terminal y mandar peticiones al servidor
const globales = require('./comandos/globales');

//  Son la petición al servidor
const headers = require('./comandos/cabecera');
const { response } = require('express');
// Estas credenciales llevan implicitos el usuario y la contraseña
// Viene encriptadas en SHA1 de la aplicación cliente
const administrador = 'admin';  //? Esto aún hace falta?
let app = express();
app.set('accesTokenSecret', verificar.llaveSecreta)

//! Configuración de cors
var corsOptions = require("./config/cors.config")

// 
// var corsOptions = {
//     origin: '*',
//     optionsSuccessStatus: 200, // For legacy browser support
//     methods: "POST",
//     content_type: "application/json; charset=utf-8"

// }

app.use(cors(corsOptions));
app.use(bodyParser.json());
app.use(express.json())
app.listen(8080);

//! -------------------------------------
globales.msg("Servidor ok");
//! -------------------------------------

/*
    Iniciar sesión con el usuario
*/
app.post('/login', (req, res) => {
    verificar(req.body).then(response => {
        //console.log(2/0);
        globales.peticiones(response, res)
    }).catch(err => {
        console.log(err)
        headers(res).status(500).json(response);
        });
});

/*
        -------------------------Crear Empresa-------------------------
    Con un post mandaremos al servidor la petición de la creación de una empresa.
    Crearemos una empresa y un usuario predeterminado con la contraseña de la misma
*/

app.post('/crear_empresa', (req, res) => {
    crear_emp(req.body).then(response => {
        globales.peticiones(response, res)
    });
});

/*
        -------------------------Crear usuarios de telemetria-------------------------
    Con un post mandaremos la información necesaria para la creación de un usuario de telemetria  
*/

app.post('/crear_usuarios_telemetria', (req, res) => {
    crear_ute(req.body).then(response => {
        globales.peticiones(response, res)
    });     
});

/*
        -------------------------Listado de empresas-------------------------
    A la hora de crear a un usuario de telemetria este se tendra que asociar a una empresa,
    haremos una petición al servidor el cual se mostrara en un desplegabe de la aplicación.
*/
app.post('/listado_empresas', (req, res) => {
    obtener(req.body).then(response => {
        globales.peticiones(response, res)
    })
});

/*
        -------------------------Cerrar Sesion de Usuario-------------------------
    Cada usuario principal tiene un token asociado el cual solo se usara una vez,
    durante la sesión iniciada ese token estara activo. Hasta que el usuario decida salir de la aplicación,
    el cual cambiara al estado de 'false' y no se volvera a utilizar.
*/
app.post('/cerrar_sesion', (req, res) => {
    cerrar(req.body).then(response => {
        globales.peticiones(response, res)
    })
});