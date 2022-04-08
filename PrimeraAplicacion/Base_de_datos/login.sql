-- Al final del todo hay una llamada a la función de ejemplo

-- FUNCTION: public.login(json)

-- DROP FUNCTION IF EXISTS public.login(json);

CREATE OR REPLACE FUNCTION public.login(
	jleer json,
	OUT jresultado json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	rRegistro record;
	cUsu_nombre character varying;
	cUsu_pwd character varying;
	
	bOk boolean;
	iUsu_cod integer;
	cError character varying;
	iCoderror integer;

BEGIN
	-- tabla temporal para leer el json enviado por el servidor
	CREATE TEMP TABLE x(
		usu_nombre character varying,
		usu_pwd character varying
	);
	
	bOk := false;
	iUsu_cod := -1;
	cError := '';
	iCoderror := 0;
	
	-- Pasamos al json a la tabla temporal
	FOR rRegistro IN (select * from json_populate_record(null::x, jleer))
	
	LOOP
	END LOOP;
	

	IF FOUND THEN
		-- consultamos si existe el usuario con la contraseña
		SELECT usu_cod into iUsu_cod
			from usuarios 
			where usu_nombre = rRegistro.usu_nombre
				and usu_pwd = rRegistro.usu_pwd;
		IF FOUND THEN
			bOk := true;
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

ALTER FUNCTION public.login(json)
    OWNER TO postgres;

select * from public.login('{"usu_nombre": "Joselito", "usu_pwd": "7887186b33749971de515859532def15f4b210eb"}')