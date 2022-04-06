CREATE OR REPLACE FUNCTION public.login(
	in un character varying,
	in up character varying,
	OUT ok boolean,
	OUT coderror integer,
	OUT error character varying)
	RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE nombre character varying;

BEGIN
	ok :=false;
	coderror :=0;
	error := '';
   SELECT usu_nombre into nombre from usuarios where usu_nombre = un and 
   usu_pwd = up;
   
	IF FOUND THEN
	ok = true;
	END IF;

	EXCEPTION WHEN OTHERS THEN
		coderror := -1;
		error := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.login(character varying, character varying)
    OWNER TO postgres;