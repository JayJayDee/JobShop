
util = require('util')

env = process.env.NODE_ENV

errorMiddleware = (err, req, res, next) -> 
  type = _identifyError(err) 

  if type == 'system'
    log.e('UNEXPECTED ERROR FIRED')
    log.e(err)
    if env == 'PROD' 
      return res.render('error', 
        error: null 
        message: 'internal server error'
      )
    else 
      throw err 

  return _sendApiError(err, req, res) 
  
# identify error type.
_identifyError = (err) ->
  if err.err? and util.isObject(err) == true
    return 'defined'
  return 'system'

# api error processes
_sendApiError = (err, req, res) -> 
  statusCode = 400 
  errorPayload = 
    success: false 
    data: null
    error: null

  if err.err == 'UNAUTHORIZED' 
    statusCode = 401   

  errorPayload.error = err.err 
  errorPayload.data = err.data
  res.status(statusCode).send(errorPayload) 

module.exports = errorMiddleware