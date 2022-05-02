const conexion = require('../config/db.config');
const globales = require('./globales');
/*
  Función asincrona que permite la creación de un usuario de telemetria
  Estos usuarios son creados por el usuario principal
*/
async function crear_usuarios_telemetria(json_usu){

  globales.msg("SELECT * FROM crear_usuarios_telemetria('"+JSON.stringify(json_usu)+"');")

  let res = await conexion.query("SELECT * FROM crear_usuarios_telemetria('"+JSON.stringify(json_usu)+"');")

  return res.rows[0].jresultado;
}

module.exports = crear_usuarios_telemetria;