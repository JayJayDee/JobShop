

crypto = require('crypto')
brokerConf = require('../configs/broker') 

# job queue CRUD implementation for MySQL
class MySQLRepository

  constructor: () ->
    return

  # create new unique job id 
  # in this Repository
  createJobId: () =>
    return new Promise((resolve, reject) =>
    
    )

  # enqueue new job with payload, 
  # returns with unique job ID 
  addJob: (jobPayload) =>
    return new Promise((resolve, reject) =>
      
    )

  # get one job to do.
  fetchJobTodo: () =>
    return new Promise((resolve, reject) =>
      
    )

  # make job to success 
  makeJobSuccess: (jobId) =>
    return new Promise((resolve, reject) =>
      
    )

  # make job to failure
  makeJobFail: (jobId) =>
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
    instance = new MySQLRepository() 
  return instance