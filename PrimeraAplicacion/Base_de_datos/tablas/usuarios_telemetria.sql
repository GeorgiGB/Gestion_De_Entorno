-- Table: public.usuarios_telemetria

-- DROP TABLE IF EXISTS public.usuarios_telemetria;

CREATE TABLE IF NOT EXISTS public.usuarios_telemetria
(
    ute_cod integer NOT NULL DEFAULT nextval('usuarios_aplicacion_usa_cod_seq'::regclass),
    ute_usu_cod integer,
    ute_nombre character varying(30) COLLATE pg_catalog."default" NOT NULL,
    ute_pwd character varying(255) COLLATE pg_catalog."default" NOT NULL,
    ute_empresa integer NOT NULL DEFAULT 0,
    ute_centro_padre integer,
    ute_centro integer,
    ute_pdv integer,
    ute_jefe_area integer,
    ute_ruta integer,
    CONSTRAINT usuarios_telemetria_pkey PRIMARY KEY (ute_cod, ute_empresa),
    CONSTRAINT fk_usuarios_telemetria_empresas FOREIGN KEY (ute_empresa)
        REFERENCES public.empresas (emp_cod) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_usuarios_telemetria_usuarios FOREIGN KEY (ute_usu_cod)
        REFERENCES public.usuarios (usu_cod) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.usuarios_telemetria
    OWNER to postgres;

GRANT ALL ON TABLE public.usuarios_telemetria TO postgres;