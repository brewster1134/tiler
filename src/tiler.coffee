###
# * tiler
# * https://github.com/brewster1134/tiler
# *
# * @version 1.0.4
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
      # Collect all the tiles, except for those nested inside another tiler instance
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

    goTo: (tile, animation = true) ->
      # Find tile
      # Tile id as string
      $tile = if typeof tile == 'string'
        @$tiles.filter("##{tile}")
      # Tile as jquery object
      else if tile.jquery
        tile.jquery
      # Tile as dom node
      else if tile.nodeType
        $(tile)
      # Tile as index (starting at 1)
      else
        @$tiles.eq(tile - 1)

      # Return if we are already on that tile
      tileId = @$tiles.index($tile) + 1
      return if @$currentTileId == tileId

      @$enterTile = $tile
      @$exitTile = @$tiles.eq(Math.max(0, @$currentTileId - 1))

      # Set the active tile id to the viewport
      @element.attr 'data-tiler-active-tile', @$enterTile.attr('id')

      # Manage css classes if an one is specified
      @_transitionCss @_getAnimationClass animation

      # Fire js events
      # Trigger on viewport
      @element.trigger 'tiler.goto',
        enterTile: @$enterTile
        exitTile: @$exitTile

      # Trigger on individual tiles
      @$enterTile.trigger 'tiler.enter'
      @$exitTile.trigger 'tiler.exit'

      # Update the current tile id
      @$currentTileId = tileId

      return @$enterTile

    #
    # PRIVATE METHODS
    #
    _getAnimationClass: (animation) ->
      # return explicitly passed animation
      return animation if typeof animation == 'string'

      # use animaton from markup if true, and no-active-class for false
      if animation
        @$enterTile.data('tiler-animation') || ''
      else
        'no-active-class'

    _transitionCss: (animationClass) ->
      enterTileId = @$tiles.index(@$enterTile, @$exitTile) + 1

      # check for custom reverse defined in markup
      if animationClass?.indexOf '<' > 0
        animationClass = if @_isNavigatingForward(enterTileId)
          animationClass.replace '<', ''
        else
          animationClass.replace '<', ' reverse'
        customReverse = true

      # Determine the direction of animation
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

      # Setup tiles without animations
      @$exitTile.add(@$enterTile).css
        'transition-duration': '0 !important'
        '-o-transition-duration': '0 !important'
        '-moz-transition-duration': '0 !important'
        '-webkit-transition-duration': '0 !important'

      # Add start state classes
      @$exitTile.attr 'class', "tiler-tile #{exitTileInitialState} #{exitTileInitialPosition} #{animationClass}"
      @$enterTile.attr 'class', "tiler-tile #{enterTileInitialState} #{enterTileInitialPosition} #{animationClass}"

      # Restore animation duration
      @$exitTile.add(@$enterTile).css
        'transition-duration': ''
        '-o-transition-duration': ''
        '-moz-transition-duration': ''
        '-webkit-transition-duration': ''

      # Swap classes to animate
      @$exitTile.switchClass exitTileInitialPosition, exitTileFinalPosition
      @$enterTile.switchClass enterTileInitialPosition, enterTileFinalPosition

    # Find possible links throughout the entire page and set meta data on them
    #
    _setupLinks: ->
      $('[data-tiler-link]').each ->
        tileId = $(@).data('tiler-link').split(':')

        # Check for tiler namespace
        if tileId.length == 2
          tilerInstance = $(".tiler-viewport##{tileId[0]}")
          tileInstance = $(".tiler-tile##{tileId[1]}", tilerInstance)
        else
          tileInstance = $(".tiler-tile##{tileId[0]}")

        return unless tileInstance.length

        # Get tile data
        tileData = tileInstance.data()

        # Remove reserved attributes
        delete tileData['tilerTransition']
        delete tileData['tilerTransitionDuration']

        # Apply data to link
        $.extend $(@).data(), tileData

    # Match all the tiles to the size of the viewport
    #
    _setupTiles: ->
      self = @
      maxWidth = []
      maxHeight = []

      # Remove assigned sizes from tiles
      @$tiles.css
        width: ''
        height: ''

      # Loop through all tiles
      @$tiles.each ->
        # Add natural dimensions to array to find largest height later
        maxWidth.push $(@).outerWidth()
        maxHeight.push $(@).outerHeight()

        # Add a data attribute with the viewport id
        $(@).attr 'data-tiler-viewport-id', self.element.attr('id')

      # Determine new sizes
      width = @element.outerWidth() || Math.max(maxWidth...)
      height = @element.outerHeight() || Math.max(maxHeight...) || width

      # Set sizes
      @element.add(@$tiles).css
        width: width
        height: height

    # Determine if we are advancing or retreating through our virtual tiles
    #
    _isNavigatingForward: (enterTileId) ->
      enterTileId > @$currentTileId
