const conexion = require('../config/db.config')

//  Estos usuarios son los que crea el usuario principal
//  función asincrona que permite la creacion de un usuario de telemetria
async function crear_usuarios_telemetria(
  json){
  
  // Petición al servidor (corregir)
  let res = await conexion.query
  ("SELECT * FROM crear_usuarios_telemetria('"+json+"');")


  //  Resultado de toda la operación
  console.log(res)
}

//  Exportamos las funciones
module.exports = {
  crear_usuarios_telemetria:crear_usuarios_telemetria
  }