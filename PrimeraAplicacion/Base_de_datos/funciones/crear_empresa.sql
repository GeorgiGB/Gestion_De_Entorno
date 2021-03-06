-- FUNCTION: public.crear_empresa(jsonb)

DROP FUNCTION IF EXISTS public.crear_empresa(jsonb);

CREATE OR REPLACE FUNCTION public.crear_empresa(
	jleer jsonb,
	OUT jresultado jsonb)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
	
DECLARE
	bOk boolean;
	iemp_cod integer;
	icod_error integer;
	cError character varying;

BEGIN
	bOk := false;
	icod_error := 0;
	cError := '';
	jresultado := '[]';

	-- Consultamos si el token es válido
	SELECT t.bOk INTO bOk
		FROM public.validar_token(jleer::jsonb) t;
	
	IF bOk THEN
		-- Tabla temporal
		CREATE TEMP TABLE IF NOT EXISTS emp_json(
			nombre character varying,
			pwd character varying,
			auto_pwd boolean,
			ctoken character varying
		);
		
		--LA CREACION DE LA EMPRESA
		INSERT INTO empresas (emp_nombre)
			SELECT j.nombre
				FROM jsonb_populate_record(null::emp_json, jleer) j
				RETURNING emp_cod into iemp_cod;
			
		-- Empresa insertada
		IF FOUND THEN
			-- Creamos el usuario Administrador de la empresa en la tabla usuarios_telemetria
			-- Por defecto se crea con el filtro ute_empresa := 0
			INSERT INTO usuarios_telemetria(ute_nombre, ute_pwd, ute_emp_cod)
				SELECT
					-- Usuario administrador
					'Admin',
					
					-- contraseña autogenerada
					(CASE WHEN j.auto_pwd THEN
					 	(SELECT cpwd FROM public.generador_cadena_aleatoria(16))
					 		ELSE j.pwd END),
					
					-- código empresa
					iemp_cod
				FROM jsonb_populate_record(null::emp_json, jleer) j;
				
			IF FOUND THEN
				bOk := true;
			END IF;
		END IF;
			
	ELSE
		-- Token no válido, usuario no validado.
		SELECT ('{"cod_error":"401"}')::jsonb || jresultado ::jsonb into jresultado;
	END IF;
		
	-- añadimos la variable bOk al JSON jresultado
	SELECT ('{"bOk":"' || bOk || '"}')::jsonb || jresultado::jsonb into jresultado;

	EXCEPTION
	-- Códigos de error -> https://www.postgresql.org/docs/current/errcodes-appendix.html
	WHEN OTHERS THEN
		bOk = false;
		cError := SQLERRM;
		CASE
			 -- el '23505' equivale a unique_violation
			 -- si ponemos directamente unique_violation en lugar de '23505'
			 -- da el siguiente error "ERROR:  no existe la columna «unique_violation»"
			WHEN SQLSTATE = '23505' THEN
				icod_error := -2;
			ELSE
				icod_error := -1;
		END CASE;

		SELECT ('{"bOk":"' || false || '", "cod_error":"' || icod_error || '", "msg_error":"' || cError || '"}')::jsonb
			|| jresultado::jsonb into jresultado;
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
--	select * from crear_empresa('{"nombre":"pruebaempresaaa","pwd":"12333","auto_pwd":"false","ctoken":"a"}')