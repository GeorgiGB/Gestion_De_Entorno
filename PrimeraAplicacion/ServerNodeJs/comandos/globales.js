let _debug = true;

//  Creamos la funcion que permitira hacer comprobaciones al servidor
function msg(message){
    if(_debug){
        console.log(message)
    }
}

//  Esto permite que se puedan utilizar los otros modulos
module.exports = {
    msg:msg
}