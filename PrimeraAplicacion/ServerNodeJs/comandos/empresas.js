const conexion = require('../config/db.config');

//  Función asincrona para la creación de la empresa
async function crear_empresa(json_emp){
  /*
    Llamada a la función de la base de datos
    la cual recogera la información y la interpretara en JSON.stringify
  */
  let res = await conexion.query("SELECT * FROM crear_empresa('"+JSON.stringify(json_emp)+"');")
  return res.rows[0].jresultado;
}

module.exports = crear_empresa;