-- FUNCTION: public.login(json)

DROP FUNCTION IF EXISTS public.login(jsonb);

CREATE OR REPLACE FUNCTION public.login(
	jleer jsonb,
	OUT jresultado jsonb)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	bOk boolean;
	iUsu_cod integer;
	cError character varying;
	iCoderror integer;

BEGIN
	
	bOk := false;
	jresultado := '[]';
	iUsu_cod := -1;
	cError := '';
	iCoderror := 0;
	
	-- Tabla temporal para leer el json enviado por el servidor
	CREATE TEMP TABLE IF NOT EXISTS json_data(
		nombre character varying,
		pwd character varying
	);
	
	--	Seleccionamos la tabla de la cual vamos a modificar y modificamos
	SELECT usu_cod INTO iUsu_cod
		FROM usuarios AS u, jsonb_populate_record(null::json_data, jleer) AS j
		WHERE u.usu_nombre = j.nombre AND u.usu_pwd = j.pwd;

	IF FOUND THEN
		bOk := true;
	ELSE
		iUsu_cod := -1;
	END IF;
	
	-- Añadimos el resultado a la salida jresultado
	SELECT ('{"bOk":"'|| bOk ||'", "cod":"'|| iUsu_cod ||'"}')::jsonb || jresultado ::jsonb INTO jresultado;
	
	EXCEPTION WHEN OTHERS THEN
		iCoderror := -1;
		jresultado :='[{"bOk":"'|| bOk
					  ||'", "cod_error":"'|| iCoderror 
					  ||'", "msg_error":"'|| SQLERRM ||'"}]';
		END;
$BODY$;

ALTER FUNCTION public.login(jsonb)
    OWNER TO postgres;

--	select * from public.login('{"nombre": "Joselito", "pwd": "7887186b33749971de515859532def15f4b210eb"}')

--	Esta función se usara para la creación de usuarios principales de la aplicación
--	los usuarios principales son lo que pueden crear tanto empresas como usuarios de telemetria
--	a estos usuarios "principales" a la hora de la creación tendran un token asociado que los distingue de los usuarios de telemetria