-- FUNCTION: public.obten_lista_empresas(jsonb)

-- DROP FUNCTION IF EXISTS public.obten_lista_empresas(jsonb);

CREATE OR REPLACE FUNCTION public.obten_lista_empresas(
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
	icod_error integer;
    statusHTML integer;

BEGIN
	jresultado :='[]';
	bOk := false;
	cError := '';
	icod_error := 0;
    statusHTML := 200;
		
	--  Consultamos si el token es válido			
	SELECT t.bok INTO bOk FROM public.validar_token(jleer::jsonb) t;
	
	IF (bOk) THEN
	
		--  Tabla temporal para leer el json enviado por el servidor
		CREATE TEMP TABLE IF NOT EXISTS json_empr_data(
			emp_busca character varying,
			ctoken character varying
		);
			
		--  Buscamos la s empresas que tienen una coincidencia con emp_busca al inicio de su nombre
		--  y lo guardamos en formato JSON en jresultado
		SELECT json_agg(empr) INTO jresultado
			FROM public.empresas empr, jsonb_populate_record(null::json_empr_data, jleer) j
			WHERE emp_nombre ILIKE j.emp_busca || '%';

		--  Añadimos la variable bOk al JSON jresultado
		--  importante añadir COALESCE(jresultado, '{}') porque jresultado puede ser null
		SELECT (COALESCE(jresultado, '[]'))::jsonb into jresultado;
	ELSE
		statusHTML := 401;
	END IF;
				
		SELECT ('{"status":"' ||statusHTML
				||'", "bOk":"' || bOk 
				||'", "cod_error":"' || icod_error || '"}')::jsonb || jresultado ::jsonb INTO jresultado;
	
	

	EXCEPTION WHEN OTHERS THEN
		bOk := false;
		statusHTML := 500;
		icod_error := -1;
		jresultado :='[{"status":"' ||statusHTML
				||'", "bOk":"' || bOk 
				||'", "cod_error":"' || icod_error
				||'", "msg_error":"'|| SQLERRM ||'"}]';
		END;
$BODY$;

ALTER FUNCTION public.obten_lista_empresas(jsonb)
    OWNER TO postgres;

--  Función que se usara a la hora de la creación de un usuario de telemetria
--  se mostrara en forma de lista y para poder acceder a esa lista tendremos
--  que haber iniciado sesión con un usuario principal que tendra un token
--  el cual se comprobara que este activo para poder continuar