###
  Copyright (c) 2015 Abi Hafshin
  see README.md
###

debug = require('debug')('app:controller')
fs = require 'fs'
path = require 'path'

default_config =
  defaultModule: 'main'
  defaultController: 'default'
  defaultAction: 'index'

###
  This class must be extended by any controllers
###
class Controller
  constructor: (@req, @res, @next) ->

  createUrl: (name, param) ->
    return @res.createUrl(name, param)

  redirect: (name, param, status) ->
    @res.redirect(@createUrl(name, param), status)

  render: (name, data) ->
    if name[0] is '/'
      name = name.substr(1)
    else
      name = @req.routeName.replace(/\.\w+$/, '').replace('.', '/') + '/' + name
    debug('rendering %s', name)
    @res.render(name, data)

  runAction: (name) ->
    funcName = 'action' + name.replace /(^|-)\w/g, (c) ->
      if c[0] is '-' then c=c[1]
      return c.toUpperCase()
    debug('calling action function: %s', funcName)
    action = this[funcName]
    if action
      if typeof action._paramNames isnt 'object'
        paramStr = action.toString().match(/function\s+\w*\(\s*([^)]*)\s*\)/)[1].trim()
        action._paramNames = if paramStr.length > 0 then paramStr.split(/,\s*/) else []
      requestParams = @req.params
      requestQuery = @req.query
      callParams = action._paramNames.map (param_name) -> requestParams[param_name] || requestQuery[param_name]
      action.apply(this, callParams)
    else
      @next new HttpError @req.i18n.__('Action %s not found', name), 404

Object.defineProperty(Controller.prototype, 'db', {
  get: -> @req.db
})

## Controller loader
loaded_controllers = {}
found_controllers = {}
basedir = path.join __dirname, 'controllers'
searchController = (subdir) ->

getController = (module_name, controller_name) ->
  import_name = module_name + '/' + controller_name
  if not loaded_controllers[import_name]
    debug('importing controller: %s', import_name)
    if fs.existsSync(path.join(basedir, import_name+'.js')) or fs.existsSync(path.join(basedir, import_name+'.coffee'))
      controller_loader = require('./controllers/' + import_name)
      loaded_controllers[import_name] = controller_loader(Controller)
  return loaded_controllers[import_name]

# middleware
module.exports = () ->
  return (req, res, next) ->
    parts = if req.routeName.length > 0 then req.routeName.split('.', 3) else []
    n = Math.min parts.length, 3
    module_name = req.params._module || if n > 2 then  parts[0] else  default_config.defaultModule
    controller_name = req.params._controller || if n > 1 then parts[n-2] else default_config.defaultController
    action_name = req.params._action || if n > 0 then parts[n-1] else default_config.defaultAction
    req.routeName = "#{module_name}.#{controller_name}.#{action_name}"

    debug("handling %s", req.routeName)
    controllerClass = getController(module_name, controller_name)
    if controllerClass
      controller = new controllerClass(req, res, next)
      controller.runAction(action_name)
    else
      next new HttpError req.i18n.__('Controller %s.%s not found', module_name, controller_name), 404

