describe 'Tiler', ->
  describe 'initialize', ->
    before ->
      $('#initialize').tiler()

    it 'should size the tiles', ->
      expect($('#initialize .tiler-tile').css('width')).to.equal('200px')
      expect($('#initialize .tiler-tile').css('height')).to.equal('200px')

    describe '_buildLinks', ->
      it 'should add the title to the link', ->
        expect($('button').data('tiler-title')).to.equal 'Tile 1'

    context 'with option', ->
      describe 'initialTile', ->
        before ->
          $('#initial-tile').tiler
            initialTile: 1

        it 'should activate the initial tile', ->
          expect($('#initial-tile #tile-2').hasClass('active')).to.be.true

      describe 'reverseSupport', ->
        before ->
          $('#reverse-support').tiler
            initialTile: 0
            reverseSupport: true

        it 'should set the reverse classes', ->
          expect($('#reverse-support #tile-1').hasClass('exit')).to.be.true

  describe '.goTo', ->
    before ->
      $('#go-to').tiler
        initialTile: 0
      $('#go-to').tiler('goTo', 1)

    it 'should activate the tile', ->
      expect($('#go-to #tile-2').hasClass('active')).to.be.true
