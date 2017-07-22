
class ApiController 

  constructor: (repository) ->
    @repo = repository

  route: (expressInst) =>
    expressInst.post('/job', (req, res, next) =>
      @addJob(req, res, next)
    )

  addJob: (req, res, next) =>
    jobPayload = req.body

    if JSON.stringify(jobPayload) == '{}'
      return next(
        err: 'INVALID_PARAM'
        data: 'jobPayload must be supplied with body/json'
      )

    res.sendApiSuccess({}) 


instance = null 
module.exports = (repository) ->
  if instance == null 
    instance = new ApiController(repository)
  return instance