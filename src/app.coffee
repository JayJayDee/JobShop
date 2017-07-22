
RedisRepository = require('./repositories/redisRepository') 

repo = RedisRepository() 

console.log('app entry')

###
repo.enqueueJob(
  test: 'test_job_spec'
)
.then((resp) ->
  console.log(resp)
)
.catch((err) ->
  console.log(err)
)
###

repo.dequeueJob()
.then((job) =>
  console.log(job)
)
.catch((err) =>
  console.log(err)
)