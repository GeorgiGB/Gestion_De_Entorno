-- FUNCTION: public.crearusuariostelemetria(jsonb)

-- DROP FUNCTION IF EXISTS public.crear_usuarios_telemetria(jsonb);

CREATE OR REPLACE FUNCTION public.crear_usuarios_telemetria(
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
	iute_cod integer;
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
		CREATE TEMP TABLE IF NOT EXISTS ust_json(
			ute_emp_cod integer,
			ute_nombre character varying,
			ute_pwd character varying,
			ute_auto_pwd boolean,
			ute_centro_padre integer,
			ute_centro integer,
			ute_pdv integer,
			ute_jefe_area integer,
			ute_ruta integer,
			ute_empresa integer,
			ust_token character varying
		);
		
		SELECT * INTO rRegistro
			FROM jsonb_populate_record(null::ust_json, jleer) AS j;
	
		IF rRegistro.ute_auto_pwd THEN
		-- generar contraseña
			Select cpwd, icoderror as e into rRegistro.ute_pwd, icod_error from public.generador_cadena_aleatoria(16);
				IF icod_error !=0 THEN
						RAISE EXCEPTION 'Error en la generación de la contraseña';
				END IF;
		END IF;
		
		--	CREACION DE USUARIOS DE TELEMETRIA
		INSERT INTO usuarios_telemetria (ute_emp_cod, ute_nombre, ute_pwd, ute_centro_padre, ute_centro,
										 		ute_pdv, ute_jefe_area, ute_ruta,ute_empresa) 
				VALUES (rRegistro.ute_emp_cod, rRegistro.ute_nombre, rRegistro.ute_pwd, rRegistro.ute_centro_padre,
							 rRegistro.ute_centro, rRegistro.ute_pdv,
								rRegistro.ute_jefe_area, rRegistro.ute_ruta, rRegistro.ute_emp)
								RETURNING ute_cod INTO iute_cod;
	
			IF FOUND THEN
				bOk := true;
				-- añdimos la variable bOk al JSON jresultado
				select ('{"bOk":"'||bOk||'"}')::jsonb into jresultado;
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

ALTER FUNCTION public.crear_usuarios_telemetria(jsonb)
    OWNER TO postgres;

/*
SELECT * FROM public.crear_usuarios_telemetria('{
	"ute_emp_cod":"60",
	"ute_nombre":"pruebausuariostelemetria",
	"ute_pwd":"",
	"ute_auto_pwd":"true",
	"ute_centro_padre":"",
	"ute_centro":"2",
	"ute_pdv":"",
	"ute_jefe_area":"",
	"ute_ruta":"",
	"ute_empresa":"0",
	"ust_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Ijc4ODcxODZiMzM3NDk5NzFkZTUxNTg1OTUzMmRlZjE1ZjRiMjEwZWIiLCJpYXQiOjE2NDkzNDUyMzV9.olI-c3Zzl-QsCIgSDmhJ5QY71O7eL2d1mhDOrQSkP2k"}')*/