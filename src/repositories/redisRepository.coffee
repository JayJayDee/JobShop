
crypto = require('crypto')
redis = require('redis')

redisConf = require('../configs/redis')
brokerConf = require('../configs/broker') 

# base CRUD implementation for REDIS

# you may want to implement this with MySQL, 
# just do it! just check out method names.
class RedisRepository 

  constructor: () ->
    @client = @_initRedisInst() 

  # initialize redis client connection
  _initRedisInst: () =>
    redisInst = redis.createClient(redisConf)
    redisInst.on('ready', () =>
      log.i('redis ready')
    )
    redisInst.on('connect', () =>
      log.i('redis connected ' + redisConf.host)
    )

  # create new unique job id 
  # in this Repository(redis), using redis INCR command
  createJobId: () =>
    incrKey = redisConf.uniqueGeneratorKey
    return new Promise((resolve, reject) =>
      @client.incr(incrKey, (err, newIncrId) =>
        if err != null
          return reject(err)
        now = Date.now()
        rawJobId = newIncrId.toString() + now.toString()
        jobId = crypto.createHash('sha256').update(rawJobId).digest('hex')
        resolve(jobId)
      )
    )

  # enqueue new job with payload, 
  # returns with unique job ID 
  addJob: (jobPayload) =>
    queueKey = redisConf.jobQueueKey
    jobMapKey = redisConf.jobMapKey
    return new Promise((resolve, reject) =>
      @createJobId()
      .then((jobId) =>
        stringified = JSON.stringify(jobPayload)
        @client.hmset(jobMapKey, jobId, stringified, (err, resp) =>
          if err != null 
            return reject(err) 
          
          @client.rpush(queueKey, jobId, (err, resp) =>
            if err != null 
              return reject(err) 
            
            retPayload =
              job_id: jobId
              payload: jobPayload
            resolve(retPayload) 
          ) 
        )
      )
      .catch((err) =>
        reject(err) 
      )
    )

  # get one job to do.
  fetchJobTodo: () =>
    queueKey = redisConf.jobQueueKey
    jobMapKey = redisConf.jobMapKey
    procMapKey = redisConf.jobProcMapKey

    return new Promise((resolve, reject) =>
      @client.lpop(queueKey, (err, jobId) =>
        if err != null 
          return reject(err)
        if jobId == null 
          return resolve(null) 

        @client.hmset(procMapKey, jobId, 1, (err, resp) =>
          if err != null 
            return reject(err) 
          @client.hmget(jobMapKey, jobId, (err, jobPayload) =>
            if err != null 
              return reject(err) 
            resolve(
              job_id: jobId
              payload: JSON.parse(jobPayload) 
            )
          )
        )
      )
    )

  # make job to success 
  makeJobSuccess: (jobId) =>
    jobMapKey = redisConf.jobMapKey
    procMapKey = redisConf.jobProcMapKey
    return new Promise((resolve, reject) =>
      @client.hdel(procMapKey, jobId, (err, resp) =>
        if err != null 
          return reject(err)
        if parseInt(resp) != 1 
          return reject(
            err: 'NOT_WORKING_JOG' 
            data: 'job was not working status for job id : ' + jobId 
          )
        @client.hdel(jobMapKey, jobId, (err, resp) =>
          if err != null 
            return reject(err)
          log.d("JOB SUCCESS, job_id: #{jobId}")
          resolve({}) 
        )
      )
    )

  # make job to failure
  makeJobFail: (jobId) =>
    jobMapKey = redisConf.jobMapKey
    procMapKey = redisConf.jobProcMapKey
    failMapKey = redisConf.jobFailMapKey
    queueKey = redisConf.jobQueueKey
    return new Promise((resolve, reject) =>
      @client.hdel(procMapKey, jobId, (err, resp) =>
        if err != null 
          return reject(err)
        if parseInt(resp) != 1 
          return reject(
            err: 'NOT_WORKING_JOG' 
            data: 'job was not working status for job id : ' + jobId 
          )
        @client.hmget(failMapKey, jobId, (err, failResp) =>
          if err != null 
            return reject(err)

          failCount = null 
          if failResp.length == 1
            if failResp[0] != null 
              failCount = parseInt(failResp[0])
            else if failResp[0] == null 
              failCount = 1

          # case of failCount within threshold
          if failCount < brokerConf.retryWhenFail
            log.d("JOB FAILED, #{failCount} TIMES, job_id: #{jobId}")
            @client.hmset(failMapKey, jobId, failCount + 1, (err, resp) =>
              if err != null 
                return reject(err)
              
              @client.rpush(queueKey, jobId, (err, resp) =>
                if err != null 
                  return reject(err) 
                return resolve(
                  job_id: jobId
                  fail_count: failCount
                  finally_failed: false 
                )
              )
            )

          # case of failCount bigger than threshold
          else if failCount >= brokerConf.retryWhenFail
            log.d('JOB FINALLY FAILED, job_id: ' + jobId)
            return resolve(
              job_id: jobId
              fail_count: failCount
              finally_failed: true 
            )
            
        )
      )
    )

  # returns job queue elements with condition
  getJobs: (condition) =>
    return new Promise((resolve, reject) =>

    )

  # returns job failure logs.
  getJobFails: (condition) =>
    return new Promise((resolve, reject) =>

    )

instance = null
module.exports = () ->
  if instance == null 
    instance = new RedisRepository() 
  return instance