
RedisRepository = require('./repositories/redisRepository') 

repo = RedisRepository() 

console.log('app entry')

repo.enqueue(
  test: 'test_job_spec'
)
.then((resp) ->
  console.log(resp)
)
.catch((err) ->
  console.log(err)
)