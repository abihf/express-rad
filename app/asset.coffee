###
  Copyright (c) 2015 Abi Hafshin
  see README.md
###

asset = require 'connect-assets'

Mincer = require('mincer')
require('mincer-cssurl')(Mincer)
Mincer.Template.libs.coffee = require('iced-coffee-script')

module.exports = () ->
  options =
    paths: [
      'assets/css',
      'assets/js',
      'assets/img'
    ]
    gzip: process.env.NODE_ENV == 'production'

  return asset options, (instance) ->
    env = instance.environment
    env.enable('cssurl')
    env.enable('autoprefixer')
