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

module.exports = {
    msg:msg,
    peticiones:peticiones
}