const conexion = require('../db.config')

//  Estos usuarios son los que crea el usuario principal
//  función asincrona que permite la creacion de un usuario de telemetria
async function crear_usuarios_telemetria(
  token,
  ute_nombre,
    ute_pwd,
    ute_autogenerada, 
    ute_empresa, 
    ute_filtro,
    filtro_cod){
  
  // Petición al servidor
  let res = await conexion.query
  (`INSERT INTO usuarios_telemetria (
    [ute_nombre,
      ute_pwd,
      ute_empresa, 
      ute_filtro]) VALUES ($1,
                      $2,
                      $3,
                      $4)`,
  [token,
    ute_nombre,
    ute_pwd,
    ute_autogenerada, 
    ute_empresa, 
    ute_filtro,
    filtro_cod]);

  //  Resultado de toda la operación
  console.log(res)
}

//  Exportamos las funciones
module.exports = {
  crear_usuarios_telemetria:crear_usuarios_telemetria
  }