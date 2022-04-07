-- FUNCTION: public.validar_token(character varying, integer)

-- DROP FUNCTION IF EXISTS public.validar_token(character varying, integer);

CREATE OR REPLACE FUNCTION public.validar_token(
	ctoken character varying,
	iusu_cod integer,
	OUT tok boolean,
	OUT coderror integer,
	OUT cerror character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

BEGIN
	tok :=false;
	coderror :=0;
	cerror := '';
	
	
	SELECT ust_activo INTO tok
		FROM usuarios_token 
			WHERE ctoken = ust_token 
				AND iusu_cod = ust_usuario 
				AND ust_activo;

	--IF FOUND then
	--	tok := true;
	--END IF;
	
	EXCEPTION WHEN OTHERS THEN
		coderror := -1;
		cerror := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.validar_token(character varying, integer)
    OWNER TO postgres;
	
-- SELECT * FROM validar_token('7887186b33749971de515859532def15f4b210eb', 0)