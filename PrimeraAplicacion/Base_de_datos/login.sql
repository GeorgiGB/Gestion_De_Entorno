-- FUNCTION: public.login(character varying, character varying)

-- DROP FUNCTION IF EXISTS public.login(character varying, character varying);

CREATE OR REPLACE FUNCTION public.login(
	cun character varying,
	cup character varying,
	OUT bok boolean,
	OUT iusu_cod integer,
	OUT icoderror integer,
	OUT cerror character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE nombre character varying;

BEGIN
	
	bok := false;
	iusu_cod := -1;
	icoderror := 0;
	cerror := '';

	SELECT usu_cod into iusu_cod from usuarios where usu_nombre = cun and usu_pwd = cup;
   
	IF FOUND THEN
		bok := true;
	END IF;

	EXCEPTION WHEN OTHERS THEN
		icoderror := -1;
		cerror := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.login(character varying, character varying)
    OWNER TO postgres;
