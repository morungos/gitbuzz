## Define the scheduled task actions.

module.exports.log4js = module.parent.exports.log4js
module.exports.logger = module.parent.exports.logger
config =                module.parent.exports.config
app =                   module.parent.exports.app

logger = module.exports.logger

schedule = require('node-schedule')
dateUtils = require('date-utils')

module.exports.initializeScheduler = (callback) ->
  callback()

  # stop = (err) ->
  #   logger.error "Scheduler error", err

  # job = schedule.scheduleJob config['schedule']['cron'], () ->
  #   callback()
  #   logger.info "Scheduled tasks completed"
