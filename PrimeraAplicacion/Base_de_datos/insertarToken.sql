-- FUNCTION: public.insertartoken(character varying, integer)

-- DROP FUNCTION IF EXISTS public.insertartoken(character varying, integer);

CREATE OR REPLACE FUNCTION public.insertartoken(
	ctoken character varying,
	iusu_cod integer,
	OUT bok boolean,
	OUT coderror integer,
	OUT error character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	iust_cod integer;

BEGIN
	bok :=false;
	coderror :=0;
	error := '';
	iust_cod := -1;
	
   INSERT INTO usuarios_token (ust_token, ust_usuario, ust_activo) VALUES (ctoken, iusu_cod, 'true') RETURNING ust_cod into iust_cod;
	
	IF FOUND then
		bok := true;
	END IF;
	
	EXCEPTION WHEN OTHERS THEN
		coderror := -1;
		error := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.insertartoken(character varying, integer)
    OWNER TO postgres;
