// Creación del servidor
const express = require('express');

// Para trabajar  Intercambio de Recursos de Origen Cruzado de diferentes servidores
const cors = require('cors');

// Tratar datos con formato JSON
const bodyParser = require('body-parser');

//Verifica si el usuario existe en el sistema
const verificar = require('./comandos/login');

//La conexion con el servidor de empresas
const crear_emp = require('./comandos/empresas');

//La conexion con el servidor de usuarios
const crear_ute = require('./comandos/usuarios_telemetria');

const debug = require('./comandos/globales');

// Estas credenciales llevan implicitos el usuario y la contraseña
// Viene encriptadas en SHA1 de la aplicación cliente
const administrador = 'admin';


// Generar tokens con formato JWT
const jwt = require('jsonwebtoken');

// Creación ficticia de usuarios
const users = [
    {
    usuario: administrador
    }
    ];

//  ---------------------------------------------------------

// Middleware
//const authToken = require('./comandos/login')
const verificarJWT = require('./middleware/verificarJWT');
// constante para verificar el token y sus cabeceras
const authenticateJWT = (req, res, next) => {
    // arrepleguem el JWT d'autorització
    const authHeader = req.headers.authorization;
    debug.msg(authHeader)
    if (authHeader) {
        //  recogemos el jwt
        const token = authHeader.split(' ')[1];
        //  usando el verify accederemos al token y la llaveSecreta
        jwt.verify(token, verificarJWT.llaveSecreta, (err, user) => {
            debug.msg("Entro JWT: "+err);
            if (err) {
                return headers(res).status(403).json([{
                    "msg_error":"No tienes permisos"}]);
            }

            req.user = user;
            next();
        });
    } else {
        debug.msg("VOY A DAR ERROR DE TOKEN")
        headers(res).status(401).json([{
            "msg_error": "Token invalido"}]);
    }
};

//  -------------------------------------------------------------

let app = express();
app.set('accesTokenSecret', verificarJWT.llaveSecreta)
var corsOptions = {
    origin: '*',
    optionsSuccessStatus: 200, // For legacy browser support
    methods: "POST",
    content_type: "application/json; charset=utf-8"

}

app.use(cors(corsOptions));
app.use(bodyParser.json());
app.use(express.json())

app.listen(8080);

debug.msg("Servidor ok");

const headers = require('./comandos/cabecera');

//  Iniciar sesion con el usuario
app.post('/login', (req, res)=>{
    
    let usu_nombre = req.body.usu_nombre;
    let usu_pwd = req.body.usu_pwd;
    
    if(!usu_nombre || !usu_pwd){
        headers(res).status(401)
        //.header("Content-Type", "application/json; charset=utf-8")
        .send([{"msg_error":"No se ha introducido el nombre o la contraseña"}])
    }else{
        verificar.login(usu_nombre, usu_pwd).then(response => {
            //debug.msg(response);

            if(response.bok){
                //  Si todo se ha rellenado correctamente
                    headers(res).status(200).json([{"token":response.token}])
                    //  El resultado final se pone en send después de enviar todas las cabeceras.
            }else{
                if(response.icoderror < 0){
                    headers(res).status(500).json([{
                        "bok":response.bok,
                        "cod_error":response.icoderror,
                        "msg_error":response.cerror}]);
                }else{
                    headers(res).status(404).json([{
                    "bok":response.bok,
                    "cod_error":response.icoderror,
                    "msg_error": "Usuario o contraseña no válidos"}]);
                //  El resultado final se pone en send después de enviar todas las cabeceras.  
                }
                
            }
        })
        .catch(err => {
            debug.msg(err)
            headers(res).status(500).json([{"msg_error": "Error de servidor"}]);
            })
    }
});


//  Con un post mandaremos al servidor la petición de la creación de una empresa
//  Ahora con la creación del middleware tenemos que introducir el authenticateJWT
//  
app.post('/crear_empresa', authenticateJWT,(req,res)=>{
    debug.msg(req.body);
    
    // Requerimientos para la creación de una empresa el nombre y la contraseña
    const emp_nombre = req.body.emp_nombre;
    const emp_pwd = req.body.emp_pwd;
    // campo el cual nos indicara si la contraseña a sido solicitada por el servidor
    const contrasena_autogenerada = req.body.contrasena_autogenerada;
    
    // si alguno de los campos esta vacio, este mandara un error y no creara nada
    if (!emp_nombre || !emp_pwd && !contrasena_autogenerada) {
        console.log(emp_nombre, emp_pwd);
        headers(res).status(401).json([{"msg_error":"No se ha introducido el nombre o la contraseña"}]);
    }else{
        // Datos correctos
        let token = req.headers.authorization.split(' ')[1];
        crear_emp.crear_empresa(token, emp_nombre, emp_pwd, contrasena_autogenerada).then(response => {
            //debug.msg(response);
            //  Si todo esta correcto el usuario accedera
            if(response){headers(res).status(200)
                // El resultado final se pone en send después de enviar todas las cabeceras.
                .json(([{"msg": "empresa creada correctamente"}]))
            }}
        )
        .catch(err => {
            headers(res).status(500).json("Error de servidor.");
        });
    }
    
});

//  Con un post mandaremos la información necesaria para la creación de un usuario de telemetria
//  Crear usuarios de telemetria
app.post('/crear_usuarios_telemetria',authenticateJWT, (req, res)=>{
    console.log(JSON.stringify(req.body));
    // Requisitos para la inserción de nuevo usuario
    const ute_nombre = req.body.usa_nombre;
    const ute_pwd = req.body.usa_pwd;
    const ute_filtro = req.body.ute_filtro;// Introducir en una lista
    const filtro_cod = req.body.filtro_cod;
    //  Campo el cual nos indicara si la contraseña a sido solicitada por el servidor
    const ute_contra_auto = req.body.contrasena_autogenerada;
    
    //console.log(req.body);
    //  Si alguno de los dos campos o los dos estan vacios este no mandara nada al servidor
    if (!ute_nombre || !ute_pwd) {
        headers(res).status(401).json("No se ha introducido el nombre o la contraseña");
    }else{
        // Datos correctos
        crear_ute.crear_usuarios_telemetria(ute_nombre, ute_pwd,ute_contra_auto, ute_filtro, filtro_cod).then(
            () => headers(res).status(200)
                // El resultado final se pone en send después de enviar todas las cabeceras.
                .json([{"Usuario_creado": true, "usa_cod": "codigo_devuelto"}])
        )
        .catch(err => {
            headers(res).status(500).json("Error de servidor.");
        });
    }
    
});

    
