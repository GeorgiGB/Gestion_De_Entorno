-- SELECT * FROM usuarios_token;

-- SELECT * FROM usuarios_telemetria;

-- SELECT * FROM usuarios;

-- SELECT * FROM empresas;

/*  select * from public.crearempresa('{
	"ute_nombre":"usu_telemetria",
	"ute_pwd":"qwer",
	"auto_pwd":"false",
	"ute_centro_padre":"2",
	"ute_centro":"",
	"ute_pdv":"",
	"ute_jefe_area":"",
	"ute_ruta":"",
	"ute_empresa":"",
	"ust_token":"7887186b33749971de515859532def15f4b210eb"}')*/
	
SELECT * FROM public.crear_usuarios_telemetria('{
	"ute_emp_cod":"60",
	"ute_nombre":"pruebausuariostelemetria",
	"ute_pwd":"",
	"ute_auto_pwd":"true",
	"ute_centro_padre":"",
	"ute_centro":"2",
	"ute_pdv":"",
	"ute_jefe_area":"",
	"ute_ruta":"",
	"ute_empresa":"0",
	"ust_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Ijc4ODcxODZiMzM3NDk5NzFkZTUxNTg1OTUzMmRlZjE1ZjRiMjEwZWIiLCJpYXQiOjE2NDkzNDUyMzV9.olI-c3Zzl-QsCIgSDmhJ5QY71O7eL2d1mhDOrQSkP2k"}')
