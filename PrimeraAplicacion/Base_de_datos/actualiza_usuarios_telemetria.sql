-- FUNCTION: public.crear_usuarios_telemetria(jsonb)

-- DROP FUNCTION IF EXISTS public.actualiza_usuarios_telemetria(jsonb);

CREATE OR REPLACE FUNCTION public.actualiza_usuarios_telemetria(
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
			CREATE TEMP TABLE IF NOT EXISTS json_update_usuarios_telemetria(
				ust_token character varying,
				ute_emp_cod integer,
				ute_nombre character varying,
				ute_nuevo_nombre character varying, -- si está presente se canviará el nombre por el nuevo nombre
				ute_pwd character varying, 
				auto_pwd boolean, -- indica si la contraseña se autogenerará
				ute_filtro character varying, -- nombre delcampo de filtro donde se insertará
				ute_cod_filtro integer -- el código de filtro a inssertar
			);
            
            -- Realizamos el UPDATE en usuarios_telemetria desde los valores de la tabla del JSON jleer
			-- de forma que si algún campo de los que se encuentra
			-- en el CASE WHEN coincide con el fitro contenido en j.ute_filtro
            -- se le assignará el valor contenido en j.ute_cod_filtro
			UPDATE usuarios_telemetria
				SET (ute_nombre, ute_pwd,
					 ute_centro_padre, ute_centro, ute_pdv,
					 ute_jefe_area, ute_ruta, ute_empresa
					)
				 =
				(	
					-- Cambiamos el nombre?
					(CASE WHEN j.ute_nuevo_nombre IS NULL THEN
					 	usuarios_telemetria.ute_nombre
					ELSE 
						j.ute_nuevo_nombre
					END),
					
					-- Actualizamos la contraseña?
					(CASE WHEN j.ute_pwd IS NULL THEN
					 	usuarios_telemetria.ute_pwd
					ELSE  
						-- es autogenerada?
						CASE WHEN j.auto_pwd THEN
					 		(SELECT cpwd FROM public.generador_cadena_aleatoria(16))
					 	ELSE j.ute_pwd END
					END),
							
					-- A partir de aquí se actualizará el valor de j.ute_cod_filtro
					-- en el campo que en el CASE coincida con j.ute_filtro
					(CASE WHEN 'ute_centro_padre' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE usuarios_telemetria.ute_centro_padre END),
					(CASE WHEN 'ute_centro' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE usuarios_telemetria.ute_centro END),
					(CASE WHEN 'ute_pdv' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE usuarios_telemetria.ute_pdv END),
					(CASE WHEN 'ute_jefe_area' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE usuarios_telemetria.ute_jefe_area END),
					(CASE WHEN 'ute_ruta' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE usuarios_telemetria.ute_ruta END),
					(CASE WHEN 'ute_empresa' = j.ute_filtro THEN
						j.ute_cod_filtro ELSE usuarios_telemetria.ute_empresa END)
				 )
				-- Obtenemos los valores de la tabla del JSON jleer
				FROM jsonb_populate_record(null::json_update_usuarios_telemetria, jleer) j
					WHERE usuarios_telemetria.ute_emp_cod = j.ute_emp_cod
					 AND usuarios_telemetria.ute_nombre = j.ute_nombre;
			
			-- Usuario actualizado?
			IF FOUND THEN
				bOk := true;
			END IF;
			
		ELSE
			-- Token no válido, usuario no validado.
			SELECT ('{"cod_error":"401"}')::jsonb || jresultado ::jsonb into jresultado;
        END IF;
		
			-- añadimos la variable bOk al JSON jresultado
			SELECT ('{"bOk":"' || bOk || '"}')::jsonb || jresultado::jsonb into jresultado;

        EXCEPTION WHEN OTHERS THEN
        	bOk := false;
            icod_error := -1;
            cerror := SQLERRM;
            jresultado := '[{"bOk":"' || bOk || '", "cod_error":"' || icod_error || '", "msg_error":"' || SQLERRM || '"}]';
        END;
    
$BODY$;

ALTER FUNCTION public.actualiza_usuarios_telemetria(jsonb)
    OWNER TO postgres;


-- Para hacer un insert hay que poner un ute_emp_cod que exista en la tabla empresas
-- Para que funcione hay que poner un ute_emp_cod y un ute_nombre que existan en la tabla usuarios_telemetria
-- select * from actualiza_usuarios_telemetria('{"ute_emp_cod": "60", "ust_token": "7887186b33749971de515859532def15f4b210eb", "ute_nombre": "Jo5sssssssss", "ute_nuevo_nombre": "Joana", "ute_pwd": "490", "auto_pw": "true", "ute_filtro": "ute_pdv", "ute_cod_filtro": "35"}');
-- select * from usuarios_telemetria