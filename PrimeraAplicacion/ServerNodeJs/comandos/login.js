const conexion = require('../db.config')
const debug = require('./globales')

// Funcion que hara la conexion con la base de datos y mirara si esta el usuario creado con su token
async function login(usu_nombre, usu_pwd){
        debug.msg("Entrando en login")
        // peticion del servidor
        // verificar si el usuario existe y proseguir con la operacion
       let res = await conexion.query("SELECT login('"+usu_nombre+"','"+usu_pwd+"')");
        //resultado de la operacion
        debug.msg(res.rows[0])
        return res.rows[0];
    }

// async function guardarToken(){

// }

module.exports = {
    login:login,
    //guardarToken:guardarToken
}   