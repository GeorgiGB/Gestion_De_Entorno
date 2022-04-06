CREATE OR REPLACE FUNCTION public.crearusuariostelemetria(
	cute_nombre character varying,
	cute_pwd character varying,
	bauto_pwd boolean,
	iute_emp integer,
	iute_centro integer,
	iute_centro_padre integer,
	iute_pdv integer,
	iute_jefe_area integer,
	iute_ruta integer,
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
	
	bOk := false;
	iUsu_cod := -1;
	iCoderror := 0;
	cError := '';
	if bauto_pwd then 
	-- generar contraseña
	
	END IF;

	INSERT INTO usuarios_telemetria (ute_nombre, ute_pwd, ute_empresa, ute_centro_padre,
									ute_centro, ute_pdv, ute_jefe_area, ute_ruta) 
			VALUES (cute_nombre, cute_pwd, iute_emp,
					iute_centro_padre, iute_centro, iute_pdv,
					iute_jefe_area, iute_ruta);
					
			RETURNING emp_cod into cerror;
	IF FOUND THEN
		bOk := true;
	END IF;

	EXCEPTION WHEN OTHERS THEN
		iCoderror := -1;
		cError := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.crearusuariostelemetria(character varying,
											  character varying,
											  integer, integer,
											  integer, integer,
											  integer, integer)
    OWNER TO postgres;