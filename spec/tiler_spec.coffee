describe 'Tiler', ->
  describe 'initialize', ->
    before ->
      $('#initialize').tiler()

    it 'should not include tiles from nested tiler instances', ->
      expect($('#initialize > .tiler-tile').data 'tiler-viewport-id').to.equal 'initialize'
      expect($('#initialize-nested > .tiler-tile').data 'tiler-viewport-id').to.not.equal 'initialize'

    describe '_buildLinks', ->
      it 'should add tile data to the link', ->
        expect($('button').data('tiler-title')).to.equal 'Tile 1'
        expect($('button').data('tiler-foo')).to.equal 'Foo 1'

    context 'with options', ->
      describe 'reverseSupport', ->
        before ->
          $('#reverse-support').tiler
            reverseSupport: true
          $('#reverse-support').tiler('goTo', 2, 'fade<')
          $('#reverse-support').tiler('goTo', 1, 'fade<')

        it 'should set the reverse classes', ->
          expect($('#reverse-support #tile-1').hasClass('exit')).to.be.true

    describe '_setupTiles', ->
      context 'when viewport has a height', ->
        before ->
          $('#viewport-height').tiler()

        it 'should match the tiles size to the viewport size', ->
          expect($('#viewport-height .tiler-tile').outerWidth()).to.equal 321
          expect($('#viewport-height .tiler-tile').outerHeight()).to.equal 123

      context 'when tiles have a height', ->
        before ->
          $('#tile-height').tiler()

        it 'should match the tiles size to the largest tile size', ->
          # can't explain this. even though these get tested AFTER $.css sets width & height, the computed sizes don't reflect it right away
          setTimeout ->
            expect($('#tile-height #tile-1').outerWidth()).to.equal 432
            expect($('#tile-height #tile-1').outerHeight()).to.equal 432
            expect($('#tile-height #tile-2').outerWidth()).to.equal 432
            expect($('#tile-height #tile-2').outerHeight()).to.equal 432

  describe 'goTo', ->
    eventSpy = null

    before ->
      eventSpy = sinon.spy()
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

    context 'when passing a boolean to active class', ->
      before ->
        $('#tile-1', '#go-to').data 'tiler-animation', 'goto-animate-1'
        $('#tile-2', '#go-to').data 'tiler-animation', 'goto-animate-2'

      context 'when passing true', ->
        before ->
          $('#go-to').tiler('goTo', 2, true)

        it 'should add the active class from the first tile', ->
          expect($('#go-to #tile-2').hasClass('goto-animate-2')).to.be.true

      context 'when passing false', ->
        before ->
          $('#go-to').tiler('goTo', 1, false)

        it 'should add the active class', ->
          expect($('#go-to #tile-1').hasClass('no-active-class')).to.be.true

  describe 'refresh', ->
    newWidth = null
    newHeight = null

    before ->
      $('#refresh').tiler()
      $('#refresh').tiler('goTo', 'tile-2')
      $('#refresh').tiler('refresh')

    it 'should stay on the current tile', ->
      expect($('#refresh').attr('data-tiler-active-tile')).to.equal 'tile-2'
