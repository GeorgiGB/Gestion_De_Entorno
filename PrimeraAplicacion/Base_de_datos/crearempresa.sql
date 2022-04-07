-- FUNCTION: public.crearempresa(character varying, character varying, boolean, integer)

-- DROP FUNCTION IF EXISTS public.crearempresa(character varying, character varying, boolean, integer);

CREATE OR REPLACE FUNCTION public.crearempresa(
	ctoken character varying,
	cemp_nombre character varying,
	cemp_pwd character varying,
	bauto_pwd boolean,
	iusu_cod integer,
	OUT bok boolean,
	OUT iemp_cod integer,
	OUT icod_error integer,
	OUT cerror character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

BEGIN
	
	bok := false;
	iemp_cod := -1;
	icod_error := 0;
	cerror := '';
	
	if bauto_pwd then 
	-- generar contraseña
		Select cpwd, icoderror as e into cemp_pwd, icod_error from public.generador_cadena_aleatoria(16);
		IF icod_error !=0 THEN
				RAISE EXCEPTION 'Error en la generación de la contraseña';
		END IF;
	END IF;
	
	IF EXISTS (SELECT ust_token FROM usuarios_token VALUES (ctoken)) THEN
	
		INSERT INTO empresas (emp_nombre, emp_pwd, emp_usu_cod) 
		VALUES (cemp_nombre, cemp_pwd, iusu_cod) 
		RETURNING emp_cod into iemp_cod;
   
   	END IF;
	
	IF FOUND THEN
		bok := true;
	END IF;

	EXCEPTION WHEN OTHERS THEN
		icod_error := -1;
		cerror := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.crearempresa(character varying, character varying, boolean, integer)
    OWNER TO postgres;
