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
async function peticiones(response, res){
    let status = parseInt(response[0].status)
    if(status == 500){
        registrarErr(JSON.stringify(response[0]))
    }
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
            peticiones(response, res)
        })
    } catch (err) {
        let msg_error = {status : 500,
			cod_error: -1,
			msg_error: err.name + ': '+ err.message}
        header(res).status(500).json(msg_error)
        registrarErr(JSON.stringify(msg_error))
    }
}

//  Función para registrar errores del servidor que se guardaran en un archivo txt
function registrarErr(msgerr){
    let diastring = new Date().toString();
    diastring = diastring.substring(0, diastring.indexOf('('))
    try {
        fs.appendFile('registroLogs.txt',
        "["+diastring+"]"+
        "[msg: "+ msgerr + "]\n", function (err){
            if (err) throw err;});
    }catch (err){
        msg(err)
    }}

module.exports = {
    msg:msg,
    peticiones:peticiones,
    tryCath:lanzarPeticion
}