###
  Copyright (c) 2015 Abi Hafshin
  see README.md
###

module.exports = (Controller) ->
  class DefaultController extends Controller

    actionIndex: ->
      @render('index')

