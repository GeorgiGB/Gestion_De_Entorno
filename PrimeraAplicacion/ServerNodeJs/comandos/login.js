const conexion = require('../db.config')
const debug = require('./globales')
// Constante utilizada para generar el token con JWT
const tokenSecret = ('./comandos/authenticateJWT');

// Generar tokens con formato JWT
const jwt = require('jsonwebtoken');

// Funcion que hara la conexion con la base de datos y mirara si esta el usuario creado con su token
async function login(usu_nombre, usu_pwd){
        debug.msg("Entrando a login")
        // peticion del servidor
        // verificar si el usuario existe y proseguir con la operacion
       let reslogin = await conexion.query("SELECT * FROM login('"+usu_nombre+"','"+usu_pwd+"')");
        //resultado de la operacion
        debug.msg(reslogin.rows[0]);
        fila = reslogin.rows[0];

        debug.msg(fila)

        if(fila.bok){
            let usu_cod = fila.iusu_cod;
            debug.msg("Podemos insertar.")
            //  insertar token en base de usuarios
            let token = getToken(usu_pwd);
            let instoken = await conexion.query("SELECT * FROM insertartoken('"+token+"','"+usu_cod+"')");
            //reslogin.token = instoken.rows[0].token;
            debug.msg("otro: "+instoken.rows[0]);
        }
        return reslogin;
    }

// Funcion comparativa de tokens
function getToken(usuario_contra){
    return jwt.sign(
        {username: usuario_contra}, tokenSecret);
}

module.exports = {
    login:login,
    //guardarToken:guardarToken
}   