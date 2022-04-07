const conexion = require('../config/db.config')
const debug = require('./globales')
// Constante utilizada para generar el token con JWT
const tokenSecret = ('./comandos/verificarJWT');

// Generar tokens con formato JWT
const jwt = require('jsonwebtoken');
const verificarJWT = require('../middleware/verificarJWT');

// Funcion que hara la conexion con la base de datos y mirara si esta el usuario creado con su token
async function login(usu_nombre, usu_pwd){
        debug.msg("Entrando a login")
        // peticion del servidor
        // verificar si el usuario existe y proseguir con la operacion
       let reslogin = await conexion.query("SELECT * FROM login('"+usu_nombre+"','"+usu_pwd+"')");
        //resultado de la operacion
        //debug.msg(reslogin.rows[0]);
        let fila = reslogin.rows[0];

        if(fila.bok){
            let usu_cod = fila.iusu_cod;
            //  insertar token en base de usuarios
            let token = getToken(usu_pwd);
            //  Hacemos la petición a la base de datos
            let instoken = await conexion.query("SELECT * FROM insertartoken('"+token+"','"+usu_cod+"')");
            //  Insertamos el token en fila si todo ha ido correcto
            fila.bok = instoken.rows[0].bok;
            //  Entonces crearemos un campo para recibir la respuesta
            if(fila.bok){
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