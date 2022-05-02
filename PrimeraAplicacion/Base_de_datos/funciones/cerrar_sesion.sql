-- FUNCTION: public.cerrar_sesion(jsonb)

-- DROP FUNCTION IF EXISTS public.cerrar_sesion(jsonb);

CREATE OR REPLACE FUNCTION public.cerrar_sesion(
	jleer jsonb,
	OUT jresultado jsonb)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
--	Función que permitira cambiar el estado de un token
--	de un usuario principal, si este tiene el token activo
--	cambiara a inactivo, por lo tanto tendria que iniciar de nuevo sesión
--  SELECT * FROM cerrar_sesion('{"name_token":"a"}')

DECLARE
	icodusu integer;
	icoderror integer;
	cError character varying;
	statusHTML integer;
	cToken character varying;
	
BEGIN
	-- Inicializamos los parametros
	cerror := '';
	icoderror := 0;
	cToken := '';
    statusHTML := 200;
    jresultado := '[]';
	
	--	Transformamos el jleer que era principalmente un character varying
	--	por un json ya que tenemos que manipular los datos
	--	y luego insertarlo a cToken
	SELECT jleer::json->>'ctoken' into cToken;

	--	Hacemos un update de usuarios_token con el json ya transformado
	UPDATE usuarios_token
		SET ust_activo = false	--	indicamos que lo queremos a false
		WHERE usuarios_token.ust_token = cToken AND usuarios_token.ust_activo
		--	Que busque por la tabla y que este activo
		--	si este no lo esta no continuara y no devolvera nada
		RETURNING usuarios_token.ust_cod into icodusu;
		--	Si existe el usuario con el token activo
		--	devolvera el cod del usuario
		
	icodusu := COALESCE(icodusu, -1);
	
	
	--	Añadimos la variable bOk i statusHTML al JSON jresultado
	SELECT ('{"status":"' ||statusHTML
		|| '", "cod_error":"' || icoderror || '"}')::jsonb
		|| jresultado::jsonb into jresultado;
		
	EXCEPTION WHEN OTHERS THEN
    	statusHTML := 500;
		icoderror := -1;
		cerror := SQLERRM;
		
		SELECT ('{"status":"' || statusHTML
			|| '", "cod_error":"' || icoderror
			|| '", "msg_error":"' || cerror || '"}')::jsonb
			|| jresultado::jsonb into jresultado;
		END;
$BODY$;

ALTER FUNCTION public.cerrar_sesion(jsonb)
    OWNER TO postgres;


