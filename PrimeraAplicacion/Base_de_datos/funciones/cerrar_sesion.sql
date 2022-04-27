DROP FUNCTION IF EXISTS public.cerrar_sesion(jsonb);

CREATE OR REPLACE FUNCTION public.cerrar_sesion(
	jleer jsonb,
	OUT jresultado jsonb)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	bOk boolean;
	cError character varying;
	iCoderror integer;
BEGIN
	-- Inicializamos los parametros
	
	bOk := false;
	cError := '';
	iCoderror := 0;
	
	--	Creacion de una tabla temporal para manipular los datos en ella
	CREATE TEMP TABLE IF NOT EXISTS json_estado_token(
		usu_token character varying
	);

	UPDATE usuarios_token
		SET ust_activo = 'false'
			FROM jsonb_populate_record(null::json_validar_token, jleer) t2
		WHERE usuarios_token.ust_token = t2.ust_token AND usuarios_token.ust_activo;
	
	IF FOUND THEN
		bOk := true;
	END IF;
	
	EXCEPTION WHEN OTHERS THEN
		iCoderror := -1;
		cError := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.cerrar_sesion(jsonb)
    OWNER TO postgres;