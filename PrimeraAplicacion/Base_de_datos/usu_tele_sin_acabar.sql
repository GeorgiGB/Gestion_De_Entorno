CREATE OR REPLACE FUNCTION public.crearusuariostelemetria(
	ctoken character varying,
	iusu_cod integer,
	cute_nombre character varying,
	cute_pwd character varying,
	bauto_pwd boolean,
	cute_filtro character varying,
	iute_cod_filtro integer,
	OUT bok boolean,
	OUT iusu_cod integer,
	OUT icoderror integer,
	OUT cerror character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

BEGIN
	
	bok := false;
	iusu_cod := -1;
	icoderror := 0;
	cerror := '';
	if bauto_pwd then 
	-- generar contraseña
		Select cpwd, icoderror as e into cemp_pwd, icod_error from public.generador_cadena_aleatoria(16);
			IF icod_error !=0 THEN
					RAISE EXCEPTION 'Error en la generación de la contraseña';
			END IF;
	END IF;
	
	
	IF EXISTS (SELECT bok FROM validar_token(ctoken, iusu_cod)) THEN
		INSERT INTO usuarios_telemetria (ute_nombre, ute_pwd, iute_filtro, iute_cod_filtro) 
				VALUES (cute_nombre, cute_pwd, iute_emp,
						iute_centro_padre, iute_centro, iute_pdv,
						iute_jefe_area, iute_ruta);
	END IF;	
	
	IF FOUND THEN
		bok := true;
	END IF;

	EXCEPTION WHEN OTHERS THEN
		icoderror := -1;
		cerror := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.crearusuariostelemetria(character varying,
											  character varying,
											  integer, integer,
											  integer, integer,
											  integer, integer)
    OWNER TO postgres;