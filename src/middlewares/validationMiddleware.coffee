
_ = require('underscore') 
validator = require('validator') 
sprintf = require("sprintf-js").sprintf

validationRouter =
  route: (rule) ->
    self = this 
    switch rule 
      when 'integer' then return self.validateIsInteger
      when 'email' then return self.validateIsEmail 
      when 'date' then return self.validateIsDate
      when 'timezone' then return self.validateIsTimezone
      when 'boolean' then return self.validateIsBoolean
      when 'region' then return self.validateIsRegionCode
      when 'language' then return self.validateIsLanguageCode
      when 'array' then return self.validateIsArray
      when 'category_type' then return self.validateIsCategoryType
      when 'interval' then return self.validateIsInterval
      when 'stat_type' then return self.validateIsStatType 
      when 'order' then return self.validateIsOrderExpr 
      when 'duration' then return self.validateIsDurationExpr 
    return null  

  isValidMethod: (method) ->
    if !(method == 'body' or method == 'query' or method == 'url')
      return false 
    return true  

  # validations below
  validateIsCategoryType: (categoryType) ->
    if categoryType == 'category' or categoryType == 'game' 
      return true 
    return false 

  validateIsOrderExpr: (map, paramName, value) ->
    validTypes = ['recent_desc', 'popular_desc', 'random']
    if _.contains(validTypes, value) == false 
      throw {
        err: 'INVALID_PARAM'
        data: "not a valid order expression : #{value}"
      }
    return true 

  validateIsDurationExpr: (map, paramName, value) ->
    validTypes = ['all', 'today', 'week_ago', 'month_ago', 'year_ago']
    if _.contains(validTypes, value) == false 
      throw {
        err: 'INVALID_PARAM'
        data: "not a valid duration expression : #{value}"
      }
    return true 

  validateIsStatType: (map, paramName, value) ->
    validTypes = ['view', 'uv', 'view_per_uv', 'newbie']
    if _.contains(validTypes, value) == false 
      throw {
        err: 'INVALID_PARAM'
        data: "not a valid stat_type : #{value}"
      }
    return true 

  validateIsInterval: (map, paramName, value) ->
    if !(value == 'daily' or value == 'hourly' or value == 'weekly' or value == 'monthly') 
      throw {
        err: 'INVALID_PARAM'
        data: "not a valid interval : #{value}"
      }
    return true 

  validateIsTimezone: (map, paramName, value) ->
    if validator.isNumeric(value) == false 
      throw {
        err: 'INVALID_PARAM'
        data: "invalid time zone expression : #{value}"
      }
    abs = value
    abs *= -1 if abs < 0 
    body = sprintf('%02d:00', parseInt(abs)) 
    if parseInt(value) >= 0 
      body = '+' + body 
    else if parseInt(value) < 0 
      body = '-' + body 
    map[paramName] = body

  validateIsDate: (map, paramName, value) ->
    if validator.isDate(value) == false 
      throw {
        err: 'INVALID_PARAM'
        data: "not a date expression : #{value}"
      }
      map[paramName] = value 

  # default, common validations
  validateIsInteger: (map, paramName, value) ->
    if validator.isNumeric(value) == false 
      throw {
        err: 'INVALID_PARAM' 
        data: 'not a number : ' + paramName 
      }
    map[paramName] = parseInt(value)

  validateIsBoolean: (map, paramName, value) ->
    if validator.isBoolean(value) == false
      throw {
        err: 'INVALID_PARAM'
        data: 'not a boolean : ' + paramName
      }
    map[paramName] = (value == 'true')

  validateIsEmail: (map, paramName, value) ->
    if validator.isEmail(value) == false 
      throw {
        err: 'INVALID_PARAM' 
        data: "not an email : #{value}" 
      }
    map[paramName] = value

  validateIsRegionCode: (map, paramName, value) ->
    if validator.isAlpha(value) == false or 
       validator.isUppercase(value) == false or 
        value.length < 2 
      throw {
        err: 'INVALID_PARAM'
        data: "invalid region code : #{value}"
      }
    map[paramName] = value 

  validateIsLanguageCode: (map, paramName, value) ->
    if validator.isAlpha(value) == false or 
       validator.isLowercase(value) == false or 
        value.length < 2 
      throw {
        err: 'INVALID_PARAM'
        data: "invalid language code : #{value}"
      }
    map[paramName] = value 

  validateIsArray: (map, paramName, value) ->
    if _.isArray(value) == false
      throw {
        err: 'INVALID_PARAM'
        data: 'not an array : ' + value
      }

validationMiddleware = (req, res, next) ->
  req.validateParam = (validateRule) ->
    validatedParams = {} 
    _.each(validateRule, (paramsDesc, method) ->
      if validationRouter.isValidMethod(method) == false 
        throw {
          err: 'INVALID_VALIDATE_METHOD' 
          data: 'invalid validation http method name'
        }
      dataMap = null 
      switch method 
        when 'body' then dataMap = req.body 
        when 'query' then dataMap = req.query 
        when 'url' then dataMap = req.params 

      _.each(paramsDesc, (paramRules, paramName) ->
        isNullable = false 
        _.each(paramRules, (rule) ->
          if rule == 'nullable' 
            isNullable = true 
        )

        validatedParams[paramName] = null 

        if isNullable == false and dataMap[paramName] == undefined 
          throw {
            err: 'INVALID_PARAM' 
            data: 'param required : ' + paramName 
          }

        if (isNullable == true and dataMap[paramName] != undefined) or 
            (isNullable == false and dataMap[paramName] != undefined)
          _.each(paramRules, (rule) ->
            if rule == 'nullable' 
              return 

            validateFunc = validationRouter.route(rule) 
            if validateFunc != null 
              validateFunc(dataMap, paramName, dataMap[paramName])
          )

        if dataMap[paramName] == undefined 
          validatedParams[paramName] = null 
        else 
          validatedParams[paramName] = dataMap[paramName]
      )
    )
    req.vparams = validatedParams
    return validatedParams
  next() 

module.exports = validationMiddleware