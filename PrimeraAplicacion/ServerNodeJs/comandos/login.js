const conexion = require('../db.config')
const debug = require('./globales')

// Funcion que hara la conexion con la base de datos y mirara si esta el usuario creado con su token
async function login(usu_nombre, usu_pwd){
        debug.msg("Entrando a login")
        // peticion del servidor
        // verificar si el usuario existe y proseguir con la operacion
       let reslogin = await conexion.query("SELECT * FROM login('"+usu_nombre+"','"+usu_pwd+"')");
        //resultado de la operacion
        debug.msg(reslogin.rows[0]);
        fila = reslogin.rows[0];
        //let fila = reslogin.rows[0]["login"].replace(/\(|\)/g,"");
        debug.msg(fila)

        if(fila.bok){
            debug.msg("Podemos insertar.")
            //  insertar token en base de usuarios
            //  let instoken = await conexion.query()

        }
        return fila;
    }

module.exports = {
    login:login,
    //guardarToken:guardarToken
}   