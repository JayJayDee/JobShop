
express = require('express')
morgan = require('morgan')

validationMiddleware = require('./middlewares/validationMiddleware')
apiResponseMiddleware = require('./middlewares/apiResponseMiddleware')

ApiController = require('./controllers/apiController')
webConf = require('./configs/web')


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
app.use(validationMiddleware)  
app.use(apiResponseMiddleware)

# register controller routes
api.route(app) 

# listen http request
server.listen(webConf.httpPort)
if process.env.NODE_ENV == 'PROD' 
  envExpr = 'PROD'
else 
  envExpr = 'DEV'
console.log('taskshop listening on port ' + webConf.httpPort + ', env:' + envExpr)
