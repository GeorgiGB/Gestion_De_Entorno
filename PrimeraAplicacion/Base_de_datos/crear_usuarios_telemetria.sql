-- FUNCTION: public.crear_usuarios_telemetria(jsonb)

-- DROP FUNCTION IF EXISTS public.crear_usuarios_telemetria(jsonb);

CREATE OR REPLACE FUNCTION public.crear_usuarios_telemetria(
jleer jsonb,
OUT jresultado jsonb)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
rRegistro record;

rValues record;

bOk boolean;
iemp_cod integer;
icod_error integer;
cError character varying;

BEGIN

bOk := false;
icod_error := 0;
cError := '';
jresultado := '[]';

-- Consultamos si el token es válido
SELECT t.bOk INTO bOk FROM public.validar_token(jleer::jsonb) t;

IF (bOk) THEN
-- Tabla temporal
CREATE TEMP TABLE IF NOT EXISTS ust_json(
ust_token character varying,
ute_emp_cod integer,
ute_nombre character varying,
ute_pwd character varying,
auto_pwd boolean,
ute_filtro character varying,
ute_cod_filtro integer
);

-- select ('{"bOk":"'||bOk||'"}')::jsonb || jresultado ::jsonb into jresultado;

-- obtenemos los valores del JSON enviados por el servidor
SELECT * INTO rRegistro
FROM jsonb_populate_record(null::ust_json, jleer) AS j;

SELECT
ute_centro_padre,
ute_centro,
ute_pdv,
ute_jefe_area,
ute_ruta,
ute_empresa
INTO rValues
from usuarios_telemetria
WHERE ute_emp_cod = rRegistro.ute_emp_cod;

case
	WHEN rRegistro.ute_filtro = 'ute_pdv' THEN
		rValues.ute_pdv = rRegistro.ute_cod_filtro;
	else
end CASE;


update usuarios_telemetria
set
ute_centro_padre = rValues.ute_centro_padre,
ute_centro = rValues.ute_centro,
ute_pdv = rValues.ute_pdv,
ute_jefe_area = rValues.ute_jefe_area,
ute_ruta = rValues.ute_ruta,
ute_empresa = rRegistro.ute_emp_cod
WHERE ute_emp_cod = rRegistro.ute_emp_cod;


/*IF rRegistro.bauto_pwd THEN
-- generar contraseña
Select cpwd, icod_error as e into rRegistro.cute_pwd, icod_error from public.generador_cadena_aleatoria(16);
IF icod_error !=0 THEN
RAISE EXCEPTION 'Error en la generación de la contraseña';
END IF;
END IF;

-- CREACION DE USUARIOS DE TELEMETRIA
INSERT INTO usuarios_telemetria (ute_nombre, ute_pwd, iute_filtro, iute_cod_filtro)
VALUES (rRegistro.cute_nombre, rRegistro.cute_pwd, rRegistro.iute_emp,
rRegistro.iute_centro_padre, rRegistro.iute_centro, rRegistro.iute_pdv,
rRegistro.iute_jefe_area, rRegistro.iute_ruta);
*/
IF FOUND THEN
bOk := true;
-- añdimos la variable bOk al JSON jresultado
select ('{"bOk":"'||rRegistro.ute_filtro||'"}')::jsonb || jresultado ::jsonb into jresultado;
END IF;
END IF;
-- select ('{"bOk":"'||bOk||'"}')::jsonb into jresultado;

EXCEPTION WHEN OTHERS THEN
icod_error := -1;
cerror := SQLERRM;
jresultado :='[{"bOk":"'|| bOk
 ||'", "cod_error":"'|| icod_error
 ||'", "msg_error":"'|| SQLERRM ||'"}]';
END;
$BODY$;

ALTER FUNCTION public.crear_usuarios_telemetria(jsonb)
    OWNER TO postgres;

-- select * from crear_usuarios_telemetria('{"ust_token": "7887186b33749971de515859532def15f4b210eb", "ute_emp_cod": "60", "ute_nombre": "Jo", "ute_pwd": "45678","bauto_pwd": "false", "ute_filtro": "ute_pdv", "ute_cod_filtro": "21"}');
-- select * from usuarios_telemetria