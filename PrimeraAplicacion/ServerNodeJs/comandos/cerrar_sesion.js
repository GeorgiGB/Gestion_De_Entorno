const conexion = require('../config/db.config');
//  Función asincrona para cambiar el estado del token
async function cerrar_sesion(json_sesion){
  /*
    Petición en la base de datos de la función de cerrar_sesion
    la función cambiara el estado del token de 'true' a 'false'
  */
  let res = await conexion.query("SELECT * FROM cerrar_sesion('"+JSON.stringify(json_sesion)+"')")
  return res.rows[0];
}

module.exports = cerrar_sesion;