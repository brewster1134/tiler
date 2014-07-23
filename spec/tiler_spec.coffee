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
          expect($('#initial-tile #tile-1').hasClass('active')).to.be.true

      describe 'reverseSupport', ->
        before ->
          $('#reverse-support').tiler
            initialTile: 2
            reverseSupport: true
          $('#reverse-support').tiler('goTo', 1)

        it 'should set the reverse classes', ->
          expect($('#reverse-support #tile-1').hasClass('exit')).to.be.true

  describe '.goTo', ->
    # eventSpy = null
    eventSpy = sinon.spy()

    before ->
      $('#go-to').tiler
        initialTile: 1

      # setup event after initialize to only test the event being called on the goTo call
      $('#go-to').on 'tiler.goto', (e, data) ->
        eventSpy data.enterTile.attr('id'), data.exitTile.attr('id')

      $('#go-to').tiler('goTo', 2)

    it 'should activate the tile', ->
      expect($('#go-to #tile-2').hasClass('active')).to.be.true

    it 'should fire an event', ->
      expect(eventSpy).to.be.calledWith 'tile-2', 'tile-1'
