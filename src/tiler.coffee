###
# * tiler
# * https://github.com/brewster1134/tiler
# *
# * @version 2.0.1
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
      isReversible: true
      startingActiveTile: 1
      startingPreviousTile: 2

    _create: ->
      @currentActiveTileIndex = @options.startingActiveTile
      @currentPreviousTileIndex = @options.startingPreviousTile

    _init: ->
      @element.addClass 'animation-disabled'

      # Collect all the tiles, except for those nested inside another tiler instance
      @$tiles = $('.tiler-tile', @element).not(@element.find('.tiler-viewport .tiler-tile'))
      @$enterTile = @$tiles.eq @currentActiveTileIndex - 1
      @$exitTile = @$tiles.eq @currentPreviousTileIndex - 1

      @_setupTiles()
      @_setupLinks()

    #
    # PUBLIC METHODS
    #
    refresh: ->
      @_init()
      @element.trigger 'tiler.refresh'
      @$enterTile?.trigger 'tiler.refresh'

    # Find tile with various values
    #
    _getTile: (tileValue) ->
      # ...as a css ID (String)
      if typeof tileValue == 'string'
        $("##{tileValue}", @element)

      # ...as jquery object
      else if tileValue.jquery
        tileValue.jquery

      # ...as dom node
      else if tileValue.nodeType
        $(tileValue)

      # ...as index (starting at 1)
      else
        @$tiles.eq tileValue - 1

    goTo: (tile, animation) ->
      # New active tile
      @$enterTile = @_getTile tile
      enterTileIndex = @$tiles.index @$enterTile
      @$exitTile = @_getTile @currentActiveTileIndex + 1

      # Return if we are already on that tile
      return if !@$enterTile.length || @currentActiveTileIndex == enterTileIndex

      @_transitionCss @_getAnimationClass(), animation

      # Fire js events
      # ...on viewport
      @element.trigger 'tiler.goto',
        enterTile: @$enterTile
        exitTile: @$exitTile

      # ...on animating tiles
      @$enterTile.trigger 'tiler.enter'
      @$exitTile.trigger 'tiler.exit'

      # Update the current tile id
      @currentActiveTileIndex = enterTileIndex
      @currentPreviousTileIndex = @currentActiveTileIndex
      @element.attr 'data-tiler-active-tile', @$enterTile.attr('id')

      return @$enterTile

    #
    # PRIVATE METHODS
    #
    _getAnimationClass: ->
      @$enterTile.data('tiler-animation') || @element.data('tiler-animation') || ''

    _transitionCss: (animationClass, animation) ->
      animationClass = animation if typeof animation == 'string'

      position = if animation == false
        'end'
      else
        'start'

      enterTileIndex = @$tiles.index @$enterTile

      # Add reverse class if supported and navigating in reverse order (according to the dom)
      reverseClass = if @options.isReversible && !@_isNavigatingForward(enterTileIndex)
        'reverse'
      else
        ''

      # Disable animations
      @element.addClass 'animation-disabled'

      # Build tile starting position animations classes
      enterStartClass = "tiler-tile #{animationClass} active enter #{reverseClass} #{position}"
      exitStartClass = "tiler-tile #{animationClass} previous exit #{reverseClass} #{position}"
      otherTileClass = 'tiler-tile'

      # Set tile classes
      @$enterTile.attr 'class', enterStartClass
      @$exitTile.attr 'class', exitStartClass
      @$tiles.not(@$enterTile).not(@$exitTile).attr 'class', otherTileClass

      # setTimeout needed to give the browser time to repaint the tiles (if neccessary) with the animation starting position
      unless animation == false
        setTimeout =>
          # Enable transitions
          @element.removeClass 'animation-disabled'

          # Replace position classes to trigger animation
          @$enterTile.add(@$exitTile).switchClass 'start', 'end'
        , 10

    # Find possible links throughout the entire page and set meta data on them
    #
    _setupLinks: ->
      $('[data-tiler-link]').each ->
        # Get tile id (and optional tiler viewport id)
        tileIds = $(@).data('tiler-link').split(':').reverse()

        # Get tiler id
        tileId = tileIds[0]

        # Get the tile with matching id and viewport
        tile = if tileIds[1]
          $(".tiler-tile##{tileId}", "##{tileIds[1]}")
        else
          $(".tiler-tile##{tileId}")

        return unless tile.length

        # Apply tile data attributes to link
        $.extend $(@).data(), tile.data()

    # Match all the tiles to the size of the viewport
    #
    _setupTiles: ->
      self = @

      # Loop through all tiles
      @$tiles.each ->
        # Add a data attribute with the viewport id
        $(@).attr 'data-tiler-viewport-id', self.element.attr('id')

        # Add animation class
        $(@).addClass self._getAnimationClass(true)

      # Set sizes
      @element.add(@$tiles).css
        width: @element.outerWidth()
        height: @element.outerHeight()

    # Determine if we are advancing or retreating through our virtual tiles
    #
    _isNavigatingForward: (enterTileIndex) ->
      enterTileIndex > @currentActiveTileIndex
