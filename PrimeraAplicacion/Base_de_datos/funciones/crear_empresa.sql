CREATE OR REPLACE FUNCTION public.crear_empresa(
	jleer jsonb,
	OUT jresultado jsonb)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

--  Función que permite crear una empresa
--  Solo el usuario principal con un token activo
--  podrá insertar una nueva empresa la cual permite seguidamente
--	Si todo es correcto crear el usuario 'Admin'
--	y la relación entre empresas y usuarios de telemetria es
--	que cada empresa ha de tener mínimo un usuario de telemetria

--  Consulta ejemplo --
--	select * from crear_empresa('{"nombre":"pruebaempresaaa","pwd":"12333","auto_pwd":"false","ctoken":"a"}')

--  Respuesta en jsonb correcta
--  [{"bOk": "true", "cod_error": "200"}]

--  Respuesta en jsonb error empresa existente --
--  [
--    {
--      "bOk": "false",
--      "cod_error": "-400",
--      "msg_error": "llave duplicada viola restricción de unicidad «empresas_nombre_ukey»"
--    }
--  ]

--  Respuesta en jsonb otros errores --
--  [
--    {
--      "bOk": "false",
--      "cod_error": "-500",
--      "msg_error": "el valor nulo en la columna «emp_nombre» de la relación «empresas» viola la restricción de no nulo"
--    }
--  ]
	
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
	SELECT t.bok INTO bOk
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
			SELECT jleer::jsonb->>'nombre'
				RETURNING emp_cod INTO iemp_cod;
			
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
		--	Token no válido, usuario no validado.
		icod_error = -401;
	END IF;
	
	--	Añadimos la variable bOk i statusHTML al JSON jresultado
	SELECT ('{"bOk":"' || bOk 
			|| '", "cod_error":"' || icod_error || '"}')::jsonb || jresultado::jsonb into jresultado;

	EXCEPTION
	-- Códigos de error -> https://www.postgresql.org/docs/current/errcodes-appendix.html
	WHEN OTHERS THEN
		select excepcion from control_excepciones(SQLSTATE, SQLERRM) into jresultado;
	END;
$BODY$;