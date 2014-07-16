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
        'widget'
      ], ($) ->
      factory $
  else
    factory jQuery
) @, ($) ->

  $.widget 'ui.tiler',
    widgetEventPrefix: 'tiler'
    options:
      tileSelector: '.tiler'
      initialTile: [1,1]

    _create: ->
      @grid = {}
      @$currentTile = $('<div/>')
      @$tiles = $(@options.tileSelector, @element)

    _init: ->
      @_sizeTiles()
      @_buildGrid()
      @goToTile @options.initialTile...

    # PUBLIC METHODS
    #
    goToTile: (row, col, direction) ->
      $exitTile = @$currentTile
      $enterTile = @grid[row][col]

      enterTileClass = $enterTile.data('tiler-active-class')

      # hide all uninvolved tiles
      @$tiles.not($exitTile).not($enterTile).hide()

      # EXIT TILE
      #

      # reset
      $exitTile.attr 'class', 'tiler exit'
      $exitTile.addClass enterTileClass

      # set enter tile start position
      $exitTile.data 'tiler-transition', $exitTile.css('transition')
      $exitTile.data 'tiler-transition-duration', $exitTile.css('transition-duration')
      $exitTile.css 'transition-duration', 0
      $exitTile.addClass 'start'
      $exitTile.css
        transition: $exitTile.data 'tiler-transition'
        transitionDuration: $exitTile.data 'tiler-transition-duration'
      $exitTile.show()

      # trigger the end position
      setTimeout ->
        $exitTile.addClass 'end'
        $exitTile.removeClass 'start'

      # ENTER TILE
      #

      # reset
      $enterTile.attr 'class', 'tiler enter'
      $enterTile.addClass enterTileClass

      # set enter tile start position
      $enterTile.data 'tiler-transition', $enterTile.css('transition')
      $enterTile.data 'tiler-transition-duration', $enterTile.css('transition-duration')
      $enterTile.css 'transition-duration', 0
      $enterTile.addClass 'start'
      $enterTile.css
        transition: $enterTile.data 'tiler-transition'
        transitionDuration: $enterTile.data 'tiler-transition-duration'
      $enterTile.show()

      # trigger the end position
      setTimeout ->
        $enterTile.addClass 'end'
        $enterTile.removeClass 'start'

      # update the current title
      @$currentTile = $enterTile

      return $enterTile

    # match all the tiles to the size of the viewport
    #
    _sizeTiles: ->
      @$tiles.css
        width: @element.outerWidth()
        height: @element.outerHeight()

    # calculate the virtual grid locations of all the tiles
    #
    _buildGrid: ->
      _this = @

      @$tiles.each ->
        # check if row is set explicitly, otherwise calculate it
        row = $(@).data('tiler-row') || (Object.keys(_this.grid).length + 1)

        # calculate col
        col = Object.keys(_this.grid[row] || {}).length + 1

        # add meta data to tiles
        $(@).data 'tiler-row', row
        $(@).data 'tiler-col', col

        # add jquery object to its proper coordinate
        _this.grid[row] ||= {}
        _this.grid[row][col] = $(@)

      @grid
