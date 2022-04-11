SELECT 
	u.usu_cod,
	ut.ust_cod,
	ut.ust_usuario
FROM
	usuarios u
LEFT JOIN usuarios_token ut ON ut.ust_usuario = u.usu_cod order by u.usu_cod