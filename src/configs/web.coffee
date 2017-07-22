
webConf = 

  dev: 
    httpPort: 5000 
    accessLog: true 
    accessLogFormat: ':method :url :status :res[content-length] - :response-time ms'

  prod: 
    httpPort: 5000 
    accessLog: false
    accessLogFormat: ':method :url :status :res[content-length] - :response-time ms'


exportConf = null 
if process.env.NODE_ENV == 'PROD'
  exportConf = webConf.prod
else 
  exportConf = webConf.dev 
module.exports = exportConf 