-- FUNCTION: public.crear_empresa(jsonb)

-- DROP FUNCTION IF EXISTS public.crear_empresa(jsonb);

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
	--  Inicializacion de los valores
	bOk := false;
	icod_error := 0;
	cError := '';
	
	--  Consultamos si el token es válido
	SELECT t.bok INTO bOk FROM public.validar_token(jleer::jsonb) t;
	
	IF (bOk) THEN
		--  Tabla temporal la cual usaremos para introducir los datos
		CREATE TEMP TABLE IF NOT EXISTS emp_json(
			emp_nombre character varying,
			emp_pwd character varying,
			auto_pwd boolean,
			ust_token character varying
		);
		
		SELECT * INTO rRegistro
			FROM jsonb_populate_record(null::emp_json, jleer) AS j;
			
		IF rRegistro.auto_pwd THEN
		--  Generador de pwd
			Select cpwd, icoderror as e into rRegistro.emp_pwd, icod_error from public.generador_cadena_aleatoria(16);
			IF icod_error !=0 THEN
					RAISE EXCEPTION 'Error en la generación de la contraseña';
			END IF;
			
		END IF;
		
		--  La creación de la empresa
		INSERT INTO empresas (emp_nombre)
			VALUES (rRegistro.emp_nombre)
			RETURNING emp_cod into iemp_cod;
		--  Al crear una empresa tambien
        --  crearemos un usuario que tendra un nombre predeterminado
        --  y usara el pwd de la empresa que le hemos indicado en el registro
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

ALTER FUNCTION public.crear_empresa(jsonb)
    OWNER TO postgres;

--  Función que permite crear una empresa
--  el cual solo el usuario principal con un token activo
--  podrá insertar una nueva empresa la cual permite seguidamente
--	crear a un nuevo usuario de telemetria
--	la relación entre empresas y usuarios de telemetria es
--	que cada empresa ha de tener mínimo un usuario de telemetria