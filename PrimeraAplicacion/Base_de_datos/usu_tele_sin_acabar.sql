CREATE OR REPLACE FUNCTION public.crearusuariostelemetria(
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
	
	bOk := false;
	icod_error := 0;
	cError := '';
	
	-- Consultamos si el token es válido
	SELECT t.bOk INTO bOk FROM public.validar_token(jleer::jsonb) t;
	
	IF (bOk) THEN
		-- Tabla temporal
		CREATE TEMP TABLE IF NOT EXISTS ust_json(
			ctoken character varying,
			iusu_cod integer,
			cute_nombre character varying,
			cute_pwd character varying,
			bauto_pwd boolean,
			cute_filtro character varying,
			iute_cod_filtro integer
		);
		
		SELECT * INTO rRegistro
			FROM jsonb_populate_record(null::ust_json, jleer) AS j;
	
		IF rRegistro.bauto_pwd THEN
		-- generar contraseña
			Select cpwd, icod_error as e into rRegistro.cute_pwd, icod_error from public.generador_cadena_aleatoria(16);
				IF icod_error !=0 THEN
						RAISE EXCEPTION 'Error en la generación de la contraseña';
			END IF;
		END IF;
		
		--	CREACION DE USUARIOS DE TELEMETRIA
		INSERT INTO usuarios_telemetria (ute_nombre, ute_pwd, iute_filtro, iute_cod_filtro) 
				VALUES (rRegistro.cute_nombre, rRegistro.cute_pwd, rRegistro.iute_emp,
						rRegistro.iute_centro_padre, rRegistro.iute_centro, rRegistro.iute_pdv,
						rRegistro.iute_jefe_area, rRegistro.iute_ruta);
	
		IF FOUND THEN
			bOk := true;
			-- añdimos la variable bOk al JSON jresultado
			select ('{"bOk":"'||bOk||'"}')::jsonb into jresultado;
		END IF;
	END IF;
	
	EXCEPTION WHEN OTHERS THEN
		icod_error := -1;
		cerror := SQLERRM;
		jresultado :='[{"bOk":"'|| bOk
					  ||'", "cod_error":"'|| icod_error 
					  ||'", "msg_error":"'|| SQLERRM ||'"}]';
		END;
$BODY$;

ALTER FUNCTION public.crearusuariostelemetria(jsonb)
    OWNER TO postgres;
	
/*  SELECT * FROM public.crearusuariostelemetria('{
	"ute_nombre":"usu_telemetria",
	"ute_pwd":"qwer",
	"auto_pwd":"false",
	"ute_centro_padre":"2",
	"ute_centro":"",
	"ute_pdv":"",
	"ute_jefe_area":"",
	"ute_ruta":"",
	"ute_empresa":"",
	"ust_token":"7887186b33749971de515859532def15f4b210eb"}')*/
	