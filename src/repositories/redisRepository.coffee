
redisConf = require('../configs/redis')

class RedisRepository 

  constructor: () ->
    return 

instance = null
module.exports = () ->
  if instance == null 
    instance = new RedisRepository() 
  return instance