CREATE OR REPLACE FUNCTION public.validar_token(
	jleer jsonb,
	OUT bok boolean,
	OUT cerror character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	rRegistro record;
	token character varying;
	iUsu_cod integer;
	cerror character varying;
	iCoderror integer;
BEGIN
	-- Inicializamos los parametros
	
	bok := false;
	iUsu_cod := -1;
	cError := '';
	iCoderror := 0;
	
	--	Creacion de una tabla temporal para manipular los datos en ella
	/*CREATE TEMP TABLE IF NOT EXISTS json_validar_token(
		ctoken character varying
	);*/
	
	SELECT jleer::jsonb->>'ctoken' INTO token;

		
	SELECT ut.ust_activo into bok FROM usuarios_token ut --, -- tabla 1
		 -- jsonb_populate_record(null::json_validar_token, jleer) t2 -- tabla 2 temporal
			 WHERE ut.ust_token = token AND ut.ust_activo;
	
	IF NOT FOUND THEN
		bok := false;
	else
		-- actualizamos los usos del token
		UPDATE usuarios_token ut
			SET ust_usos = ust_usos + 1
				FROM jsonb_populate_record(null::json_validar_token, jleer) t2
					WHERE ut.ust_token = token;
	END IF;
	
	EXCEPTION WHEN OTHERS THEN
		iCoderror := -1;
		cerror := SQLERRM;
		END;
$BODY$;