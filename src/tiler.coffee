###
# * tiler
# * https://github.com/brewster1134/tiler
# *
# * @version 0.2.3
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


    #
    # WIDGET SETUP/METHODS
    #
    widgetEventPrefix: 'tiler'
    options:
      reverseSupport: true

    _create: ->
      @$currentTileId = 0

    _init: ->
      # collect all the tiles, except for those nested inside another tiler instance
      @$tiles = $('.tiler-tile', @element).not(@element.find('.tiler-viewport .tiler-tile'))
      @_setupTiles()
      @_setupLinks()


    #
    # PUBLIC METHODS
    #
    refresh: ->
      @_init()
      @element.trigger 'tiler.refresh'
      @$enterTile.trigger 'tiler.refresh'

    goTo: (idOrIndex, activeClass) ->
      # detect tile id or coordinates
      if typeof idOrIndex == 'string'
        $tile = @$tiles.filter("##{idOrIndex}")
        tileId = @$tiles.index($tile) + 1
      else
        $tile = @$tiles.eq(idOrIndex - 1)
        tileId = idOrIndex

      # return if we are already on that tile
      return if @$currentTileId == tileId

      @$enterTile = $tile
      @$exitTile = @$tiles.eq(Math.max(0, @$currentTileId - 1))

      # set the active tile id to the viewport
      @element.attr 'data-tiler-active-tile', @$enterTile.attr('id')

      # allow false to disable the active class
      activeClass = 'no-active-class' if activeClass == false
      enterTileClass = activeClass || @$enterTile.data('tiler-active-class') || ''

      # order tiles
      @$enterTile.css
        display: 'block'
        zIndex: 2
      @$exitTile.css
        display: 'block'
        zIndex: 1
      @$tiles.not(@$enterTile).not(@$exitTile).css
        display: 'none'
        zIndex: -1

      # manage css classes if an one is specified
      @_transitionCss enterTileClass

      # fire js events
      # trigger on viewport
      @element.trigger 'tiler.goto',
        enterTile: @$enterTile
        exitTile: @$exitTile

      # trigger on individual tiles
      @$enterTile.trigger 'tiler.enter'
      @$exitTile.trigger 'tiler.exit'

      # update the current tile id
      @$currentTileId = tileId

      return @$enterTile


    #
    # PRIVATE METHODS
    #
    _transitionCss: (enterTileClass) ->
      enterTileId = @$tiles.index(@$enterTile, @$exitTile) + 1

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
      @$exitTile.attr 'class', "tiler-tile #{exitTileInitialState} #{enterTileClass}"

      # set enter tile start position
      # backup any transition data.  we need to set a start position without any animations
      #
      @$exitTile.data 'tilerTransition', @$exitTile.css('transition')
      @$exitTile.data 'tilerTransitionDuration', @$exitTile.css('transition-duration')
      @$exitTile.css 'transition-duration', 0
      @$exitTile.addClass exitTileInitialPosition
      @$exitTile.css
        transition: @$exitTile.data 'tilerTransition'
        'transition-duration': @$exitTile.data 'tilerTransitionDuration'

      # trigger the end position
      @$exitTile.switchClass exitTileInitialPosition, exitTileFinalPosition


      # ENTER TILE
      #

      # reset
      @$enterTile.attr 'class', "tiler-tile #{enterTileInitialState} #{enterTileClass}"

      # set enter tile start position
      # backup any transition data.  we need to set a start position without any animations
      #
      @$enterTile.data 'tilerTransition', @$enterTile.css('transition')
      @$enterTile.data 'tilerTransitionDuration', @$enterTile.css('transition-duration')
      @$enterTile.css 'transition-duration', 0
      @$enterTile.addClass enterTileInitialPosition
      @$enterTile.css
        transition: @$enterTile.data 'tilerTransition'
        'transition-duration': @$enterTile.data 'tilerTransitionDuration'

      # trigger the end position
      @$enterTile.addClass 'active'
      @$enterTile.switchClass enterTileInitialPosition, enterTileFinalPosition

    # find possible links throughout the entire page and set meta data on them
    #
    _setupLinks: ->
      $('[data-tiler-link]').each ->
        tileId = $(@).data('tiler-link').split(':')

        # check for tiler namespace
        if tileId.length == 2
          tilerInstance = $(".tiler-viewport##{tileId[0]}")
          tileInstance = $(".tiler-tile##{tileId[1]}", tilerInstance)
        else
          tileInstance = $(".tiler-tile##{tileId[0]}")

        return unless tileInstance.length

        # get tile data
        tileData = tileInstance.data()

        # remove reserved attributes
        delete tileData['tilerTransition']
        delete tileData['tilerTransitionDuration']

        # apply data to link
        $.extend $(@).data(), tileData

    # match all the tiles to the size of the viewport
    #
    _setupTiles: ->
      self = @

      @$tiles.each ->
        $(@).attr 'data-tiler-viewport-id', self.element.attr('id')

      @$tiles.css
        width: @element.outerWidth()
        height: @element.outerHeight()

    # determine if we are advancing or retreating through our virtual tiles
    #
    _isNavigatingForward: (enterTileId) ->
      enterTileId > @$currentTileId
