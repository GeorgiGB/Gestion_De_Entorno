const conexion = require('../config/db.config')
const debug = require('./globales')


// Funcion que hara la conexion con la base de datos y mirara si esta el usuario creado con su token
async function listado_empresas(json){
    debug.msg("Obteniedo listado empresas ")
    debug.msg(JSON.stringify(json))
        // peticion del servidor
        // verificar si el usuario existe y proseguir con la operacion
       let reslogin = await conexion.query("SELECT * FROM public.obten_lista_empresas('"+JSON.stringify(json)+"')");
       //let reslogin = await conexion.query("SELECT * FROM login('"+JSON.stringify(json)+"')"); 
       //resultado de la operacion
        return reslogin.rows[0].jresultado;
    }
module.exports = {
    listado_empresas:listado_empresas
}   