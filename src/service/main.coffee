## Main modules
express =   require('express')
log4js =    require('log4js')
nconf =     require('nconf')

## Middlewares
methodOverride = require('method-override')
cookieParser =   require('cookie-parser')
morgan =         require('morgan')
bodyParser =     require('body-parser')
serveStatic =    require('serve-static')

## Make the server
app = express()

## Initialize logging
logger = log4js.getLogger()

## Configure ourselves
nconf
  .use('memory')
  .argv()
  .env()
  .file(process.cwd() + "/config.json")
  .file('global', "/etc/default/gitbuzz")

nconf.defaults
  'password:salt': ''
  'data:datadb': "mongodb://localhost:27017/gitbuzz"
  'server:port': 3001
  'server:address': "0.0.0.0"
  'debug': true
  'authenticate': false
  'baseUrl': 'http://localhost:3000'
  'apikey': 'garblemonkey'
  'cookieSecret': 'keyboard cat'
  'serveStatics': false
  'serveIndex': false
  'schedule:cron': '* * * * *'

config = nconf.get()

## Exports
module.exports.logger =   logger
module.exports.log4js =   log4js
module.exports.app =      app
module.exports.config =   config

app.locals.pretty = true

app.use methodOverride('X-HTTP-Method-Override')
app.use cookieParser()
app.use morgan('short')
app.use bodyParser.json()

if config['serveStatics']
  app.use serveStatic(config['serveStatics'], {'index': false})

if config['serveIndex']
  app.get '/*', (req, res) ->
    directory = config['serveStatics'] || './public'
    file = directory + '/index.html'
    if !res.getHeader('Cache-Control')
      res.setHeader 'Cache-Control', 'public, max-age=0'
    res.sendfile(file)

logger.info("Initializing scheduled tasks");
scheduler = require("./scheduler")
scheduler.initializeScheduler () ->
  logger.info("Running background task")

app.listen config['server']['port'], config['server']['address']
logger.info "Express server listening on port", config['server']['port']

