let _debug = true;
const header = require('./cabecera');
var fs = require('fs');

//  Función que utilizaremos para mandar mensajes por pantalla y comprobar errores
function msg(message){
    if(_debug){
        console.log(message)
    }
}

//  Función asincrona que permite la petición a la base de datos con la información solicitada
// Esta función no és asíncrona
/*async */function peticiones(response, res){

    let responseErr = response[0].cod_error
    let status = 500
    switch (responseErr){
        case '0':
            status = 200
            break;

        case '-401':
            status = 401
            break;

        case '-23505':
            // status = 401
            // break;

        case '-23503':
            // status = 400
            // break;

            
        case '-404':
            status = 404
            break;
            
        default:
            status = 500;
        }

    status = Math.abs(status)
    // Errores de la BBDD
    if(status == 500){
        registrarErr(JSON.stringify(response[0]))
    }


    msg(status)
    header(res).status(status).json(response)
}

//  Función asincrona que añade un try cath para evitar errores
//  y manda la peticion deseada
 function lanzarPeticion(x, req, res){
    //  ctoken = bearer token
    //  Esta linea recoge el token del usuario
    try {
        //header(res).status(parseInt('hola')).json("asa")
        let authorization = req.headers.authorization
        if(authorization){
            req.body.ctoken = authorization.split(' ')[1]
        }
        x(req.body).then(response => {
            // peticiones no es un future
            peticiones(response, res);
        }).catch (err => errorDeServidor(res, err));
    }catch(err){
        errorDeServidor(res, err);
    }
}

function errorDeServidor(res, err){
    let msg_error = {status : 500,
        cod_error: -1,
        msg_error: err.name + ': '+ err.message}
    header(res).status(500).json(msg_error)
    registrarErr(JSON.stringify(msg_error))
}

//  Función para registrar errores del servidor que se guardaran en un archivo txt
function registrarErr(msgerr){
    let diastring = new Date().toString();
    diastring = diastring.substring(0, diastring.indexOf('('))
    try {
        fs.appendFile('registroLogs.txt',
        "["+diastring+"]"+
        "[msg: "+ msgerr + "]\n", function (err){
            // si se produce un error al escribir un fichero y lo lanzamos
            // el servidor se cuelga
            if (err) throw err;});
    }catch (err){
        msg(err)
    }}

module.exports = {
    msg:msg,
    peticiones:peticiones,
    lanzarPeticion:lanzarPeticion
}