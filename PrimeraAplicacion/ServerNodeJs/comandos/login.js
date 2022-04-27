const conexion = require('../config/db.config')
const debug = require('./globales')

// Generar tokens con formato JWT
const jwt = require('jsonwebtoken');
const verificarJWT = require('../middleware/verificarJWT');

// Funcion asincrona que hara la conexion con la base de datos y mirara si esta el usuario creado con su token
async function login(json_login){
        /*
            Petición del servidor
            Verificar si el usuario existe y proseguir con la operación
        */     
       let reslogin = await conexion.query("SELECT * FROM login('"+JSON.stringify(json_login)+"')");
       //   Resultado de la operación
        let fila = reslogin.rows[0].jresultado[0];
        
        if(fila.bOk){
            
            //  Insertar token en base de usuarios
            fila.token = getToken(json_login.usu_pwd);
            //debug.msg("SELECT * FROM insertar_token('"+JSON.stringify(fila)+"')")
            //  Hacemos la petición a la base de datos
            let instoken = await conexion.query("SELECT * FROM insertar_token('"+JSON.stringify(fila)+"')");
            fila = instoken.rows[0].jresultado[0]
        }
        return fila;
    }

// Función de generación de tokens
function getToken(usuario_contra){
    return jwt.sign(
        {username: usuario_contra}, verificarJWT.llaveSecreta);
}

module.exports = {
    login:login,
    getToken:getToken
}   