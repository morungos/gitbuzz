module.exports.log4js = module.parent.exports.log4js
module.exports.logger = module.parent.exports.logger

logger = module.exports.logger

app =    module.parent.exports.app
config = module.parent.exports.config

## Now let's start to work on handling a request to Github. This should
## actually be run periodically from a task, such as a cron-like thing.
## Oh, I remember building one of those...

https = require('https')

module.exports.update = () ->
  requestUserEvents 'morungos', (err, events) ->
    logger.debug "Done", err

requestUserEvents = (user, callback) ->
  options = {}
  for own key, value of config['github']['settings']
    options[key] = value

  options['path'] = "/users/#{user}/events"

  data = ''

  logger.debug "Making request", options

  req = https.request options, (res) =>
    logger.debug "statusCode: ", res.statusCode
    logger.debug "headers: ", res.headers

    res.on 'data', (chunk) ->
      data += chunk

    res.on 'end', () ->
      obj = JSON.parse(data)
      logger.debug "Parsed data", obj
      callback null, obj

  req.end()

  req.on 'error', (e) ->
    logger.error "Failed to get data", e
    callback e, null