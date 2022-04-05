
// Creación del servidor
const express = require('express');

// Para trabajar  Intercambio de Recursos de Origen Cruzado de diferentes servidores
const cors = require('cors');

// Tratar datos con formato JSON
const bodyParser = require('body-parser');

// Generar tokens con formato JWT
const jwt = require('jsonwebtoken');

//const contentType = require('express/lib/response');

//Verifica si el usuario existe en el sistema
const verificar = require('./comandos/login');

//La conexion con el servidor de empresas
const crear_emp = require('./comandos/empresas');

//La conexion con el servidor de usuarios
const crear_ute = require('./comandos/usuarios_telemetria');

const debug = require('./comandos/globales');
const verificarJWT = require('./comandos/verificarJWT');
// Constante utilizada para generar el token con JWT
const tokenSecret = ('./comandos/authenticateJWT');

// Estas credenciales llevan implicitos el usuario y la contraseña
// Viene encriptadas en SHA1 de l'aplicación cliente
const administrador = 'admin';
//const usuarionormal = '731ab4cd8bc667398c0ecfe80da1870cc0545ba4';
/*
Esto es un token ficticio para las pruebas
*/
let token;

// Creación ficticia de usuarios
const users = [
    {
    usuario: administrador
    }
    ];

//  ---------------------------------------------------------
const rutasProtegidas = express.Router();

rutasProtegidas.use((req, res, next) => {
    const token = req.headers['access-token'];
    if(token){
        jwt.verify(token, app.get(tokenSecret), (err, user) => {
            if(err){
                //  Si el token no esta registrado
                //  en la base de datos este mandara el siguiente mensaje
                return res.json({msg: 'Token invalida'});
            }else{
                //  Si todo es correcto mandara el token
                //  y continuara la operación
                req.user = user;
                next();
            }
        });
    }else{
        res.send({
            //  Si no se manda nada saldra este mensaje
            msg: 'Falta el token'
        })
    }

})

// funcion para verificar el token
const authenticateJWT = (req, res, next) => {
    // arrepleguem el JWT d'autorització
    const authHeader = req.headers.authorization;
    if (authHeader) { // si hi ha toquen
        // recuperem el jwt
        const token = authHeader.split(' ')[1];
        jwt.verify(token, app.get(tokenSecret), (err, user) => {
        if (err) {
            return res.sendStatus(403);
        }
        // afegim a la petició les dades que venien en el jwt user
            req.user = user;
        //  s'executa la segïuent funció, un cop s'ha fet el middleware
            next();
        });
        } else { // no està. contestem directament al client amb un error
            res.status(401).send("Token incorrecto")
        }
    };

//  -------------------------------------------------------------


let app = express();

var corsOptions = {
    origin: '*',
    optionsSuccessStatus: 200, // For legacy browser support
    methods: "POST",
    content_type: "application/json; charset=utf-8"

}

app.use(cors(corsOptions));
app.use(bodyParser.json());
app.set('accesTokenSecret', verificarJWT.llaveSecreta)

app.listen(8080);

debug.msg("Servidor ok");

//  Iniciar sesion con el usuario
app.post('/login', (req, res)=>{

    let usu_nombre = req.body.usuario;
    let usu_pwd = req.body.contra;
    
    if(!usu_nombre || !usu_pwd){
        res.status(401).send("No se ha introducido el nombre o la contraseña")
    }else{
        verificar.login(usu_nombre, usu_pwd).then(response => {
            debug.msg(response.login);
            //  Se genera en la base de datos
            token = getToken(usu_pwd);
            if(response){
                //  Si todo se ha rellenado correctamente
                    res.status(200)
                    .header("Access-Control-Allow-Headers", "Content-Type")
                    .header("Access-Control-Allow-Credentials", "true")
                    .header("Access-Control-Allow-Methods", "POST")
                    .header("Content-Type", "application/json; charset=utf-8")
                    .header("Pragma", "no-cache")
                    .send( JSON.stringify( [{token: token}]))
                    //  El resultado final se pone en send después de enviar todas las cabeceras.
            }else{
                res.status(404).send([{"msg_error": "Usuario o contraseña no válidos"}]);
                //  El resultado final se pone en send después de enviar todas las cabeceras.
            }
        })
        .catch(err => {
            debug.msg(err)
            res.status(500).send([{"msg_error": "Error de servidor"}]);
            })
    }
});


//  Con un post mandaremos al servidor la petición de la creación de una empresa
//  Crear empresa
app.post('/crear_empresa', authenticateJWT,(req,res)=>{
    debug.msg(JSON.stringify(req.body));

    let token = req.header("authorization");
    // Requerimientos para la creación de una empresa el nombre y la contraseña
    const emp_nombre = req.body.emp_nombre;
    const emp_pwd = req.body.emp_pwd;
    // campo el cual nos indicara si la contraseña a sido solicitada por el servidor
    const contrasena_autogenerada = req.body.contrasena_autogenerada;
    
    // si alguno de los campos esta vacio, este mandara un error y no creara nada
    if (!emp_nombre || !emp_pwd) {
        console.log(emp_nombre, emp_pwd);
        res.status(401).send("No se ha introducido el nombre o la contraseña");
    }else{
        // Datos correctos
        crear_emp.crear_empresa(token, emp_nombre, emp_pwd, contrasena_autogenerada).then(response => {
            debug.msg(response);
            //  Si todo esta correcto el usuario accedera
            if(response){res.status(200)
                .header("Access-Control-Allow-Headers", "Content-Type")
                .header("Access-Control-Allow-Credentials", "true")
                .header("Access-Control-Allow-Methods", "POST")
                .header("Content-Type", "application/json; charset=utf-8")
                .header("Pragma", "no-cache")
                // El resultado final se pone en send después de enviar todas las cabeceras.
                .send( JSON.stringify( [{"Empresa_creada": true}]))
            }}
        )
        .catch(err => {
            res.status(500).send("Error de servidor.");
        });
    }
    
});

//  Con un post mandaremos la información necesaria para la creación de un usuario de telemetria
//  Crear usuarios de telemetria
app.post('/crear_usuarios_telemetria',authenticateJWT, (req, res)=>{
    console.log(JSON.stringify(req.body));
    // Requisitos para la inserción de nuevo usuario
    const ute_nombre = req.body.usa_nombre;
    const ute_pwd = req.body.usa_pwd;
    const ute_filtro = req.body.ute_filtro;// Introducir en una lista
    const filtro_cod = req.body.filtro_cod;
    //  Campo el cual nos indicara si la contraseña a sido solicitada por el servidor
    const ute_contra_auto = req.body.contrasena_autogenerada;
    
    //console.log(req.body);
    //  Si alguno de los dos campos o los dos estan vacios este no mandara nada al servidor
    if (!ute_nombre || !ute_pwd) {
        res.status(401).send("No se ha introducido el nombre o la contraseña");
    }else{
        // Datos correctos
        crear_ute.crear_usuarios_telemetria(ute_nombre, ute_pwd,ute_contra_auto, ute_filtro, filtro_cod).then(
            () => res.status(200)
                .header("Access-Control-Allow-Headers", "Content-Type")
                .header("Access-Control-Allow-Credentials", "true")
                .header("Access-Control-Allow-Methods", "POST")
                .header("Content-Type", "application/json; charset=utf-8")
                .header("Pragma", "no-cache")
                // El resultado final se pone en send después de enviar todas las cabeceras.
                .send( JSON.stringify( [{"Usuario_creado": true, "usa_cod": "codigo_devuelto"}]))
        )
        .catch(err => {
            res.status(500).send("Error de servidor.");
        });
    }
    
});

// Funcion comparativa de tokens
function getToken(usuario_contra){
    return jwt.sign(
        {username: usuario_contra}, tokenSecret);
<<<<<<< HEAD
}
=======
 }
>>>>>>> 6546c1c6fa39af87e5b6b7477996ae0f772103f4

    
