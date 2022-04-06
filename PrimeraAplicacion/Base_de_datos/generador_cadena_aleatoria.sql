-- FUNCTION: public.genera_pwd(integer)

-- DROP FUNCTION IF EXISTS public.generador_Cadena_Aleatoria(integer);
-- Función que crea un contraseña alfanumérica de forma aleatoria 
-- Con mayúsculas y minúsculas
-- de una longitud indicada en el parametro iCount
CREATE OR REPLACE FUNCTION public.generador_Cadena_Aleatoria(
	IN iCount integer,
	OUT cpwd character varying,
	OUT icoderror integer,
	OUT cerror character varying)
    RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	iAleat integer;

BEGIN
	
	cpwd := '';
	-- ij := 0;
	cerror :='';
	iAleat := 0;
	
	-- en ascii primero van los digitos
	-- luego las mayúsculas 
	-- y después las minúsculas
	-- entre medias hay otras caracteres
	
	-- de 0 a 9 digitos
	-- de 10 a 34 alfabeto mayúsculas
	-- de 35 a 69 alfabeto minúsculas
	-- iCount := iCount -1 ;
	for ij in 1..iCount
		LOOP
		iAleat :=  round(random() * 59) :: integer;
		
		-- añadimos el salto
		CASE
			WHEN iAleat >= 35 THEN
				iAleat :=  iAleat + ascii('a') - 35;
			WHEN iAleat >= 10 THEN
				iAleat :=  iAleat + ascii('A') - 10;
			ELSE
				iAleat :=  iAleat + ascii('0');
		END CASE;
		
		-- obtenemos el caracter que representa iAleat
		-- y lo concatenamos al pwd
		cpwd := cpwd || chr(iAleat);
		
	END LOOP;

	EXCEPTION WHEN OTHERS THEN
		iCoderror := -1;
		cError := SQLERRM;
		END;
$BODY$;

ALTER FUNCTION public.generador_Cadena_Aleatoria(integer)
    OWNER TO postgres;
	
select * from generador_Cadena_Aleatoria(16);