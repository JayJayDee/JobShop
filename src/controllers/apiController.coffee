
class ApiController 

  constructor: (repository) ->
    @repo = repository

  route: (expressInst) =>
    expressInst.post('/job', (req, res, next) =>
      @addJob(req, res, next)
    )
    expressInst.get('/job', (req, res, next) =>
      @getJob(req, res, next)
    )

  # POST /job API 
  addJob: (req, res, next) =>
    jobPayload = req.body

    if JSON.stringify(jobPayload) == '{}'
      return next(
        err: 'INVALID_PARAM'
        data: 'jobPayload must be supplied with body/json'
      )

    @repo.enqueueJob(jobPayload)
    .then((resp) =>
      res.sendApiSuccess(resp)
    )
    .catch((err) =>
      return next(err)
    )

  getJob: (req, res, next) =>
    @repo.dequeueJob()
    .then((resp) =>
      res.sendApiSuccess(resp)
    )
    .catch((err) =>
      return next(err)
    )

instance = null 
module.exports = (repository) ->
  if instance == null 
    instance = new ApiController(repository)
  return instance