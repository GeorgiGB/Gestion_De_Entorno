const conexion = require('../config/db.config');
const debug = require('./globales');

async function crear_empresa(emp_nombre, emp_pwd, contrasena_autogenerada){
  let res = await conexion.query("SELECT * FROM crearempresa('"
                                  +emp_nombre+"', '"
                                    +emp_pwd+", '"
                                      +contrasena_autogenerada+"')")

 // Resultado de la petición
 debug.msg(res);
}


// El usuario principal creara una empresa
module.exports = {
  crear_empresa:crear_empresa
}

