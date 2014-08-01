module.exports.log4js = module.parent.exports.log4js
module.exports.logger = module.parent.exports.logger

logger = module.exports.logger

app =    module.parent.exports.app
config = module.parent.exports.config

## Now let's start to work on handling a request to Github. This should
## actually be run periodically from a task, such as a cron-like thing.
## Oh, I remember building one of those...

https = require('https')
mongo = require("mongodb")
async = require("async")
url =   require('url')

BSON = mongo.BSONPure
MongoClient = mongo.MongoClient

module.exports.update = () ->
  databaseUrl = config["data"]["datadb"]
  users = config["github"]["users"]
  limit = 50

  MongoClient.connect databaseUrl, (err, db) ->
    return if err

    db.collection "events", (err, events) ->
      return done(err) if err?

      done = (err) ->
        logger.info "Closing database", err
        db.close() if db?

      pendingUpdates = (err) ->
        return done(err) if err?
        completeEvents db, limit, done

      handleUser = (user, userCallback) ->
        logger.info "Calling handleUser", user

        handleEventRecord = (eventRecord, eventCallback) ->
          logger.info "Calling handleEventRecord", user
          eventRecord['_id'] = eventRecord['id']
          delete eventRecord['id']
          events.save eventRecord, (err, result) ->
            logger.info "Written database event record", err, result
            eventCallback err

        identifier = user.id
        limit--
        requestUserEvents user.id, (err, object) ->
          if err?
            done(err)
          else
            async.eachSeries object, handleEventRecord, userCallback

      if !err?
        async.eachSeries users, handleUser, pendingUpdates

requestData = (path, callback) ->
  options = {}
  for own key, value of config['github']['settings']
    options[key] = value

  options['path'] = path

  data = ''

  req = https.request options, (res) =>

    res.on 'data', (chunk) ->
      data += chunk

    res.on 'end', () ->
      obj = JSON.parse(data)
      if res.statusCode >= 400
        callback res.statusCode, obj
      else
        callback null, obj

  req.end()

  req.on 'error', (e) ->
    callback e, null

requestUserEvents = (user, callback) ->
  requestData "/users/#{user}/events", callback

completeEvents = (db, limit, callback) ->
  logger.debug "About to start completing events"
  db.collection "events", (err, events) ->
    events.find({'type': 'PushEvent', '$or': [{"payload.commits.buzzData" : {"$exists": false}}, {"repo.buzzLanguages" : {"$exists": false}}]},
                {"limit": limit}).toArray (err, docs) ->

      return callback(err) if err?

      statisticsCommands = {}
      addStatisticsCommand = (command) ->
        commandUrl = command.url
        if ! statisticsCommands[commandUrl]?
          statisticsCommands[commandUrl] = command

      for doc in docs
        logger.info doc['_id'], doc.repo.url, doc.repo
        addStatisticsCommand { "type" : "repoLanguages", "url" : doc.repo.url + "/languages", "query" : { 'repo.name' : doc.repo.name }, "updateField" : "repo.buzzLanguages" } unless doc.repo['buzzLanguages']?
        for commit in doc.payload.commits
          addStatisticsCommand {"type" : "commit", "url" : commit.url, "query" : { 'payload.commits.sha' : commit.sha }, "updateField" : "payload.commits.$.buzzData" } unless commit['buzzData']?

      logger.info "Gathering statistics"
      for own key, value of statisticsCommands
        logger.info "KEY: #{key}"


      ## Here we have a fairly small set of commits we can test. These might be in the
      ## database, in which case we are good to go. Or we might need to complete them
      ## with a web request.

      db.collection "statistics", (err, statistics) ->
        addStatistics = (requestUrl, statisticsCallback) ->
          request = statisticsCommands[requestUrl]
          statisticsQuery = { "type": request.type, "_id": request.url }
          logger.debug "Looking for statistics", statisticsQuery
          statistics.findOne statisticsQuery, (err, doc) ->
            return callback(err) if (err)

            updateDocuments = (doc) ->
              updater = {}
              updater[request.updateField] = doc.buzzData
              logger.info "Applying update", request.query, {"$set" : updater}
              events.update request.query, {"$set" : updater}, {'multi': true}, statisticsCallback

            if ! doc?
              if limit-- == 0
                return callback('Exceeded request limit')
              parsed = url.parse request.url
              logger.debug "Starting request", parsed
              requestData parsed.path, (err, data) ->

                ## Special case -- 404 is just plain missing
                if err == 404
                  err = null
                  data = {}

                return callback(err) if (err)

                ## Build the statistics we need. This depends a bit on the kind
                ## of data we are after.

                buzzData = {}
                switch request.type
                  when 'repoLanguages'
                    buzzData['languages'] = data
                  when 'commit'
                    buzzData['stats'] = data.stats
                    buzzData['date'] = data.commit?.committer?.date

                statisticsQuery['buzzData'] = buzzData
                statistics.insert statisticsQuery, (err, result) ->
                  return callback(err) if (err)
                  updateDocuments(statisticsQuery)
            else
              updateDocuments(doc)

        logger.debug "About to handle statistics"
        statisticsUrls = Object.keys statisticsCommands
        async.eachSeries statisticsUrls, addStatistics, callback
