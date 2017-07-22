
RedisRepository = require('./repositories/redisRepository') 

repo = RedisRepository() 

console.log('app entry')

repo.createJobId()
.then((jobId) =>
  console.log(jobId)
)
.catch((err) =>
  console.log(err)
)