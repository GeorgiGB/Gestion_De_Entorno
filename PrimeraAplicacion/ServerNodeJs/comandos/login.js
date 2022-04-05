const conexion = require('../db.config')
const debug = require('./globales')

// Funcion que hara la conexion con la base de datos y mirara si esta el usuario creado con su token
async function login(usu_nombre, usu_pwd){
        debug.msg("Entrando a login")
        // peticion del servidor
        // verificar si el usuario existe y proseguir con la operacion
       let reslogin = await conexion.query("SELECT login('"+usu_nombre+"','"+usu_pwd+"')");
        //resultado de la operacion
        debug.msg(reslogin.rows[0]);

        let fila = reslogin.rows[0]["login"].replace(/\(|\)/g,"");
        debug.msg(typeof fila)

        for (const key in fila) {
            if (Object.hasOwnProperty.call(fila, key)) {
                const element = fila[key];
                debug.msg(key+": "+element)
            }
        }
        debug.msg(typeof fila.toString())
        switch(fila.bOk){
            case 't':
            case 'true':
            case '1':
                fila.bOk = true;
                break;

            default:
                fila.bOk = false;
            }
        if(fila.bOk){
            //  insertar token en base de usuarios
            //  let instoken = await conexion.query()
        }
        //debug.msg(fila.bOk);
        return fila;
    }

module.exports = {
    login:login,
    //guardarToken:guardarToken
}   