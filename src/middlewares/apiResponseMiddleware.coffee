
apiRespMiddleware = (req, res, next) ->
  res.sendApiSuccess = (data, options = null) ->
    res.send(
      success: true 
      data: data 
      error: null 
    )
  next() 

module.exports = apiRespMiddleware