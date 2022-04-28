-- Table: public.empresas

-- DROP TABLE IF EXISTS public.empresas;

CREATE TABLE IF NOT EXISTS public.empresas
(
    emp_cod integer NOT NULL DEFAULT nextval('empresas_emp_cod_seq'::regclass),
    emp_nombre character varying(30) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT empresas_pkey PRIMARY KEY (emp_cod),
    CONSTRAINT empresas_nombre_ukey UNIQUE (emp_nombre)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.empresas
    OWNER to postgres;
	
/* select * from public.crearempresa('{
"emp_nombre": "funcioncrearempresa",
"emp_pwd":"4321",
"auto_pwd":"true", 
"ust_token":"7887186b33749971de515859532def15f4b210eb"}')

*/


