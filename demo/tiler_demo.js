// Generated by CoffeeScript 1.8.0
(function() {
  $(function() {
    $('.tiler-viewport').each(function() {
      return $(this).tiler().tiler('goTo', 1, false);
    });
    $('button[data-tiler-link]').each(function() {
      return $(this).text($(this).data('tiler-title'));
    });
    $('button').click(function() {
      var tileId;
      tileId = $(this).data('tiler-link');
      return $(this).closest('.tiler-viewport').tiler('goTo', tileId);
    });
    return $('#background').on('tiler.goto', function(e, data) {
      var x, y;
      switch (data.enterTile.attr('id')) {
        case 'tile-1':
          x = 0;
          y = 100;
          break;
        case 'tile-2':
          x = 50;
          y = 100;
          break;
        case 'tile-3':
          x = 50;
          y = 50;
          break;
        case 'tile-4':
          x = 50;
          y = 0;
      }
      return $(this).closest('.tiler-viewport').css({
        backgroundPosition: "" + x + "% " + y + "%"
      });
    });
  });

}).call(this);
