const conexion = require('../config/db.config')
const globales = require('./globales');

// Función asyncrona que hara la conexión con la base de datos y mirara si esta el usuario creado con su token
async function listado_empresas(json) {
    globales.msg("SELECT * FROM public.obten_lista_empresas('" + JSON.stringify(json) + "')");
    let reslogin = await conexion.query("SELECT * FROM public.obten_lista_empresas('" + JSON.stringify(json) + "')");
    
    return reslogin.rows[0].jresultado;
}

module.exports = listado_empresas;