CREATE OR REPLACE FUNCTION public.insertarToken(
	ctoken character varying,
	OUT ok boolean,
	OUT coderror integer,
	OUT error character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

BEGIN
	ok :=false;
	coderror :=0;
	error := '';
   INSERT INTO usuarios_token (ust_token) VALUES (ctoken) RETURNING ust_cod into coderror;

	EXCEPTION WHEN OTHERS THEN
		coderror := -1;
		error := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.insertarToken(character varying)
    OWNER TO postgres;