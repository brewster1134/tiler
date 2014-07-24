###
# * tiler
# * https://github.com/brewster1134/tiler
# *
# * @version 0.0.2
# * @author Ryan Brewster
# * Copyright (c) 2014
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
      initialTile: 1
      reverseSupport: true

    _create: ->
      @$currentTileId = 0
      @$tiles = $('.tiler-tile', @element)

    _init: ->
      @_sizeTiles()
      @_buildLinks()
      @goTo @options.initialTile, null

    # PUBLIC METHODS
    #
    goTo: (idOrRow, activeClass) ->
      # detect tile id or coordinates
      if typeof idOrRow == 'string'
        $tile = @$tiles.filter("##{idOrRow}")
        tileId = @$tiles.index($tile) + 1
      else
        $tile = @$tiles.eq(idOrRow - 1)
        tileId = idOrRow

      # return if we are already on that tile
      return if @$currentTileId == tileId

      $enterTile = $tile
      $exitTile = @$tiles.eq(Math.max(0, @$currentTileId - 1))

      # allow null or empty strings to be a valid active class
      activeClass = 'no-active-class' if activeClass == null || activeClass == ''
      enterTileClass = activeClass || $enterTile.data('tiler-active-class') || ''

      # order tiles
      $enterTile.css
        zIndex: 2
      $exitTile.css
        zIndex: 1
      @$tiles.not($enterTile).not($exitTile).css
        zIndex: -1

      # manage css classes if an one is specified
      @_transitionCss $enterTile, $exitTile, enterTileClass

      # fire js events
      # @element.trigger 'tiler.goto', $enterTile.attr('id'), $exitTile.attr('id')
      @element.trigger 'tiler.goto',
        enterTile: $enterTile
        exitTile: $exitTile

      # update the current tile id
      @$currentTileId = tileId

      return $enterTile

    _transitionCss: ($enterTile, $exitTile, enterTileClass) ->
      enterTileId = @$tiles.index($enterTile, $exitTile) + 1

      # determine the direction of animation
      #
      if !@options.reverseSupport || @_isNavigatingForward(enterTileId)
        exitTileInitialState      = 'exit'
        exitTileInitialPosition   = 'start'
        exitTileFinalPosition     = 'end'

        enterTileInitialState     = 'enter'
        enterTileInitialPosition  = 'start'
        enterTileFinalPosition    = 'end'

      else
        exitTileInitialState      = 'enter'
        exitTileInitialPosition   = 'end'
        exitTileFinalPosition     = 'start'

        enterTileInitialState     = 'exit'
        enterTileInitialPosition  = 'end'
        enterTileFinalPosition    = 'start'


      # EXIT TILE
      #
      # reset
      $exitTile.attr 'class', "tiler-tile #{exitTileInitialState} #{enterTileClass}"

      # set enter tile start position
      # backup any transition data.  we need to set a start position without any animations
      #
      $exitTile.data 'tiler-transition', $exitTile.css('transition')
      $exitTile.data 'tiler-transition-duration', $exitTile.css('transition-duration')
      $exitTile.css 'transition-duration', 0
      $exitTile.addClass exitTileInitialPosition
      $exitTile.css
        transition: $exitTile.data 'tiler-transition'
        transitionDuration: $exitTile.data 'tiler-transition-duration'

      # trigger the end position
      $exitTile.switchClass exitTileInitialPosition, exitTileFinalPosition


      # ENTER TILE
      #

      # reset
      $enterTile.attr 'class', "tiler-tile #{enterTileInitialState} #{enterTileClass}"

      # set enter tile start position
      # backup any transition data.  we need to set a start position without any animations
      #
      $enterTile.data 'tiler-transition', $enterTile.css('transition')
      $enterTile.data 'tiler-transition-duration', $enterTile.css('transition-duration')
      $enterTile.css 'transition-duration', 0
      $enterTile.addClass enterTileInitialPosition
      $enterTile.css
        transition: $enterTile.data 'tiler-transition'
        transitionDuration: $enterTile.data 'tiler-transition-duration'

      # trigger the end position
      $enterTile.addClass 'active'
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

    # determine if we are advancing or retreating through our virtual tiles
    #
    _isNavigatingForward: (enterTileId) ->
      enterTileId > @$currentTileId
