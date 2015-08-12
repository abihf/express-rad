###
  Copyright (c) 2015 Abi Hafshin
  see README.md
###

passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
debug = require('debug')('app:auth')

exports.setup = (app, options) ->
  passport.use new LocalStrategy (username, password, done) ->
    debug('authenticating ' + username)
    await app.db.User.findOne username: username, defer(err, user)
    if (err)
      done(err)
    else if not user
      done(null, false, { message: 'Incorrect username.' })
    else if not user.authenticate(password)
      done(null, false, { message: 'Incorrect password.' });
    else
      done(null, user)

  passport.serializeUser (user, done) ->
    done(null, user.id)

  passport.deserializeUser (id, done) ->
    app.db.User.findById id, done

  app.use passport.initialize()
  app.use passport.session()
  app.use (req, res, next) ->
    res.locals.user = req.user || {}
    next()

exports.login = (strategy) ->
  passport.authenticate(strategy,
    successRedirect: '/',
    failureRedirect: '/login',
    failureFlash: true
  )
