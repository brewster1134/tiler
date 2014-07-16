###
# * tiler
# * https://github.com/brewster1134/tiler
# *
# * Copyright (c) 2014 Ryan Brewster
# * Licensed under the MIT license.
###

((root, factory) ->
  if typeof define == 'function' && define.amd
    define [
        'jquery'
      ], ($) ->
      factory $
  else
    window.Tiler = factory $
) @, ($) ->

  class Tiler
    constructor: (options) ->
      @grid = {}
      @options = $.extend {},

        # create default options values here
        #
        tileSelector: '.tiler'

      , options

    buildGrid: ->
      _this = @
      $tiles = $('.tiler')

      $tiles.each ->
        row = null
        col = null

        # if coordinates are explicitly set
        if coords = $(@).data('tiler-coords')

          # create array of integers
          coords = $.map coords.split(','), (val) -> parseInt(val)
          row = coords[0]
          col = coords[1]

        # otherwise determine coordinates based on existing tiles
        else
          row = Object.keys(_this.grid).length
          col = Object.keys(_this.grid[row] || {})?.length || 0

        # add jquery object to its proper coordinate
        _this.grid[row] ||= {}
        _this.grid[row][col] = $(@)

      @grid
