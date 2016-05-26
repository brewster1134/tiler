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
      isReversible: true

    _create: ->
      @currentTileIndex = null

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
      # ...id as string
      $tile = if typeof tile == 'string'
        @$tiles.filter("##{tile}")

      # ...as jquery object
      else if tile?.jquery
        tile?.jquery

      # ...as dom node
      else if tile.nodeType
        $(tile)

      # ...as index (starting at 1)
      else
        @$tiles.eq tile - 1

      # Return if we are already on that tile
      tileIndex = @$tiles.index $tile
      return if !$tile.length || @currentTileIndex == tileIndex

      # Get animating tiles
      @$enterTile = $tile
      @$exitTile = @$tiles.eq @currentTileIndex

      @_transitionCss @_getAnimationClass animation

      # Fire js events
      # ...on viewport
      @element.trigger 'tiler.goto',
        enterTile: @$enterTile
        exitTile: @$exitTile

      # ...on animating tiles
      @$enterTile.trigger 'tiler.enter'
      @$exitTile.trigger 'tiler.exit'

      # Update the current tile id
      @currentTileIndex = tileIndex
      @element.attr 'data-tiler-active-tile', @$enterTile.attr('id')

      return @$enterTile

    #
    # PRIVATE METHODS
    #
    _getAnimationClass: (animation) ->
      # return explicitly passed animation
      return animation if typeof animation == 'string'

      # use animation from markup if true, and no-active-class for false
      if animation
        @$enterTile.data('tiler-animation') || @element.data('tiler-animation') || ''
      else
        ''

    _transitionCss: (animationClass) ->
      enterTileIndex = @$tiles.index @$enterTile

      # Add reverse class if supported and navigating in reverse order (according to the dom)
      reverseClass = if @options.isReversible && !@_isNavigatingForward(enterTileIndex)
        'reverse'
      else
        ''

      # Disable animations
      @element.addClass 'animation-disabled'

      # Build tile starting position animations classes
      enterStartClass = "tiler-tile #{animationClass} active enter #{reverseClass} start"
      exitStartClass = "tiler-tile #{animationClass} previous exit #{reverseClass} start"
      otherTileClass = 'tiler-tile'

      # Set tile classes
      @$enterTile.attr 'class', enterStartClass
      @$exitTile.attr 'class', exitStartClass
      @$tiles.not(@$enterTile).not(@$exitTile).attr 'class', otherTileClass

      # setTimeout needed to give the browser time to repaint the tiles (if neccessary) with the animation starting position
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
      tileWidths = [ @element.outerWidth() ]
      tileHeights = [ @element.outerHeight() ]

      # Remove any inline sizes from tiles
      @$tiles.css
        width: ''
        height: ''

      # Loop through all tiles
      @$tiles.each ->
        # Add natural dimensions
        tileWidths.push $(@).outerWidth()
        tileHeights.push $(@).outerHeight()

        # Add a data attribute with the viewport id
        $(@).attr 'data-tiler-viewport-id', self.element.attr('id')

      # Set sizes
      @element.add(@$tiles).css
        width: Math.max tileWidths...
        height: Math.max tileHeights...

    # Determine if we are advancing or retreating through our virtual tiles
    #
    _isNavigatingForward: (enterTileIndex) ->
      enterTileIndex > @currentTileIndex
