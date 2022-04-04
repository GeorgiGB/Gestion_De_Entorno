const conexion = require('../db.config')


// Funcion que hara la conexion con la base de datos y mirara si esta el usuario creado con su token
async function login(usu_nombre, usu_pwd){
        // peticion del servidor
        // verificar si el usuario existe y proseguir con la operacion
       let res = await conexion.query("SELECT login('"+usu_nombre+"','"+usu_pwd+"')");
        //resultado de la operacion
        return res.rows[0].login;
    }

async function guardarToken(){

}

module.exports = {
    login:login,
    guardarToken:guardarToken
}   