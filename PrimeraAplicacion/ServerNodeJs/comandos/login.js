const conexion = require('../config/db.config')
const debug = require('./globales')
// Constante utilizada para generar el token con JWT
const tokenSecret = ('./comandos/verificarJWT');

// Generar tokens con formato JWT
const jwt = require('jsonwebtoken');
const verificarJWT = require('../middleware/verificarJWT');

// Funcion que hara la conexion con la base de datos y mirara si esta el usuario creado con su token
async function login(json){
    debug.msg("Entrando a login ")
    debug.msg(JSON.stringify(json))
        // peticion del servidor
        // verificar si el usuario existe y proseguir con la operacion
       let reslogin = await conexion.query("SELECT * FROM login('"+JSON.stringify(json)+"')");
        //resultado de la operacion
        let fila = reslogin.rows[0].jresultado[0];
        
        if(fila.bOk){
            
            //  insertar token en base de usuarios
            let token = getToken(json.usu_pwd);
            //  Hacemos la petición a la base de datos
            let instoken = await conexion.query("SELECT * FROM insertartoken('"+JSON.stringify(token)+"')");
            debug.msg(JSON.stringify(token));
            //  Insertamos el token en fila si todo ha ido correcto
            fila.bOk = instoken.rows[0].bok;
            //  Entonces crearemos un campo para recibir la respuesta
            if(fila.bOk){
                fila.token = token;
            }
        }
        return fila;
    }

// Funcion de generacion de tokens
function getToken(usuario_contra){
    return jwt.sign(
        {username: usuario_contra}, verificarJWT.llaveSecreta);
}

module.exports = {
    login:login,
    getToken:getToken
}   