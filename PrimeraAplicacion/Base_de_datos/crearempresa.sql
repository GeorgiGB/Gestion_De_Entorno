-- FUNCTION: public.crearempresa(character varying, character varying)

-- DROP FUNCTION IF EXISTS public.crearempresa(character varying, character varying);

CREATE OR REPLACE FUNCTION public.crearempresa(
	cemp_nombre character varying,
	cemp_pwd character varying,
	bauto_pwd boolean,
	OUT bok boolean,
	OUT iemp_cod integer,
	OUT icoderror integer,
	OUT cerror character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

BEGIN
	
	bok := false;
	iEmp_cod := -1;
	iCoderror := 0;
	cError := '';
	if bauto_pwd then 
	-- generar contraseña
	END IF;
	
	INSERT INTO empresas (emp_nombre, emp_pwd) VALUES (cemp_nombre, cemp_pwd) RETURNING emp_cod into iEmp_cod;
   
	IF FOUND THEN
		bOk := true;
	END IF;

	EXCEPTION WHEN OTHERS THEN
		iCoderror := -1;
		cError := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.crearempresa(character varying, character varying)
    OWNER TO postgres;