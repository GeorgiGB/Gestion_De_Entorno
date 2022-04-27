const conexion = require('../config/db.config');

//  Función asincrona para cambiar el estado del token
async function cerrar_sesion(json_sesion){
  let res = await conexion.query
  ("SELECT * FROM cerrar_sesion('"+JSON.stringify(json_sesion)+"');")                                    
  return res.rows[0].jresultado;
}

module.exports = {
  cerrar_sesion:cerrar_sesion
}