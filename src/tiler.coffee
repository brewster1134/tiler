###
# * tiler
# * https://github.com/brewster1134/tiler
# *
# * @version 2.0.4
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
      activeTile: 1
      isReversible: true

    _init: ->
      # Collect all the tiles, except for those nested inside another tiler instance
      @$tiles = $('.tiler-tile', @element).not(@element.find('.tiler-viewport .tiler-tile'))
      @$currentActiveTile ||= @_getTile @options.activeTile
      @$currentPreviousTile ||= @_getTile @_getTileIndex(@$currentActiveTile) + 1

      # Setup DOM elements
      @_setupTiles()
      @_setupLinks()

    #
    # PUBLIC Methods
    #
    refresh: ->
      @_init()
      @element.trigger 'tiler.refresh'
      @$enterTile?.trigger 'tiler.refresh'

    goTo: (tileValue, animation) ->
      # Get new active & previous tiles
      $enteringTile = @_getTile tileValue
      return unless $enteringTile.length
      $exitingTile = @$currentActiveTile

      if $enteringTile[0] == @$currentActiveTile[0]
        # Just finalize if we are already on the tile
        @_finalizeNewTiles $enteringTile, $exitingTile
      else
        # Update css classes for animation
        @_transitionCss $enteringTile, $exitingTile, animation

      return $enteringTile

    #
    # PRIVATE METHODS
    #

    # Find tile with various values
    #
    _getTile: (tileValue) ->
      $tile = switch typeof tileValue
        # jquery object or dom element
        when 'number'
          @$tiles.eq tileValue - 1
        when 'string'
          $("##{tileValue}", @element)
        else
          $(tileValue, @element)

      # if no tile is found, return the first tile
      if $tile.length
        $tile
      else
        @$tiles.eq 0

    # get HUMAN COUNTABLE index (eg starting at 1, not 0)
    #
    _getTileIndex: ($tile) ->
      @$tiles.index($tile) + 1

    _getAnimationClass: ($tile) ->
      $tile.data('tiler-animation') || @element.data('tiler-animation') || ''

    _transitionCss: ($enteringTile, $exitingTile, animation) ->
      # Get animation class
      animationClass = if typeof animation == 'string'
        animation
      else
        @_getAnimationClass $enteringTile

      # Get reverse class
      reverseClass = if @options.isReversible && @_getTileIndex($enteringTile) < @_getTileIndex(@$currentActiveTile)
        'reverse'
      else
        ''

      # Get position class
      positionClass = if animation == false
        'end'
      else
        'start'

      # Disable animations
      @element.addClass 'animation-disabled'

      # Build tile starting position animations classes
      $enteringTile.attr 'class', "tiler-tile #{animationClass} active enter #{reverseClass} #{positionClass}"
      $exitingTile.attr 'class', "tiler-tile #{animationClass} previous exit #{reverseClass} #{positionClass}"
      @$tiles.not($enteringTile).not($exitingTile).attr 'class', 'tiler-tile'

      # setTimeout needed to give the browser time to repaint the tiles (if neccessary) with the animation starting position
      if animation == false
        @_finalizeNewTiles $enteringTile, $exitingTile
      else
        setTimeout =>
          # Enable transitions
          @element.removeClass 'animation-disabled'

          # Replace position classes to trigger animation
          $enteringTile.add($exitingTile).switchClass 'start', 'end'

          @_finalizeNewTiles $enteringTile, $exitingTile
        , 10

    _finalizeNewTiles: ($enterTile, $exitTile) ->
      @$currentActiveTile = $enterTile
      @$currentPreviousTile = $exitTile
      @element.attr 'data-tiler-active-tile', @$currentActiveTile.attr('id')

      # Fire js events
      # ...on viewport
      @element.trigger 'tiler.goto',
        enterTile: $enterTile
        exitTile: $exitTile

      # ...on animating tiles
      $enterTile.trigger 'tiler.enter'
      $exitTile.trigger 'tiler.exit'

    # Setup tiles with neccessary meta data
    #
    _setupTiles: ->
      # Disable animations while we setup everything
      @element.addClass 'animation-disabled'

      # Add a data attribute with the viewport id
      @$tiles.attr 'data-tiler-viewport-id', @element.attr('id')

      # Set sizes
      @$tiles.css
        width: @element.outerWidth()
        height: @element.outerHeight()

      # Add active tile animation to both active and previous tiles
      @$currentActiveTile.add(@$currentPreviousTile).addClass @_getAnimationClass(@$currentActiveTile)

      # Setup active tile
      @$currentActiveTile.addClass 'active enter end'

      # Setup (fake) previous tile
      return if @$currentPreviousTile[0] == @$currentActiveTile[0]
      @$currentPreviousTile.addClass 'previous exit end'
      @$currentPreviousTile.addClass 'reverse' if @options.isReversible

    # Find possible links throughout the entire page and set meta data on them
    #
    _setupLinks: ->
      $('[data-tiler-link]').each ->
        # Get tile id (and optional tiler viewport id)
        tileIds = $(@).data('tiler-link').split(':').reverse()

        # Get tiler id
        tileId = tileIds[0]

        # Get the tile with matching id and viewport
        $tile = if tileIds[1]
          $(".tiler-tile##{tileId}", "##{tileIds[1]}")
        else
          $(".tiler-tile##{tileId}")

        return unless $tile.length

        # Apply tile data attributes to link
        $.extend $(@).data(), $tile.data()
