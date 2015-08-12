
path = require 'path'
fs = require 'fs'
mongoose = require 'mongoose'
Schema = mongoose.Schema
debug = require('debug')('app:db')

db = mongoose.createConnection()

basedir = path.join __dirname, 'models'
fs.readdir basedir, (err, files) ->
  files.forEach (file) ->
    name = file.replace(/\.[^.]+$/, '')
    schema = require(path.join(basedir, file))(Schema)
    db.model(name, schema)
    Object.defineProperty db, name,
      get: -> db.model(name)

db.middleware = (opts) ->
  return (req, res, next) ->
    req.db = db
    if opts.wait and db.readyState isnt 1
      debug('waiting for db connection')
      db.once 'connected', ->
        next()
    else
      next()

## create admin user
db.once 'connected', ->
  debug('connected')
  await db.db.listCollections(name: 'users').toArray defer(err, list)
  if not err and list.length == 0
    debug('creating admin user: username=admin password=admin')
    user = new db.User name: 'Admin', username: 'admin', password: 'admin', email: 'admin@localhost'
    user.save()

module.exports = db
