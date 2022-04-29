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
	rRegistro record;
	
	bOk boolean;
	cError character varying;
	iCoderror integer;

BEGIN
	jresultado :='[]';
	bOk := false;
	cError := '';
	iCoderror := 0;
		
	--  Consultamos si el token es válido
	select t.bok into bOk from public.validar_token(jleer::jsonb) t;
	
	IF (bOk) THEN
	
		--  Tabla temporal para leer el json enviado por el servidor
		CREATE TEMP TABLE IF NOT EXISTS json_empr_data(
			emp_busca character varying,
			ctoken character varying
		);
		
		--  Obtenemos los valores del JSON enviados por el servidor
		SELECT * INTO rRegistro
			FROM jsonb_populate_record(null::json_empr_data, jleer) AS j;
			
		--  Buscamos la s empresas que tienen una coincidencia con emp_busca al inicio de su nombre
		--  y lo guardamos en formato JSON en jresultado
		SELECT json_agg(empr) INTO jresultado from public.empresas empr WHERE emp_nombre ILIKE rRegistro.emp_busca || '%';

		--  Añadimos la variable bOk al JSON jresultado
		--  importante añadir Coalesce(jresultado, '{}') porque jresultado puede ser null
		select ('{"bOk":"'||bOk||'"}')::jsonb || Coalesce(jresultado, '[]') ::jsonb into jresultado;
	ELSE
		select ('{"bOk":"false", "cod_error":"401"}')::jsonb || jresultado ::jsonb into jresultado;
	END IF;
	
	

	EXCEPTION WHEN OTHERS THEN
		iCoderror := -1;
		jresultado :='[{"bOk":"'|| bOk
					  ||'", "cod_error":"'|| iCoderror 
					  ||'", "msg_error":"'|| SQLERRM ||'"}]';
		END;
$BODY$;

ALTER FUNCTION public.obten_lista_empresas(jsonb)
    OWNER TO postgres;

--  Función que se usara a la hora de la creación de un usuario de telemetria
--  se mostrara en forma de lista y para poder acceder a esa lista tendremos
--  que haber iniciado sesión con un usuario principal que tendra un token
--  el cual se comprobara que este activo para poder continuar