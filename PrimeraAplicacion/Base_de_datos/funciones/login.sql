-- FUNCTION: public.login(json)

-- DROP FUNCTION IF EXISTS public.login(jsonb);

CREATE OR REPLACE FUNCTION public.login(
	jleer jsonb,
	OUT jresultado jsonb)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

--	Esta función se usara para la creación de usuarios principales de la aplicación
--	los usuarios principales son lo que pueden crear tanto empresas como usuarios de telemetria
--	a estos usuarios "principales" a la hora de la creación tendran un token asociado que los distingue de los usuarios de telemetria

DECLARE
	bOk boolean;
	iUsu_cod integer;
	icod_error integer;
	cError character varying;

BEGIN
	
	bOk := false;
	icod_error := 200;
	cError := '';
	jresultado := '[]';

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
		icod_error := -404;
	END IF;
	
	-- Añadimos el resultado a la salida jresultado

	-- SELECT ('{"status":"' || icod_error
	-- 	|| '", "cod":"' || iUsu_cod 
	-- 	|| '", "bOk":"' || bOk||'"}')::jsonb || jresultado::jsonb into jresultado;

	SELECT ('{"bOk":"' || bOk 
			|| '", "cod_error":"' || icod_error || '"}')::jsonb || jresultado::jsonb into jresultado;

	EXCEPTION WHEN OTHERS THEN
		select excepcion from control_excepciones(SQLSTATE, SQLERRM) into jresultado;
		END;
$BODY$;

ALTER FUNCTION public.login(jsonb)
    OWNER TO postgres;