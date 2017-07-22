
redisConf = 

  dev: 
    host: '127.0.0.1' 
    port: 6379

    uniqueGeneratorKey: 'TASKSHOP_UNIQUE_JOB_ID'
    jobQueueKey: 'TASKSHOP_JOB_QUEUE'
    jobMapKey: 'TASKSHOP_JOB_MAP' 
    failLogListKey: 'TASHSHOP_FAIL_LOG_LIST' 

  prod: 
    host: '127.0.0.1'
    port: 6379 

    uniqueGeneratorKey: 'TASKSHOP_UNIQUE_JOB_ID'
    jobQueueKey: 'TASKSHOP_JOB_QUEUE'
    jobMapKey: 'TASKSHOP_JOB_MAP' 
    failLogListKey: 'TASHSHOP_FAIL_LOG_LIST'

exportConf = null
if process.env.NODE_ENV == 'PROD'
  exportConf = redisConf.prod 
else 
  exportConf = redisConf.dev
module.exports = exportConf 