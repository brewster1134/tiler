describe 'Tiler', ->
  describe 'initialize', ->
    before ->
      $('#initialize').tiler()

    it 'should size the tiles', ->
      expect($('#initialize > .tiler-tile').css('width')).to.equal '200px'
      expect($('#initialize > .tiler-tile').css('height')).to.equal '200px'

    it 'should not include tiles from nested tiler instances', ->
      expect($('#initialize > .tiler-tile').data 'tiler-viewport-id').to.equal 'initialize'
      expect($('#initialize-nested > .tiler-tile').data 'tiler-viewport-id').to.not.equal 'initialize'

    describe '_buildLinks', ->
      it 'should add tile data to the link', ->
        expect($('button').data('tiler-title')).to.equal 'Tile 1'
        expect($('button').data('tiler-foo')).to.equal 'Foo 1'

    context 'with option', ->
      describe 'reverseSupport', ->
        before ->
          $('#reverse-support').tiler
            reverseSupport: true
          $('#reverse-support').tiler('goTo', 2)
          $('#reverse-support').tiler('goTo', 1)

        it 'should set the reverse classes', ->
          expect($('#reverse-support #tile-1').hasClass('exit')).to.be.true

  describe 'goTo', ->
    # eventSpy = null
    eventSpy = sinon.spy()

    before ->
      $('#go-to').tiler()
      $('#go-to').tiler('goTo', 1)

      # setup event after initialize to only test the event being called on the goTo call
      $('#go-to').on 'tiler.goto', (e, data) ->
        eventSpy data.enterTile.attr('id'), data.exitTile.attr('id')

    after ->
      eventSpy.reset()

    it 'should set the active tile id on the viewport', ->
      expect($('#go-to').attr('data-tiler-active-tile')).to.equal 'tile-1'

    context 'without an active class', ->
      before ->
        $('#go-to').tiler('goTo', 2)

      it 'should activate the tile', ->
        expect($('#go-to #tile-2').hasClass('active')).to.be.true

      it 'should fire an event', ->
        expect(eventSpy).to.be.calledWith 'tile-2', 'tile-1'

    context 'with an active class', ->
      before ->
        $('#go-to').tiler('goTo', 1, 'foo-animation')

      it 'should add the active class', ->
        expect($('#go-to #tile-1').hasClass('foo-animation')).to.be.true

  describe 'refresh', ->
    @newWidth = null
    @newHeight = null

    before ->
      $('#refresh').tiler()
      $('#refresh').tiler('goTo', 'tile-2')

      @newWidth = $('#refresh').outerWidth() / 2
      @newHeight = $('#refresh').outerHeight() / 2

      $('#refresh').css
        width: @newWidth
        height: @newHeight

      $('#refresh').tiler('refresh')

    it 'should resize the tiles to match the viewport', ->
      expect($('#refresh .tiler-tile').outerWidth()).to.equal @newWidth
      expect($('#refresh .tiler-tile').outerHeight()).to.equal @newHeight

    it 'should stay on the current tiles', ->
      expect($('#refresh').attr('data-tiler-active-tile')).to.equal 'tile-2'
