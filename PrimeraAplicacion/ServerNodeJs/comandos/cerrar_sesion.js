const conexion = require('../config/db.config');
const debug = require('./globales')
//  Función asincrona para cambiar el estado del token
async function cerrar_sesion(json_sesion){

  //debug.msg(JSON.stringify(json_sesion))
  let res = await conexion.query("SELECT * FROM cerrar_sesion('"+JSON.stringify(json_sesion)+"')")
         //debug.msg(res)
  return res;
}

module.exports = {
  cerrar_sesion:cerrar_sesion
}