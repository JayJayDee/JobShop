
brokerConf = 

  dev:
    retryWhenFail: 3

  prod:
    retryWhenFail: 3


exportConf = null
if process.env.NODE_ENV == 'PROD'
  exportConf = brokerConf.prod
else 
  exportConf = brokerConf.dev 
module.exports = exportConf