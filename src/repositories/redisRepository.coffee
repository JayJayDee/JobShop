
crypto = require('crypto')
redis = require('redis')

redisConf = require('../configs/redis')

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
  enqueueJob: (jobPayload) =>
    queueKey = redisConf.jobQueueKey
    mapKey = redisConf.jobMapKey
    return new Promise((resolve, reject) =>
      @createJobId()
      .then((jobId) =>
        stringified = JSON.stringify(jobPayload)
        @client.hmset(mapKey, jobId, stringified, (err, resp) =>
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
  dequeueJob: () =>
    queueKey = redisConf.jobQueueKey
    mapKey = redisConf.jobMapKey
    return new Promise((resolve, reject) =>
      @client.lpop(queueKey, (err, jobId) =>
        if err != null 
          return reject(err)
        if jobId == null 
          return resolve(null)
        
        @client.hmget(mapKey, jobId, (err, jobPayload) =>
          if err != null 
            return reject(err) 
          retPayload = jobPayload

          @client.hdel(mapKey, jobId, (err, resp) =>
            if err != null 
              return reject(err) 
            resolve(JSON.parse(retPayload))
          )
        )
      )
    )

  # update one queue element
  updateJob: (jobId, updateElem) =>
    return new Promise((resolve, reject) =>

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