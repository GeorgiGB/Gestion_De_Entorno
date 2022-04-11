-- FUNCTION: public.crearempresa(jsonb)

DROP FUNCTION IF EXISTS public.crearempresa(jsonb);

CREATE OR REPLACE FUNCTION public.crearempresa(
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
	iUsu_cod integer;
	Cod_error integer;
	cError character varying;
	icod_error integer;
	
BEGIN
	-- Tabla temporal
	CREATE TEMP TABLE IF NOT EXISTS emp_json(
		emp_nombre character varying,
		emp_pwd character varying,
		auto_pwd boolean,
		ust_token character varying
	);
	
	-- Inicializacion de los valores
	
	bOk := false;
	Cod_error := 0; -- excepcion
	icod_error :=0; -- error de generacion de pwd automatica
	cError := '';
	
	SELECT * INTO rRegistro
		FROM jsonb_populate_record(null::emp_json, jleer) t2;
	
	IF rRegistro.auto_pwd THEN 
	-- generar contraseña
		Select cpwd, icoderror as e into rRegistro.emp_pwd, icod_error from public.generador_cadena_aleatoria(16);
		IF icod_error !=0 THEN
				RAISE EXCEPTION 'Error en la generación de la contraseña';
		END IF;
	END IF;
	
	
	
	-- GENERAR LA CREACION DE LA EMPRESA
	SELECT t.bok INTO bOk FROM validar_token(jleer) t;
	IF false THEN
		INSERT INTO empresas (emp_nombre)
			VALUES (rRegistro.emp_nombre);
				-- RETURNING emp_cod into emp_cod;
   		END IF;
	
	--IF FOUND THEN
	--	bOk := true;
	--END IF;
		jresultado:= '[{
		"auto_pwd":"'||bOk||'"
		}]';
	EXCEPTION WHEN OTHERS THEN
		Cod_error := -1;
		cError := SQLERRM;
		jresultado:= '[{
		"cError":"'||cError||'"
		}]';
		END;
$BODY$;

ALTER FUNCTION public.crearempresa(jsonb)
    OWNER TO postgres;

SELECT * FROM crearempresa('{"emp_nombre": "pruebacrearempresa1","emp_pwd": "12345","auto_pwd": "true",
						   "ust_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Ijc4ODcxODZiMzM3NDk5NzFkZTUxNTg1OTUzMmRlZjE1ZjRiMjEwZWIiLCJpYXQiOjE2NDkzNDUyMzV9.olI-c3Zzl-QsCIgSDmhJ5QY71O7eL2d1mhDOrQSkP2k"}')
    
    
    


