-- FUNCTION: public.insertar_token(jsonb)

DROP FUNCTION IF EXISTS public.insertar_token(jsonb);

CREATE OR REPLACE FUNCTION public.insertar_token(
	jleer jsonb,
	OUT jresultado jsonb)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE

	bOk boolean;
	cToken character varying;
	cError character varying;
	iCoderror integer;
	statusHTML integer;
	
BEGIN

	--	Inicialización de las variables
	bOk := false;
	cToken := '';
	cError := '';
	iCoderror := 0;
	statusHTML := 200;
	jresultado := '[]';
	
	--	Creación de una tabla temporal para manipular los datos
	CREATE TEMP TABLE IF NOT EXISTS json_insert_token(
		token character varying,
		cod integer
	);
	
	--	Primero miramos si el usuario tiene un token activo
	SELECT ust_token INTO cToken
		FROM usuarios_token
		WHERE ust_usuario = (SELECT jleer::jsonb->>'cod')::integer
		AND ust_activo LIMIT 1;

	IF FOUND THEN
		--	Si existe el token activo
		bOk := true;
	ELSE
		--	Insertamos el código de usuario asociado el token asociado y hacemos activo
		INSERT INTO usuarios_token (ust_usuario, ust_token, ust_activo)
			SELECT j.cod, j.token, true
			FROM jsonb_populate_record(null::json_insert_token, jleer) j
			RETURNING ust_token INTO cToken;


		IF FOUND then
			bOk := true;
		END IF;
	END IF;

	-- añadimos el resultado a la salida jresultado
	SELECT ('{"status":"' || statusHTML
			|| '", "bOk":"' || bOk
			|| '", "token":"' ||cToken||'"}')::jsonb || jresultado ::jsonb INTO jresultado;


	EXCEPTION WHEN OTHERS THEN
		statusHTML := 500;
		iCoderror := -1;
		cError := SQLERRM;

		SELECT ('{"status":"' || statusHTML
			|| '", "cod_error":"' || iCoderror
			|| '", "msg_error":"' || cError || '"}')::jsonb
			|| jresultado::jsonb into jresultado;
	END;
$BODY$;

ALTER FUNCTION public.insertar_token(jsonb)
    OWNER TO postgres;


--	Función que asocia un token a un usuario,
--	cada token es único para cada usuario
--	este comprueba si el token esta activo
--	si no lo esta este creará uno nuevo