CREATE TEMP TABLE IF NOT EXISTS ust_json(
		ust_token character varying,
		ute_emp_cod integer,
		ute_nombre character varying,
		ute_pwd character varying,
		auto_pwd boolean,
		ute_nombre_filtro character varying,
		ute_cod_filtro integer
	);

SELECT * INTO rRegistro
		FROM jsonb_populate_record(null::ust_json, jleer) AS j;

UPDATE usuarios_telemetria set (
    ute_centro_padre, ute_centro, ute_pdv, ute_jefe_area, ute_ruta, ute_empresa) = 
    coalesce(j.jleer, usuarios_telemetria.ute_centro_padre),
    coalesce(j.jleer, usuarios_telemetria.ute_centro),
    coalesce(j.jleer, usuarios_telemetria.ute_pdv),
    coalesce(j.jleer, usuarios_telemetria.ute_jefe_area),
    coalesce(j.jleer, usuarios_telemetria.ute_ruta),
    coalesce(j.jleer, usuarios_telemetria.ute_empresa),
        FROM jsonb_populate_record(null::ust_json,jleer) j

        WHERE usuarios_telemetria.ute_nombre = j.ute_nombre AND usuarios_telemetria.ute_emp_cod = j.ute_emp_cod
            RETURNING usuarios_telemetria.ute_nombre into coderror;