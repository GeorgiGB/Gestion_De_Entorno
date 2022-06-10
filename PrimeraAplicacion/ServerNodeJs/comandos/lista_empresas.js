const conexion = require('../config/db.config')

// Función asyncrona queu obtendra el listado de la empresas
async function listado_empresas(json) {
    let res = await conexion.query("SELECT * FROM obten_lista_empresas('" + JSON.stringify(json) + "')");
    return res.rows[0].jresultado;
}

module.exports = listado_empresas;