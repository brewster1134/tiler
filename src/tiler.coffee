###
# * tiler
# * https://github.com/brewster1134/tiler
# *
# * @version 1.0.2
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
      @$enterTile?.trigger 'tiler.refresh'

    goTo: (tile, animation) ->
      # find tile
      # tile id as string
      $tile = if typeof tile == 'string'
        @$tiles.filter("##{tile}")
      # tile as jquery object
      else if tile.jquery
        tile.jquery
      # tile as dom node
      else if tile.nodeType
        $(tile)
      # tile as index (starting at 1)
      else
        @$tiles.eq(tile - 1)

      # return if we are already on that tile
      tileId = @$tiles.index($tile) + 1
      return if @$currentTileId == tileId

      @$enterTile = $tile
      @$exitTile = @$tiles.eq(Math.max(0, @$currentTileId - 1))

      # set the active tile id to the viewport
      @element.attr 'data-tiler-active-tile', @$enterTile.attr('id')

      # Set tile class
      animationClass = if animation == false
        'no-active-class'
      else
        animation || @$enterTile.data('tiler-animation') || ''

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
      @_transitionCss animationClass

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
    _transitionCss: (animationClass) ->
      enterTileId = @$tiles.index(@$enterTile, @$exitTile) + 1

      if animationClass?.indexOf '<' > 0
        animationClass = if @_isNavigatingForward(enterTileId)
          animationClass.replace '<', ''
        else
          animationClass.replace '<', ' reverse'
        customReverse = true

      # determine the direction of animation
      #
      if @_isNavigatingForward(enterTileId) || !@options.reverseSupport || !customReverse == true
        exitTileInitialState      = 'exit'
        exitTileInitialPosition   = 'start'
        exitTileFinalPosition     = 'end'

        enterTileInitialState     = 'enter'
        enterTileInitialPosition  = 'start'
        enterTileFinalPosition    = 'end active'

      else
        exitTileInitialState      = 'enter'
        exitTileInitialPosition   = 'end'
        exitTileFinalPosition     = 'start'

        enterTileInitialState     = 'exit'
        enterTileInitialPosition  = 'end'
        enterTileFinalPosition    = 'start active'

      # setup tiles without animations
      @$exitTile.add(@$enterTile).css
        'transition-duration': '0'
        '-o-transition-duration': '0'
        '-moz-transition-duration': '0'
        '-webkit-transition-duration': '0'

      # add start state classes
      @$exitTile.attr 'class', "tiler-tile #{exitTileInitialState} #{exitTileInitialPosition} #{animationClass}"
      @$enterTile.attr 'class', "tiler-tile #{enterTileInitialState} #{enterTileInitialPosition} #{animationClass}"

      # restore animation duration
      @$exitTile.add(@$enterTile).css
        'transition-duration': ''
        '-o-transition-duration': ''
        '-moz-transition-duration': ''
        '-webkit-transition-duration': ''

      # swap classes to animate
      @$exitTile.switchClass exitTileInitialPosition, exitTileFinalPosition
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
