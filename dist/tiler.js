// Generated by CoffeeScript 1.7.1

/*
 * * tiler
 * * https://github.com/brewster1134/tiler
 * *
 * * Copyright (c) 2014 Ryan Brewster
 * * Licensed under the MIT license.
 */

(function() {
  (function(root, factory) {
    if (typeof define === 'function' && define.amd) {
      return define(['jquery', 'widget'], function($) {
        return factory($);
      });
    } else {
      return factory(jQuery);
    }
  })(this, function($) {
    return $.widget('ui.tiler', {
      widgetEventPrefix: 'tiler',
      options: {
        tileSelector: '.tiler',
        initialTile: [1, 1]
      },
      _create: function() {
        this.grid = {};
        this.$currentTile = $('<div/>');
        return this.$tiles = $(this.options.tileSelector, this.element);
      },
      _init: function() {
        this._sizeTiles();
        this._buildGrid();
        return this.goToTile.apply(this, this.options.initialTile);
      },
      goToTile: function(row, col, direction) {
        var $enterTile, $exitTile, enterTileClass;
        $exitTile = this.$currentTile;
        $enterTile = this.grid[row][col];
        enterTileClass = $enterTile.data('tiler-active-class');
        this.$tiles.not($exitTile).not($enterTile).hide();
        $exitTile.attr('class', 'tiler exit');
        $exitTile.addClass(enterTileClass);
        $exitTile.data('tiler-transition', $exitTile.css('transition'));
        $exitTile.data('tiler-transition-duration', $exitTile.css('transition-duration'));
        $exitTile.css('transition-duration', 0);
        $exitTile.addClass('start');
        $exitTile.css({
          transition: $exitTile.data('tiler-transition'),
          transitionDuration: $exitTile.data('tiler-transition-duration')
        });
        $exitTile.show();
        setTimeout(function() {
          $exitTile.addClass('end');
          return $exitTile.removeClass('start');
        });
        $enterTile.attr('class', 'tiler enter');
        $enterTile.addClass(enterTileClass);
        $enterTile.data('tiler-transition', $enterTile.css('transition'));
        $enterTile.data('tiler-transition-duration', $enterTile.css('transition-duration'));
        $enterTile.css('transition-duration', 0);
        $enterTile.addClass('start');
        $enterTile.css({
          transition: $enterTile.data('tiler-transition'),
          transitionDuration: $enterTile.data('tiler-transition-duration')
        });
        $enterTile.show();
        setTimeout(function() {
          $enterTile.addClass('end');
          return $enterTile.removeClass('start');
        });
        this.$currentTile = $enterTile;
        return $enterTile;
      },
      _sizeTiles: function() {
        return this.$tiles.css({
          width: this.element.outerWidth(),
          height: this.element.outerHeight()
        });
      },
      _buildGrid: function() {
        var _this;
        _this = this;
        this.$tiles.each(function() {
          var col, row, _base;
          row = $(this).data('tiler-row') || (Object.keys(_this.grid).length + 1);
          col = Object.keys(_this.grid[row] || {}).length + 1;
          $(this).data('tiler-row', row);
          $(this).data('tiler-col', col);
          (_base = _this.grid)[row] || (_base[row] = {});
          return _this.grid[row][col] = $(this);
        });
        return this.grid;
      }
    });
  });

}).call(this);
