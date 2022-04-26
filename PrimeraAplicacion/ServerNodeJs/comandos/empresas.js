const conexion = require('../config/db.config');
const debug = require('./globales');

async function crear_empresa(json_emp){
  //token, emp_nombre, emp_pwd, contrasena_autogenerada

  let res = await conexion.query("SELECT * FROM crear_empresa('"+JSON.stringify(json_emp)+"');")

  /*
  ("SELECT * FROM crearempresa('"+token+"', '"
  +emp_nombre+"', '" +emp_pwd+"', "+contrasena_autogenerada+",2);")
           */                                      

 // Resultado de la petición
 debug.msg(res);
 return res;
}


// El usuario principal creara una empresa
module.exports = {
  crear_empresa:crear_empresa
}

