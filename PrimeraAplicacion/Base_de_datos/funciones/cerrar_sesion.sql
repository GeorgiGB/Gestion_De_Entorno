-- FUNCTION: public.cerrar_sesion(character varying)

-- DROP FUNCTION IF EXISTS public.cerrar_sesion(character varying);

CREATE OR REPLACE FUNCTION public.cerrar_sesion(
	jleer character varying,
	OUT icodusu integer,
	OUT icoderror integer,
	OUT cerror character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	cToken character varying;
BEGIN
	-- Inicializamos los parametros
	cerror := '';
	icoderror := 0;
	cToken := '';
	--	Transformamos el jleer que era principalmente un character varying
	--	por un json ya que tenemos que manipular los datos
	--	y luego insertarlo a cToken
	SELECT jleer::json->>'name_token' into cToken;

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
		
	EXCEPTION WHEN OTHERS THEN
		icoderror := -1;
		cerror := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.cerrar_sesion(character varying)
    OWNER TO postgres;

--	Función que permitira cambiar el estado de un token
--	de un usuario principal, si este tiene el token activo
--	cambiara a inactivo, por lo tanto tendria que iniciar de nuevo sesión
--  SELECT * FROM cerrar_sesion('{"name_token":"7887186b33749971de515859532def15f4b210eb"}')