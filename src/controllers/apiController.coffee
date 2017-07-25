
class ApiController 

  constructor: (repository) ->
    @repo = repository

  # map controller methods to rest api endpoints 
  route: (expressInst) =>
    expressInst.post('/job/push', (req, res, next) =>
      @pushJob(req, res, next)
    )
    expressInst.post('/job/pop', (req, res, next) =>
      @popJob(req, res, next)
    )
    expressInst.put('/job/:job_id/:result', (req, res, next) =>
      @saveJobResult(req, res, next)
    )

  # POST /job/push API 
  # add a new job payload 
  pushJob: (req, res, next) =>
    jobPayload = req.body
    if JSON.stringify(jobPayload) == '{}'
      return next(
        err: 'INVALID_PARAM'
        data: 'jobPayload must be supplied with body/json'
      )

    @repo.addJob(jobPayload)
    .then((resp) =>
      res.sendApiSuccess(resp)
    )
    .catch((err) =>
      return next(err)
    )
  

  # POST /job/pop API 
  # get a available job 
  popJob: (req, res, next) =>
    @repo.fetchJobTodo()
    .then((resp) =>
      res.sendApiSuccess(resp)
    )
    .catch((err) =>
      return next(err)
    )
  
  # PUT /job/:job_id/:result API
  # save a job result 
  saveJobResult: (req, res, next) =>
    req.validateParam(
      url: 
        job_id: []
        result: [] 
    )
    
    jobId = req.vparams.job_id 
    result = req.vparams.result 

    if !(result == 'success' or result == 'fail')
      return next(
        err: 'INVALID_PARAM'
        data: 'result must be success or fail'
      )    

    if result == 'success' 
      @repo.makeJobSuccess(jobId)
      .then((resp) =>
        res.sendApiSuccess(resp)
      )
      .catch((err) =>
        return next(err)       
      )
    
    else if result == 'fail' 
      @repo.makeJobFail(jobId) 
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