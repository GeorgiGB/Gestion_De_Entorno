-- FUNCTION: public.insertartoken(jsonb)

-- DROP FUNCTION IF EXISTS public.insertartoken(jsonb);

CREATE OR REPLACE FUNCTION public.insertartoken(
	jleer jsonb,
	OUT jresultado jsonb)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	rRegistro record;
	ctoken character varying;
	
	bOk boolean;
	iUsu_cod integer;
	cError character varying;
	iCoderror integer;
	
BEGIN
--	Creacion de una tabla temporal para manipular los datos en ella
	CREATE TEMP TABLE IF NOT EXISTS json_data(
		ust_token character varying,
		ust_usuario integer,
		ust_activo boolean
	);

	bOk := false;
	iUsu_cod := -1;
	cError := '';
	iCoderror := 0;
	
	FOR rRegistro IN (SELECT * FROM jsonb_populate_record(null::json_data, jleer))
	
	LOOP
	END LOOP;
	
	IF FOUND THEN
		--	Si encuentra el registro entonces insertaremos el token a su respectiva tabla
		INSERT INTO usuarios_token (ust_usuario, ust_token, ust_activo)
			VALUES (rRegistro.ust_usuario, rRegistro.ust_token, true);
		IF FOUND then
			bok := true;
		ELSE
			iUsu_cod := -1;
		END IF;
		jresultado :='[{"bOk":"'|| bOk
					  ||'", "usu_cod":"'|| iUsu_cod ||'"}]';
	END IF;
   
	
	EXCEPTION WHEN OTHERS THEN
		iCoderror := -1;
		jresultado :='[{"bOk":"'|| bOk
					  ||'", "cod_error":"'|| iCoderror 
					  ||'", "msg_error":"'|| SQLERRM ||'"}]';
	  END;
$BODY$;

ALTER FUNCTION public.insertartoken(jsonb)
    OWNER TO postgres;
