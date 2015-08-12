###
  Copyright (c) 2015 Abi Hafshin
  see README.md
###


# import base
path = require 'path'
debug = require('debug')('app:core')

# express
express = require 'express'

# import vendor midleware
i18n = require 'i18n-2'
session = require('express-session')
RedisStore = require('connect-redis')(session)
bodyParser = require 'body-parser'
flash = require 'flash'

# import internal
db = require './db'
asset = require './asset'
auth = require './auth'
router = require './router'
controllers = require('./controller')

module.exports = (config) ->
  app = express()

  ## set up app info
  if config.name
    debug('application name: ' + config.name)
    app.set('name', config.name)
    app.locals.appName = config.name

  ## set up view
  view_dir = path.join(__dirname, '../views')
  app.set('view engine', 'jade')
  app.set('views', view_dir)
  app.locals.basedir = view_dir
  app.locals.env = app.get('env')

  app.use '/assets/vendor', express.static('bower_components')
  app.use asset()

  ## data base
  app.db = db
  db.open(config.db.uri)
  app.use db.middleware(wait: true)

  ## setup session
  app.use session
    name: 'sid'
    secret: config.get('session.secret', '123456')
    resave: false
    saveUninitialized: false
    cookie:
      maxAge: 1000 * 60 * 60 * 24 * 7 # 1 week
    store: new RedisStore config.session.redis
  app.use flash()

  ## body parser
  app.use(bodyParser.urlencoded({ extended: false })) # parse application/x-www-form-urlencoded
  app.use(bodyParser.json()) # application/json
  # multi part ????

  ## setup authentication
  auth.setup(app)

  ## internationalize
  app.i18n = i18n
  i18n.expressBind app,
    locales: ['id', 'en-US']
    defaultLocale: 'id'
    cookieName: 'l'
    directory: path.join(__dirname, '../locales')
    extension: '.json'
  app.use (req, res, next) ->
    if req.user and req.user.locale
      req.i18n.setLocale(req.user.locale)
    else
      req.i18n.setLocaleFromCookie()
    res.locals.locale = req.i18n.getLocale()
    next()

  ## application router
  app.post('/login', auth.login('local'))
  app.use router(app, config.routes)
  app.use controllers()

  ## not found handler
  app.use (req, res, next) ->
    debug('404: %s', req.url)
    next new HttpError(req.i18n.__('Page Not Found'), 404)

  ## error handler
  app.use (err, req, res, next) ->
    if err.status isnt 404 then console.trace err
    if res.headersSent
      return next(err)
    res.statusCode = err.status || 500
    if req.xhr
      res.send({err: err.message})
    else
      res.render('error', pageTitle: req.i18n.__('Error'), error: err)

  return app


if not global.HttpError
  global.HttpError = class HttpError extends Error
    constructor: (@message, @status) ->
      Error.call this, message

    name: 'HttpError'

