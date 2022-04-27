-- FUNCTION: public.crear_usuarios_telemetria(jsonb)

DROP FUNCTION IF EXISTS public.crear_usuarios_telemetria(jsonb);

CREATE OR REPLACE FUNCTION public.crear_usuarios_telemetria(
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
			-- Tabla temporal para recoger los valores del JSON jleer
			CREATE TEMP TABLE IF NOT EXISTS json_insert_usuarios_telemetria(
				ust_token character varying,
				ute_emp_cod integer,
				ute_nombre character varying,
				ute_pwd character varying, 
				auto_pwd boolean, -- indica si la contraseña se autogenerará
				ute_filtro character varying, -- nombre delcampo de filtro donde se insertará
				ute_cod_filtro integer -- el código de filtro a inssertar
			);
            
            -- Realizamos el INSERT en usuarios_telemetria desde los valores de la tabla del JSON jleer
			-- de forma que si algún campo de los que se encuentra
			-- en el CASE WHEN coincide con el fitro contenido en j.ute_filtro
            -- se le assignará el valor contenido en j.ute_cod_filtro
			INSERT INTO usuarios_telemetria
				(ute_emp_cod, ute_nombre, ute_pwd,
				 ute_centro_padre, ute_centro, ute_pdv,
				 ute_jefe_area, ute_ruta, ute_empresa) 
				SELECT 
					j.ute_emp_cod, j.ute_nombre,
					-- contraseña autogenerada
					(CASE WHEN j.auto_pwd THEN
					 	(SELECT cpwd FROM public.generador_cadena_aleatoria(16))
					 		ELSE j.ute_pwd END),
							
					-- A partir de aquí se insertarà el valor de j.ute_cod_filtro
					-- en el campo que en el CASE coincida con j.ute_filtro
					(CASE WHEN 'ute_centro_padre' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE null END),
					(CASE WHEN 'ute_centro' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE null END),
					(CASE WHEN 'ute_pdv' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE null END),
					(CASE WHEN 'ute_jefe_area' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE null END),
					(CASE WHEN 'ute_ruta' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE null END),
					(CASE WHEN 'ute_empresa' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE null END)
				-- Obtenemos los valores de la tabla del JSON jleer
				FROM jsonb_populate_record(null::json_insert_usuarios_telemetria, jleer) j;
			
			-- Usuario insertado?
			IF FOUND THEN
				bOk := true;
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

ALTER FUNCTION public.crear_usuarios_telemetria(jsonb)
    OWNER TO postgres;
	
-- Para hacer un insert hay que poner un ute_emp_cod que exista en la tabla empresas
-- Si exite en la tabla un nombre con el mismo ust_emp_cod HAY QUE CAMBIAR EL NOMBRE DE "ute_nombre"
-- select * from crear_usuarios_telemetria('{"ust_token": "7887186b33749971de515859532def15f4b210eb", "ute_emp_cod": "60","ute_nombre": "Jo78", "ute_pwd": "45678", "auto_pwd": "true", "ute_filtro": "ute_pdv", "ute_cod_filtro": "21"}');
-- select * from usuarios_telemetria
