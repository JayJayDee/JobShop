
redisConf = 

  dev: 
    host: '127.0.0.1' 
    port: 6379

    uniqueGeneratorKey: 'UNIQUE_JOB_ID'



  prod: 
    host: '127.0.0.1'
    port: 6379 

    uniqueGeneratorKey: 'UNIQUE_JOB_ID'

exportConf = null
if process.env.NODE_ENV == 'PROD'
  exportConf = redisConf.prod 
else 
  exportConf = redisConf.dev
module.exports = exportConf 