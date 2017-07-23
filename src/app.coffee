
express = require('express')
morgan = require('morgan')
bodyParser = require('body-parser')

validationMiddleware = require('./middlewares/validationMiddleware')
apiResponseMiddleware = require('./middlewares/apiResponseMiddleware')
errorMiddleware = require('./middlewares/errorMiddleware')

ApiController = require('./controllers/apiController')
webConf = require('./configs/web')
appLogger = require('./libs/appLogger')

global.log = appLogger

# express initialization
app = express() 
server = require('http').createServer(app)
envExpr = null 

# inject repository to controllers
Repository = require('./repositories/redisRepository') # can change another repos
api = ApiController(Repository())

# register middlewares by web config (see configs/web.coffee)
if webConf.accessLog == true 
  morganInst = morgan(webConf.accessLogFormat) 
  app.use(morganInst)

# register common middlewares 
app.use(bodyParser.urlencoded(
  extended: true
))
app.use(bodyParser.json())
app.use(validationMiddleware)  
app.use(apiResponseMiddleware)

# register controller routes
api.route(app) 

# register exception processing middlewares
app.use(errorMiddleware)

# listen http request
server.listen(webConf.httpPort)
if process.env.NODE_ENV == 'PROD' 
  envExpr = 'PROD'
else 
  envExpr = 'DEV'
log.i('taskshop listening on port ' + webConf.httpPort + ', env:' + envExpr)
