// Generated by CoffeeScript 1.7.1

/*
 * * tiler
 * * https://github.com/brewster1134/tiler
 * *
 * * @version 0.0.2
 * * @author Ryan Brewster
 * * Copyright (c) 2014
 * * Licensed under the MIT license.
 */

(function() {
  (function(root, factory) {
    if (typeof define === 'function' && define.amd) {
      return define(['jquery', 'widget', 'effect'], function($) {
        return factory($);
      });
    } else {
      return factory(jQuery);
    }
  })(this, function($) {
    return $.widget('ui.tiler', {
      widgetEventPrefix: 'tiler',
      options: {
        initialTile: 1,
        reverseSupport: true
      },
      _create: function() {
        this.$currentTileId = 0;
        return this.$tiles = $('.tiler-tile', this.element);
      },
      _init: function() {
        this._sizeTiles();
        this._buildLinks();
        return this.goTo(this.options.initialTile, null);
      },
      goTo: function(idOrRow, activeClass) {
        var $enterTile, $exitTile, $tile, enterTileClass, tileId;
        if (typeof idOrRow === 'string') {
          $tile = this.$tiles.filter("#" + idOrRow);
          tileId = this.$tiles.index($tile) + 1;
        } else {
          $tile = this.$tiles.eq(idOrRow - 1);
          tileId = idOrRow;
        }
        if (this.$currentTileId === tileId) {
          return;
        }
        $enterTile = $tile;
        $exitTile = this.$tiles.eq(Math.max(0, this.$currentTileId - 1));
        if (activeClass === null || activeClass === '') {
          activeClass = 'no-active-class';
        }
        enterTileClass = activeClass || $enterTile.data('tiler-active-class') || '';
        $enterTile.css({
          zIndex: 2
        });
        $exitTile.css({
          zIndex: 1
        });
        this.$tiles.not($enterTile).not($exitTile).css({
          zIndex: -1
        });
        this._transitionCss($enterTile, $exitTile, enterTileClass);
        this.element.trigger('tiler.goto', {
          enterTile: $enterTile,
          exitTile: $exitTile
        });
        this.$currentTileId = tileId;
        return $enterTile;
      },
      _transitionCss: function($enterTile, $exitTile, enterTileClass) {
        var enterTileFinalPosition, enterTileId, enterTileInitialPosition, enterTileInitialState, exitTileFinalPosition, exitTileInitialPosition, exitTileInitialState;
        enterTileId = this.$tiles.index($enterTile, $exitTile) + 1;
        if (!this.options.reverseSupport || this._isNavigatingForward(enterTileId)) {
          exitTileInitialState = 'exit';
          exitTileInitialPosition = 'start';
          exitTileFinalPosition = 'end';
          enterTileInitialState = 'enter';
          enterTileInitialPosition = 'start';
          enterTileFinalPosition = 'end';
        } else {
          exitTileInitialState = 'enter';
          exitTileInitialPosition = 'end';
          exitTileFinalPosition = 'start';
          enterTileInitialState = 'exit';
          enterTileInitialPosition = 'end';
          enterTileFinalPosition = 'start';
        }
        $exitTile.attr('class', "tiler-tile " + exitTileInitialState + " " + enterTileClass);
        $exitTile.data('tiler-transition', $exitTile.css('transition'));
        $exitTile.data('tiler-transition-duration', $exitTile.css('transition-duration'));
        $exitTile.css('transition-duration', 0);
        $exitTile.addClass(exitTileInitialPosition);
        $exitTile.css({
          transition: $exitTile.data('tiler-transition'),
          transitionDuration: $exitTile.data('tiler-transition-duration')
        });
        $exitTile.switchClass(exitTileInitialPosition, exitTileFinalPosition);
        $enterTile.attr('class', "tiler-tile " + enterTileInitialState + " " + enterTileClass);
        $enterTile.data('tiler-transition', $enterTile.css('transition'));
        $enterTile.data('tiler-transition-duration', $enterTile.css('transition-duration'));
        $enterTile.css('transition-duration', 0);
        $enterTile.addClass(enterTileInitialPosition);
        $enterTile.css({
          transition: $enterTile.data('tiler-transition'),
          transitionDuration: $enterTile.data('tiler-transition-duration')
        });
        $enterTile.addClass('active');
        return $enterTile.switchClass(enterTileInitialPosition, enterTileFinalPosition);
      },
      _buildLinks: function() {
        var _this;
        _this = this;
        return $('[data-tiler-link-id]').each(function() {
          var tileId, tileInstance, tileTitle, tilerInstance;
          tileId = $(this).data('tiler-link-id').split(':');
          if (tileId.length === 2) {
            tilerInstance = $(".tiler-viewport#" + tileId[0]);
            tileInstance = $(".tiler-tile#" + tileId[1], tilerInstance);
          } else {
            tileInstance = $(".tiler-tile#" + tileId[0]);
          }
          tileTitle = tileInstance.data('tiler-title');
          return $(this).attr('data-tiler-title', tileTitle);
        });
      },
      _sizeTiles: function() {
        return this.$tiles.css({
          width: this.element.outerWidth(),
          height: this.element.outerHeight()
        });
      },
      _isNavigatingForward: function(enterTileId) {
        return enterTileId > this.$currentTileId;
      }
    });
  });

}).call(this);