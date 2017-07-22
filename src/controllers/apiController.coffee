
class ApiController 

  constructor: (repository) ->
    @repo = repository

  route: (expressInst) =>
    expressInst.post('/job', (req, res, next) =>
      @addJob(req, res, next)
    )

  addJob: (req, res, next) =>
    res.sendApiSuccess({}) 


instance = null 
module.exports = (repository) ->
  if instance == null 
    instance = new ApiController(repository)
  return instance