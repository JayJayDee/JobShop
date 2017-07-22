
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

  # enqueue new job with payload, 
  # returns with unique job ID 
  enqueue: (jobPayload) =>
    return new Promise((resolve, reject) =>
    
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