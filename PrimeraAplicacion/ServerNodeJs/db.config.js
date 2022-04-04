// Conexion con la base de datos
//------------------------------
const { Pool } = require('pg')

// Parte de la base de datos
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'Empresa',
    password: 'caslab',
    port: 5432,
  });

  module.exports = pool;