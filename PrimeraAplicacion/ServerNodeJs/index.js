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
app.post('/crear_empresa', (req, res) => {
    crear_emp.crear_empresa(req.body).then(response=>{
        if(response[0].bOk){
            headers(res).status(200).json(([{"msg": "Usuario creado correctamente"}]))
        }else{
            if (response[0].cod_error < 0) {
                headers(res).status(500).json(response);
            } else if (response[0].cod_error == 401) {
                headers(res).status(401).json(response);
            } else {
                // Error desconocido
                headers(res).status(500).json(response);
            }
        }
    }).catch(err=>{
        headers(res).status(500).json(([{"msg": "Error de servidor"}]))
    });
});

//  Con un post mandaremos la información necesaria para la creación de un usuario de telemetria
//  Crear usuarios de telemetria
app.post('/crear_usuarios_telemetria', (req, res) => {
    //debug.msg(req.body);
    crear_ute.crear_usuarios_telemetria(req.body).then(response =>{
        if(response[0].bOk){
            headers(res).status(200).json(([{"msg": "Usuario creado correctamente"}]))
        }else{
            if (response[0].cod_error < 0) {
                headers(res).status(500).json(response);
            } else if (response[0].cod_error == 401) {
                headers(res).status(401).json(response);
            } else {
                // Error desconocido
                headers(res).status(500).json(response);
            }
        }
    }).catch(err=>{
        headers(res).status(500).json(([{"msg": "Error de servidor"}]))
    });
});

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