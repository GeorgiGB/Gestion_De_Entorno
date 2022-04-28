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
    let bOk = response[0].bOk === 'true';
    //    Transformamos el bOk a boolean para poder seguir con la petición
    let cod_error = parseInt(response[0].cod_error );
    //  el cod_error lo transformamos a integer para leerlo en la petición
    
    if (bOk) {
        //  Información enviada con éxito
        header(res).status(200).json(response)
    } else {
        switch(cod_error){
            case 401:
                // Usuario no autorizado
                header(res).status(401).json(response);
                break;
            case -2:
                // Error (llave duplicada)
                header(res).status(200).json(response);
                break;
            default:
                // Otros errores
                header(res).status(500).json(response);
                break;
        }
    }
}


module.exports = {
    msg:msg,
    peticiones:peticiones
}