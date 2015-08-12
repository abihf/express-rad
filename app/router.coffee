###
  Copyright (c) 2015 Abi Hafshin
  see README.md
###

debug = require('debug')('app:router')
Path = require 'path'

class Router
  ###

  ###
  constructor: (routes) ->
    @_basePath = '/'
    @_simpleRoutes = {}
    @_regexRoutes = []
    @_names = {}
    for path,name of routes
      if path.match /:/
        @_addRegexRoutes(path, name)
      else
        @_addSimpleRoutes(path, name)

  _addSimpleRoutes: (path, name) ->
    @_simpleRoutes[path] = name
    @_names[name] = path

  _matchSimpleRoutes: (path) ->
    path = path.replace(/\/{2,}/g, '/')
    if (path.length > 2)
      path = path.replace(/\/$/, '')
    if @_simpleRoutes[path]
      return {name: @_simpleRoutes[path], param: {}}

  _addRegexRoutes: (path, name) ->
    params = []
    matchingParts = []
    generatingParts = []
    for t in path.split('/')
      colon_index = t.indexOf(':')
      if colon_index >= 0
        param_name = t.substr(colon_index+1)
        regex = if colon_index is 0 then new RegExp("^#{t.substr(0, colon_index)}$") else /.*/
        matchingParts.push(regex)
        params.push(param_name)
        generatingParts.push("{#{param_name}}")
      else
        matchingParts.push(t)
        generatingParts.push(t)
    @_regexRoutes.push {parts: matchingParts, params: params, name: name}
    @_names[name] = generatingParts.concat('/')


  _matchRegexRoutes: (path) ->
    parts = path.split('/')
    for route in @_regexRoutes
      match = true
      params = {}
      param_index = 0
      i = 0
      while match and i < route.parts.length
        p = route.parts[i]
        if typeof p is 'string'
          if p isnt parts[i]
            match = false
        else # if p instanceof RegExp
          if not parts[i].match(p)
            match = false
          else
            param_name = route.params[param_index++]
            params[param_name] = parts[i]
        i++
      if match  # really match
        return {name: route.name, params: params}
    return null



  matchUrl: (path) ->
    path = path.replace(/(^\/+)|(\/+$)/g, '').replace(/\/{2,}/g, '.')
    if res = @_matchSimpleRoutes(path)
      return res
    else if res = @_matchRegexRoutes(path)
      return res
    else
      name = path.replace(/\//g, '.')
      return {name: name, param: {}}

  createUrl: (name, params, relativePath) ->
    url = @_names[name] || name.replace(/\./g, '/')
    url = url.replace /\{\w\}/g, (p) ->
      if not params[p]
        debug('createUrl(%s) incomplete param %s', name, p)
      return params[p]
    return Path.join @_basePath, url

  handleRequest: (req, res, next) ->
    debug('handling request %', req.url)
    route = @matchUrl(req.path)
    if route
      debug('route name: %s', route.name)
      req.routeName = route.name
      for k,v of route.param
        req.param[k] = v
    else
      debug('unknown route name')

    _this = this
    res.createUrl = res.locals.url = (name, params) ->
      _this.createUrl(name, params, req.routeName)

    next()


module.exports = (app, routes) ->
  debug('configuring...')
  router = new Router(routes || {})
  app.routeManager = router
  return router.handleRequest.bind(router)
