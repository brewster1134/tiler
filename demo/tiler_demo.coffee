$ ->
  # event to set background
  $('#background').on 'tiler.goto', (e, data) ->
    switch data.enterTile.attr('id')
      when 'tile-1'
        x = 0
        y = 100
      when 'tile-2'
        x = 50
        y = 100
      when 'tile-3'
        x = 50
        y = 50
      when 'tile-4'
        x = 50
        y = 0

    $(@).closest('.tiler-viewport').css
      backgroundPosition: "#{x}% #{y}%"

  # initalize tiler
  $('.tiler-viewport').tiler()

  # set the button text to match the tile title
  $('button[data-tiler-title]').each ->
    $(@).text($(@).data('tiler-title'))

  # go to a tile on click based on the link id
  $('button').click ->
    tileId = $(@).data('tiler-link-id')
    $(@).closest('.tiler-viewport').tiler('goTo', tileId)