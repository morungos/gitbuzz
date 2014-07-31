module.exports.log4js = module.parent.exports.log4js
module.exports.logger = module.parent.exports.logger

logger = module.exports.logger

app =    module.parent.exports.app
config = module.parent.exports.config

mongo = require("mongodb")

BSON = mongo.BSONPure
MongoClient = mongo.MongoClient

applicationMiddleware = (req, res, next) =>
  logger.debug "Called middleware"

  originalEnd = res.end
  res.end = (chunk, encoding) ->
    res.end = originalEnd
    res.end(chunk, encoding)
    if res.locals.db?
      logger.debug "Disconnecting..."
      res.locals.db.close()

  url = config["data"]["datadb"]
  res.locals.config = config

  MongoClient.connect url, (err, db) ->
    return next(err) if err?
    res.locals.db  = db
    next()

app.get '/api/commitsByUser', applicationMiddleware, (req, res) ->
  pipeline = [
    { $match : { type : 'PushEvent' }}
    { $group : { _id : '$actor.login', events : { $sum : { $size : '$payload.commits' }}}}
    { $project : { name : '$_id', '_id' : 0, score : '$events' }}
  ]

  res.locals.db.collection('events').aggregate pipeline, (err, records) ->
    if err
      res.send 500, err
    else
      res.send {data: records}

app.get '/api/commitsByRepository', applicationMiddleware, (req, res) ->
  pipeline = [
    { $match : { type : 'PushEvent' }}
    { $group : { _id : '$repo.name', events : { $sum : { $size : '$payload.commits' }}}}
    { $project : { name : '$_id', '_id' : 0, score : '$events' }}
  ]

  res.locals.db.collection('events').aggregate pipeline, (err, records) ->
    if err
      res.send 500, err
    else
      res.send {data: records}
