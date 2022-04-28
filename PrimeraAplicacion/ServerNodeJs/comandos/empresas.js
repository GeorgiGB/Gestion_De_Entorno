const conexion = require('../config/db.config');
const debug = require('./globales');
//  Función asincrona para la creación de la empresa
async function crear_empresa(json_emp){
  let res = await conexion.query
  ("SELECT * FROM crear_empresa('"+JSON.stringify(json_emp)+"');")                                    
 //debug.msg(res)
 return res.rows[0].jresultado;
}

module.exports = {
  crear_empresa:crear_empresa
}

