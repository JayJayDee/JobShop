
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
      console.log('redis ready')
    )
    redisInst.on('connect', () =>
      console.log('redis connected ' + redisConf.host)
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
  enqueue: (jobPayload) =>
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
  dequeue: () =>
    return new Promise((resolve, reject) =>
    
    )

  # update one queue element
  updateQueueElem: (jobId, updateElem) =>
    return new Promise((resolve, reject) =>
    
    )

  # returns job queue elements with condition
  getQueueElems: (condition) =>
    return new Promise((resolve, reject) =>

    )

instance = null
module.exports = () ->
  if instance == null 
    instance = new RedisRepository() 
  return instance