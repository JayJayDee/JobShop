

mysqlConf = 

  dev: 
    host: '127.0.0.1' 
    port: 3306 
    user: 'root'
    password: 'hands'
    database: 'taskshop_dev'
    connectionLimit: 10

  prod: 
    host: '127.0.0.1'
    port: 3306
    user: 'root'
    password: 'hu77lzg5'
    database: 'taskshop_prod'
    connectionLimit: 10 

exportConf = null
if process.env.NODE_ENV == 'PROD'
  exportConf = mysqlConf.prod 
else 
  exportConf = mysqlConf.dev
module.exports = exportConf 