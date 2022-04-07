const conexion = require('../config/db.config');
const debug = require('./globales');

async function crear_empresa(token, emp_nombre, emp_pwd, contrasena_autogenerada){
  let res = await conexion.query
  ("SELECT * FROM crearempresa('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImM4YTM5ZTIxZGU5NzcyOWEyYzgwNmJjNjU5NjhmMmI0ZmRlM2Q3OTgiLCJpYXQiOjE2NDkzMzE3NDl9.wdKkXtTcVw4qV0XunhRM3V5019lo6mgf5reA-Hlrxg0', '"+emp_nombre+"', '" +emp_pwd+"', "+contrasena_autogenerada+",2);")
                                      
                                   
                                    
                                      
//"SELECT * FROM crearempresa('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImM4YTM5ZTIxZGU5NzcyOWEyYzgwNmJjNjU5NjhmMmI0ZmRlM2Q3OTgiLCJpYXQiOjE2NDkzMzE3NDl9.wdKkXtTcVw4qV0XunhRM3V5019lo6mgf5reA-Hlrxg0','adsada','',true,2);")
                                      

 // Resultado de la petición
 debug.msg(res);
 return res;
}


// El usuario principal creara una empresa
module.exports = {
  crear_empresa:crear_empresa
}

