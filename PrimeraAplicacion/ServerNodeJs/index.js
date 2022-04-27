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

const cerrar = require('./comandos/cerrar_sesion');

const debug = require('./comandos/globales');

const headers = require('./comandos/cabecera');
const response = require('express');

let app = express();
app.set('accesTokenSecret', verificar.llaveSecreta)

//! Configuración de cors
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

//! -------------------------------------
debug.msg("Servidor ok");
//! -------------------------------------

/*
    Iniciar sesión con el usuario
*/
app.post('/login', (req, res) => {
    verificar.login(req.body).then(response => {

        if (response.bOk) {
            headers(res).status(200).json(response)
        } else {
            if (response.icoderror < 0) {
                headers(res).status(500).json(response);
            } else {
                headers(res).status(404).json(response);
            }

        }
    })
        .catch(err => {
            headers(res).status(500).json(response);
        })
});

/*
        -------------------------Crear Empresa-------------------------
    Con un post mandaremos al servidor la petición de la creación de una empresa
*/

app.post('/crear_empresa', (req, res) => {
    crear_emp.crear_empresa(req.body).then(response => {
        if (response[0].bOk) {
            headers(res).status(200).json(response)
        } else {
            if (response[0].cod_error < 0) {
                headers(res).status(500).json(response);
            } else if (response[0].cod_error == 401) {
                headers(res).status(401).json(response);
            } else {
                headers(res).status(500).json(response);
            }
        }
    }).catch(err => {
        headers(res).status(500).json(response)
    });
});

/*
        -------------------------Crear usuarios de telemetria-------------------------
    Con un post mandaremos la información necesaria para la creación de un usuario de telemetria  
*/

app.post('/crear_usuarios_telemetria', (req, res) => {
    crear_ute.crear_usuarios_telemetria(req.body).then(response => {
        if (response[0].bOk) {
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
        headers(res).status(500).json(response)
    });
});

/*
        -------------------------Listado de empresas-------------------------
    A la hora de crear a un usuario de telemetria este se tendra que asociar a una empresa,
    haremos una petición al servidor el cual se mostrara en un desplegabe de la aplicación.
*/
app.post('/listado_empresas', (req, res) => {
    obtener.listado_empresas(req.body).then(response => {
        if (response[0].bOk) {
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
        headers(res).status(500).json(response);
    })
});

app.post('/cerrar_sesion', (req, res) => {
    cerrar.cerrar_sesion(req.body).then(response => {
        if (response[0].bOk) {
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
        headers(res).status(500).json(response);
    })
});