-- FUNCTION: public.crearempresa(jsonb)

-- DROP FUNCTION IF EXISTS public.crearempresa(jsonb);

CREATE OR REPLACE FUNCTION public.crear_empresa(
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
	iemp_cod integer;
	icod_error integer;
	cError character varying;
	
	
BEGIN
	-- Inicializacion de los valores
	bOk := false;
	icod_error := 0;
	cError := '';
	
	-- Consultamos si el token es válido
	SELECT t.bok INTO bOk FROM public.validar_token(jleer::jsonb) t;
	
	IF (bOk) THEN
		-- Tabla temporal
		CREATE TEMP TABLE IF NOT EXISTS emp_json(
			emp_nombre character varying,
			emp_pwd character varying,
			auto_pwd boolean,
			ust_token character varying
		);
		
		SELECT * INTO rRegistro
			FROM jsonb_populate_record(null::emp_json, jleer) AS j;
			
		IF rRegistro.auto_pwd THEN
		-- generar contraseña
			Select cpwd, icoderror as e into rRegistro.emp_pwd, icod_error from public.generador_cadena_aleatoria(16);
			IF icod_error !=0 THEN
					RAISE EXCEPTION 'Error en la generación de la contraseña';
			END IF;
			
		END IF;
		
		--LA CREACION DE LA EMPRESA
		INSERT INTO empresas (emp_nombre)
			VALUES (rRegistro.emp_nombre)
				RETURNING emp_cod into iemp_cod;
		
		IF FOUND THEN
			INSERT INTO usuarios_telemetria(ute_nombre, ute_pwd, ute_emp_cod)
				VALUES ('Admin', rRegistro.emp_pwd, iemp_cod);
				
			IF FOUND THEN
				bOk := true;
				-- añdimos la variable bOk al JSON jresultado
				select ('{"bOk":"'||bOk||'"}')::jsonb into jresultado;
			END IF;
		END IF;
	END IF;

	EXCEPTION WHEN OTHERS THEN
		icod_error := -1;
		cError := SQLERRM;
		jresultado :='[{"bOk":"'|| bOk
					  ||'", "cod_error":"'|| icod_error 
					  ||'", "msg_error":"'|| SQLERRM ||'"}]';
		END;
$BODY$;

ALTER FUNCTION public.crearempresa(jsonb)
	OWNER TO postgres;
	
/* select * from public.crearempresa('{
"emp_nombre": "funcioncrearempresa",
"emp_pwd":"4321",
"auto_pwd":"true", 
"ust_token":"7887186b33749971de515859532def15f4b210eb"}')

*/


