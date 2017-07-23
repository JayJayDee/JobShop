
util = require('util') 
moment = require('moment') 
_ = require('underscore') 

env = process.env.NODE_ENV

helpers  = 
  # parse log payload
  parse: (log) ->
    logExpr = null 
    if util.isObject(log) == true or util.isArray(log) == true 
      logExpr = JSON.stringify(log) 
    else 
      logExpr = log 
    return logExpr 

  # build log expression 
  bulidLog: (mode, log) ->
    date = moment().utc().format('YYYY-MM-DD HH:mm:ss')
    formatted = "[#{date}@#{mode}] #{log}"
    return formatted


logger = 

  # info. showing all cases
  i: (log) ->
    rawLog = helpers.parse(log) 
    console.log(helpers.bulidLog('i', rawLog))

  # debug. show in dev only
  d: (log) ->
    if !(!env or env == 'dev')
      return 
    rawLog = helpers.parse(log) 
    console.log(helpers.bulidLog('d', rawLog))

  # error. showing in all cases
  e: (log) ->
    rawLog = helpers.parse(log) 
    console.log(helpers.bulidLog('e', rawLog))

module.exports = logger