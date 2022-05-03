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

--	Para hacer un insert hay que poner un emp_cod que exista en la tabla empresas
--	Si exite en la tabla un nombre con el mismo ust_emp_cod HAY QUE CAMBIAR EL NOMBRE DE "nombre"
--	select * from crear_usuarios_telemetria('{"emp_cod": "41", "ctoken": "a", "nombre": "usunuevotele", "pwd": "1111111", "auto_pwd": "false", "filtro": "ute_ruta", "cod_filtro": "37"}');
--	select * from usuarios_telemetria


--	Función de creación de usuarios de telemetria
--	el cual solo podra acceder un usuario principal con un token activo
--	a la hora de la creación del usuario de telemetria
--	se tiene que relacionar con una empresa de forma obligatoria
	
    DECLARE
        bOk boolean;
        iemp_cod integer;
        icod_error integer;
        cError character varying;
        statusHTML integer;

    BEGIN
        bOk := false;
        icod_error := 0;
        cError := '';
        jresultado := '[]';
        statusHTML := 200;
		
        -- Consultamos si el token es válido
        SELECT t.bok INTO bOk
        	FROM public.validar_token(jleer::jsonb) t;
			
        IF bOk THEN
			-- Tabla temporal para recoger los valores del JSON jleer
			CREATE TEMP TABLE IF NOT EXISTS json_insert_usuarios_telemetria(
				ctoken character varying,
				emp_cod integer,
				nombre character varying,
				pwd character varying, 
				auto_pwd boolean, -- indica si la contraseña se autogenerará
				filtro character varying, -- nombre delcampo de filtro donde se insertará
				cod_filtro integer -- el código de filtro a inssertar
			);
            
            --	Realizamos el INSERT en usuarios_telemetria desde los valores de la tabla temporal
			--	de forma que si algún campo de los que se encuentra
			--	en el CASE WHEN coincide con el fitro contenido en j.filtro
            --	se le assignará el valor contenido en j.cod_filtro
			INSERT INTO usuarios_telemetria
				(ute_emp_cod, ute_nombre, ute_pwd,
				 ute_centro_padre, ute_centro, ute_pdv,
				 ute_jefe_area, ute_ruta) 
				SELECT 
					j.emp_cod, j.nombre,
					--	Contraseña autogenerada
					(CASE WHEN j.auto_pwd THEN
					 	(SELECT cpwd FROM public.generador_cadena_aleatoria(16))
					 		ELSE j.pwd END),
							
					--	A partir de aquí se insertará el valor de j.cod_filtro
					--	en el campo que en el CASE coincida con j.filtro
					(CASE WHEN 'ute_centro_padre' = j.filtro THEN
						j.cod_filtro ELSE null END),
					(CASE WHEN 'ute_centro' = j.filtro THEN
						j.cod_filtro ELSE null END),
					(CASE WHEN 'ute_pdv' = j.filtro THEN
						j.cod_filtro ELSE null END),
					(CASE WHEN 'ute_jefe_area' = j.filtro THEN
						j.cod_filtro ELSE null END),
					(CASE WHEN 'ute_ruta' = j.filtro THEN
						j.cod_filtro ELSE null END)
						
				--	Obtenemos los valores de la tabla del JSON jleer
				FROM jsonb_populate_record(null::json_insert_usuarios_telemetria, jleer) j;
			
			--	Usuario insertado?
			IF FOUND THEN
				bOk := true;
			END IF;
			
		ELSE
			--	Token no válido, usuario no validado.
			statusHTML = 401;
        END IF;
		
			--	Añadimos la variable bOk i statusHTML al JSON jresultado
			SELECT ('{"status":"' ||statusHTML 
					||'", "cod_error":"' || icod_error || '"}')::jsonb || jresultado::jsonb into jresultado;

		EXCEPTION
			--	Códigos de error -> https://www.postgresql.org/docs/current/errcodes-appendix.html
			WHEN OTHERS THEN
				cError := SQLERRM;
                statusHTML := 500;
				CASE
					 --	El '23505' equivale a unique_violation
					 --	si ponemos directamente unique_violation en lugar de '23505'
					 --	da el siguiente error "ERROR:  no existe la columna «unique_violation»"
					WHEN SQLSTATE = '23505' THEN
                        statusHTML :=200;
						icod_error := -2;
					ELSE
						icod_error := -1;		
				END CASE;
				
				SELECT ('{"status":"' || statusHTML
					|| '", "cod_error":"' || icod_error
					|| '", "msg_error":"' || cError || '"}')::jsonb
					|| jresultado::jsonb into jresultado;
        END;
    
$BODY$;

ALTER FUNCTION public.crear_usuarios_telemetria(jsonb)
    OWNER TO postgres;