const conexion = require('../config/db.config');
const debug = require('./globales');

async function crear_empresa(json_emp){
  let res = await conexion.query
  ("SELECT * FROM crear_empresa('"+JSON.stringify(json_emp)+"');")                                    
 // Resultado de la petición
 return res.rows[0].jresultado;
}

// El usuario principal creara una empresa
module.exports = {
  crear_empresa:crear_empresa
}

