-- FUNCTION: public.insertar_token(jsonb)

-- DROP FUNCTION IF EXISTS public.insertar_token(jsonb);

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
	iCoderror integer;
	
BEGIN
	--	Creación de una tabla temporal para manipular los datos
	CREATE TEMP TABLE IF NOT EXISTS json_insert_token(
		token character varying,
		usu_cod integer
	);

	--	Inicialización de las variables
	bOk := false;
	cToken := '';
	iCoderror := 0;
	
		--	Primero miramos si el usuario tiene un token activo
		SELECT ust_token INTO cToken
			FROM usuarios_token,
			jsonb_populate_record(null::json_insert_token, jleer) as rg
			WHERE ust_usuario = rg.usu_cod
			AND ust_activo LIMIT 1;
			
		IF FOUND THEN
			--	Si existe el token activo
			bok := true;
		ELSE
			--	Si encuentra el registro entonces insertaremos el token a su respectiva tabla
			INSERT INTO usuarios_token (ust_usuario, ust_token, ust_activo)
				SELECT rg.usu_cod, rg.token, 'true'
				FROM jsonb_populate_record(null::json_insert_token, jleer) as rg
				RETURNING ust_token INTO cToken;

			IF FOUND then
				bok := true;
			END IF;
		END IF;
		
		jresultado :='[{"bOk":"'||bOk ||'", "token":"'||cToken||'"}]';
   
	
	EXCEPTION WHEN OTHERS THEN
		iCoderror := -1;
		jresultado :='[{"bOk":"'|| bOk
					  ||'", "cod_error":"'|| iCoderror 
					  ||'", "msg_error":"'|| SQLERRM ||'"}]';
	  END;
$BODY$;

ALTER FUNCTION public.insertar_token(jsonb)
    OWNER TO postgres;


--	Función que asocia un token a un usuario,
--	cada token es único para cada usuario
--	este comprueba si el token esta activo
--	si no lo esta este creará uno nuevo