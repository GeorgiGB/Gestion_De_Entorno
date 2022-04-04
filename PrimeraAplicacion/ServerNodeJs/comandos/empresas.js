const conexion = require('../db.config')

// El usuario principal creara una empresa
module.exports = {
  // Función asincrona que permite la creación de una empresa introduciendo su nombre y pwd.
  async crear_empresa(emp_nombre, emp_pwd, contrasena_autogenerada){
    // Petición del servidor
      let res = await conexion.query(`INSERT INTO empresas (emp_nombre,
         emp_pwd) 
         VALUES ($1,
                  $2)`,
                  [emp_nombre, 
                    emp_pwd,
                    contrasena_autogenerada]);
      // Resultado de la petición
      console.log(res)
    }
  }

