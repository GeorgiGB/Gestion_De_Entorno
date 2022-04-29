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
	-- Declaramos variables y las inicializamos
    DECLARE
        bOk boolean;
        icod_error integer;
        cError character varying;
		iemp_cod integer;
    BEGIN
        bOk := false;
        icod_error := 0;
        cError := '';
        jresultado := '[]';
		
        --	Consultamos si el token es válido
        SELECT t.bOk INTO bOk
        	FROM public.validar_token(jleer::jsonb) t;
		--	Si es válido el programa seguira
        IF bOk THEN
			--	Tabla temporal para recoger los valores del JSON jleer
			CREATE TEMP TABLE IF NOT EXISTS json_update_usuarios_telemetria(
				ctoken character varying,
				emp_cod integer,
				nombre character varying,
				nuevo_nombre character varying, -- Si está presente se cambiara el nombre por el nuevo nombre
				pwd character varying, 
				auto_pwd boolean, --	Indica si la contraseña se autogenerará
				filtro character varying, --	Nombre del campo de filtro donde se insertará
				cod_filtro integer --	El código de filtro se asociara con el nombre del filtro
			);
            
            --	Realizamos el UPDATE en usuarios_telemetria desde los valores de la tabla del JSON jleer
			--	de forma que si algún campo de los que se encuentra
			--	en el CASE WHEN coincide con el fitro contenido en j.filtro
            --	se le assignará el valor contenido en j.cod_filtro
			UPDATE usuarios_telemetria
				SET (ute_nombre, ute_pwd,
					 ute_centro_padre, ute_centro, ute_pdv,
					 ute_jefe_area, ute_ruta, ute_empresa
					)
				 =
				(	
					--	Cambiamos el nombre?
					(CASE WHEN j.nuevo_nombre IS NULL THEN
					 	usuarios_telemetria.ute_nombre
					ELSE 
						j.nuevo_nombre
					END),
					
					--	Actualizamos la contraseña?
					(CASE WHEN j.pwd IS NULL THEN
					 	usuarios_telemetria.ute_pwd
					ELSE  
						--	Es autogenerada?
						CASE WHEN j.auto_pwd THEN
					 		(SELECT cpwd FROM public.generador_cadena_aleatoria(16))
					 	ELSE j.pwd END
					END),
							
					--	A partir de aquí se actualizará el valor de j.cod_filtro
					--	en el campo que en el CASE coincida con j.filtro
					(CASE WHEN 'ute_centro_padre' = j.filtro THEN
						j.cod_filtro ELSE usuarios_telemetria.ute_centro_padre END),
					(CASE WHEN 'ute_centro' = j.filtro THEN
						j.cod_filtro ELSE usuarios_telemetria.ute_centro END),
					(CASE WHEN 'ute_pdv' = j.filtro THEN
						j.cod_filtro ELSE usuarios_telemetria.ute_pdv END),
					(CASE WHEN 'ute_jefe_area' = j.filtro THEN
						j.cod_filtro ELSE usuarios_telemetria.ute_jefe_area END),
					(CASE WHEN 'ute_ruta' = j.filtro THEN
						j.cod_filtro ELSE usuarios_telemetria.ute_ruta END),
					(CASE WHEN 'ute_empresa' = j.filtro THEN
						j.cod_filtro ELSE usuarios_telemetria.ute_empresa END)
				 )
				--	Obtenemos los valores de la tabla del JSON jleer
				FROM jsonb_populate_record(null::json_update_usuarios_telemetria, jleer) j
					WHERE usuarios_telemetria.ute_emp_cod = j.emp_cod
					 AND usuarios_telemetria.ute_nombre = j.nombre;
			
			--	Usuario actualizado?
			IF FOUND THEN
				bOk := true;
			END IF;
			
		ELSE
			--	token no válido, usuario no validado.
			SELECT ('{"cod_error":"401"}')::jsonb || jresultado ::jsonb into jresultado;
        END IF;
		
			--	Añadimos la variable bOk al JSON jresultado
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


-- Para hacer un insert hay que poner un emp_cod que exista en la tabla empresas
-- Para que funcione hay que poner un emp_cod y un nombre que existan en la tabla usuarios_telemetria
-- select * from actualiza_usuarios_telemetria('{"emp_cod": "69", "ctoken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6IjkyOTIyMzBiMzcwZjRjNzkzYzM0MzM1ODk5ZWRlYTAxNzYwNGYwZDIiLCJpYXQiOjE2NDkzNDU0MTN9.3_yp3tm7KVnt_m5K_KjPpEzYXPbaN73X9zp_xedSyjo", "nombre": "oooo", "nuevo_nombre": "ActualizaNombre", "pwd": "1234555", "auto_pwd": "false", "filtro": "ute_pdv", "cod_filtro": "36"}');
-- select * from usuarios_telemetria

--	Función que permitira modificar a un usuario existente de telemetria