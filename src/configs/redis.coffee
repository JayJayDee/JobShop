
redisConf = 

  dev: 
    host: '127.0.0.1' 
    port: 6379

  prod: 
    host: '127.0.0.1'
    port: 6379 

exportConf = null
if process.env.NODE_ENV == 'PROD'
  exportConf = redisConf.prod 
else 
  exportConf = redisConf.dev
module.exports = exportConf 