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
        'effect'
      ], ($) ->
      factory $
  else
    factory jQuery
) @, ($) ->

  $.widget 'ui.tiler',
    widgetEventPrefix: 'tiler'
    options:
      initialTile: [1,1]
      reverseSupport: true

    _create: ->
      @grid = {}
      @$currentTile = [0,0]
      @$tiles = $('.tiler-tile', @element)

    _init: ->
      @_sizeTiles()
      @_buildGrid()
      @_buildLinks()
      @goTo @options.initialTile...

    # PUBLIC METHODS
    #
    goTo: (idOrRow, col = null) ->
      # detect tile id or coordinates
      unless col
        row = @$tiles.filter("##{idOrRow}").data('tiler-row')
        col = @$tiles.filter("##{idOrRow}").data('tiler-col')
      else
        row = idOrRow

      $exitTile = @grid[@$currentTile[0]]?[@$currentTile[1]] || $()
      $enterTile = @grid[row][col]

      # return if we are already on that tile
      return if @$currentTile[0] == row && @$currentTile[1] == col

      # hide all uninvolved tiles
      @$tiles.not($exitTile).not($enterTile).hide()

      # manage css classes if an one is specified
      @_transitionCss $exitTile, $enterTile

      # update the current tile
      @$currentTile = [row, col]

      return $enterTile

    _transitionCss: ($exitTile, $enterTile) ->
      enterTileClass = $enterTile.data('tiler-active-class')

      row = $enterTile.data('tiler-row')
      col = $enterTile.data('tiler-col')

      # determine the direction of animation
      #
      if !@options.reverseSupport || @_isNavigatingForward(row, col)
        exitTileInitialState = 'exit'
        exitTileInitialPosition = 'start'
        exitTileFinalPosition = 'end'

        enterTileInitialState = 'enter'
        enterTileInitialPosition = 'start'
        enterTileFinalPosition = 'end'

      else
        exitTileInitialState = 'enter'
        exitTileInitialPosition = 'end'
        exitTileFinalPosition = 'start'

        enterTileInitialState = 'exit'
        enterTileInitialPosition = 'end'
        enterTileFinalPosition = 'start'


      # EXIT TILE
      #

      # reset
      $exitTile.attr 'class', "tiler-tile #{exitTileInitialState}"
      $exitTile.addClass enterTileClass

      # set enter tile start position
      $exitTile.data 'tiler-transition', $exitTile.css('transition')
      $exitTile.data 'tiler-transition-duration', $exitTile.css('transition-duration')
      $exitTile.css 'transition-duration', 0
      $exitTile.addClass exitTileInitialPosition
      $exitTile.css
        transition: $exitTile.data 'tiler-transition'
        transitionDuration: $exitTile.data 'tiler-transition-duration'
      $exitTile.show()

      # trigger the end position
      $exitTile.switchClass exitTileInitialPosition, exitTileFinalPosition


      # ENTER TILE
      #

      # reset
      $enterTile.attr 'class', "tiler-tile #{enterTileInitialState}"
      $enterTile.addClass enterTileClass

      # set enter tile start position
      $enterTile.data 'tiler-transition', $enterTile.css('transition')
      $enterTile.data 'tiler-transition-duration', $enterTile.css('transition-duration')
      $enterTile.css 'transition-duration', 0
      $enterTile.addClass enterTileInitialPosition
      $enterTile.css
        transition: $enterTile.data 'tiler-transition'
        transitionDuration: $enterTile.data 'tiler-transition-duration'
      $enterTile.show()

      # trigger the end position
      setTimeout -> $enterTile.addClass 'active'
      $enterTile.switchClass enterTileInitialPosition, enterTileFinalPosition

    # find possible lins throughout the entire page and set meta data on them
    #
    _buildLinks: ->
      _this = @

      $('[data-tiler-link-id]').each ->
        tileId = $(@).data('tiler-link-id').split(':')

        # check for tiler namespace
        if tileId.length == 2
          tilerInstance = $(".tiler-viewport##{tileId[0]}")
          tileInstance = $(".tiler-tile##{tileId[1]}", tilerInstance)
        else
          tileInstance = $(".tiler-tile##{tileId[0]}")

        # get tile title
        tileTitle = tileInstance.data('tiler-title')

        # set tile title to link
        $(@).attr 'data-tiler-title', tileTitle

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

    # determine if we are advancing or retreating through our virtual tiles
    #
    _isNavigatingForward: (row, col) ->
      currentRow = @$currentTile[0]
      currentCol = @$currentTile[1]

      (row > currentRow) || (row == currentRow && col >= currentCol)
