const conexion = require('../config/db.config')
const debug = require('./globales')
//  Estos usuarios son los que crea el usuario principal
//  función asincrona que permite la creación de un usuario de telemetria
async function crear_usuarios_telemetria(json_usu){
  debug.msg(("SELECT * FROM crear_usuarios_telemetria('"+JSON.stringify(json_usu)+"');"))
  let res = await conexion.query
  ("SELECT * FROM crear_usuarios_telemetria('"+JSON.stringify(json_usu)+"');")

  //  Resultado de toda la operación
  return res.rows[0].jresultado;
}

//  Exportamos las funciones
module.exports = {
  crear_usuarios_telemetria:crear_usuarios_telemetria
  }
