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
	
	select jleer::json->>'name_token' into cToken;

	UPDATE usuarios_token
		SET ust_activo = false
		WHERE usuarios_token.ust_token = cToken AND usuarios_token.ust_activo
		
		RETURNING usuarios_token.ust_cod into icodusu;
		
	icodusu := COALESCE(icodusu, -1);
		
	EXCEPTION WHEN OTHERS THEN
		icoderror := -1;
		cerror := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.cerrar_sesion(character varying)
    OWNER TO postgres;