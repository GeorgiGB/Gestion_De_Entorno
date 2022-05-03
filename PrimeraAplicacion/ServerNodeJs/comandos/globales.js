let _debug = true;
const header = require('./cabecera');

//  Función que utilizaremos para mandar mensajes por pantalla y comprobar errores
function msg(message){
    if(_debug){
        console.log(message)
    }
}

//  Función asincrona que permite la petición a la base de datos con la información solicitada
async function peticiones(response, res){
    header(res).status(parseInt(response[0].status)).json(response)
}

//  Función asincrona que añade un try cath para evitar errores
//  y manda la peticion deseada
 function tryCath(x, req, res){
    try {
        x(req.body).then(response => {
            peticiones(response, res)
        })
    } catch (error) {
        // TODO enviar respuesta a quien a generado la petición
        msg(error)
    }
}

module.exports = {
    msg:msg,
    peticiones:peticiones,
    tryCath:tryCath
}