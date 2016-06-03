describe 'Tiler', ->
  $tiler = null

  describe 'initialize', ->
    before ->
      $tiler = $('#initialize')
      $tiler.tiler
        activeTile: 1
        isReversible: true

    it 'should not include tiles from nested tiler instances', ->
      expect($('.tiler-tile', $tiler).data 'tiler-viewport-id').to.equal 'initialize'
      expect($('#initialize-nested > .tiler-tile').data 'tiler-viewport-id').to.be.undefined

    it 'should setup enter and exit tiles', ->
      # tile 1
      $activeTile = $('#tile-initialize-1', $tiler)
      expect($activeTile).to.have.class 'tile-initialize-1-animation'
      expect($activeTile).to.have.class 'active'
      expect($activeTile).to.have.class 'enter'
      expect($activeTile).to.have.class 'end'
      expect($activeTile).to.not.have.class 'previous'
      expect($activeTile).to.not.have.class 'exit'
      expect($activeTile).to.not.have.class 'start'
      expect($activeTile).to.not.have.class 'reverse'

      # tile 2
      $previousTile = $('#tile-initialize-2', $tiler)
      expect($previousTile).to.have.class 'tile-initialize-1-animation'
      expect($previousTile).to.have.class 'previous'
      expect($previousTile).to.have.class 'exit'
      expect($previousTile).to.have.class 'end'
      expect($previousTile).to.have.class 'reverse'
      expect($previousTile).to.not.have.class 'active'
      expect($previousTile).to.not.have.class 'enter'
      expect($previousTile).to.not.have.class 'start'

    it 'should match the tiles size to the viewport size', ->
      expect($('.tiler-tile', $tiler).outerWidth()).to.equal 321
      expect($('.tiler-tile', $tiler).outerHeight()).to.equal 123

    it 'should add tile data to the link', ->
      $button = $('button')
      expect($button.data('tiler-title')).to.equal 'Tile Initialize 2 Title'
      expect($button.data('tiler-animation')).to.equal 'tile-initialize-2-animation'

    context 'with custom activeTile', ->
      before ->
        $tiler = $('#active-tile')
        $tiler.tiler
          activeTile: 2

      it 'should set the active & pervious tiles', ->
        expect($('#tile-active-tile-2', $tiler)).to.have.class 'active'
        expect($('#tile-active-tile-2', $tiler)).to.not.have.class 'previous'
        expect($('#tile-active-tile-1', $tiler)).to.have.class 'previous'
        expect($('#tile-active-tile-1', $tiler)).to.not.have.class 'active'

  describe 'goTo', ->
    before ->
      $tiler = $('#go-to')
      $tiler.tiler()
      $tiler.tiler 'goTo', 2, false

    it 'should set the active tile id on the viewport', ->
      expect($tiler.attr('data-tiler-active-tile')).to.equal 'tile-go-to-2'

    context 'when going to the current tile', ->
      currentTileViewportSpy = null

      before ->
        currentTileViewportSpy = sinon.spy()
        $tiler = $('#current-tile')
        $tiler.one 'tiler.goto', (e, data) ->
          currentTileViewportSpy data

        $tiler.tiler()
        $tiler.tiler 'goTo', 1, false

      it 'should not fire events', ->
        expect(currentTileViewportSpy).to.not.be.called

      it 'should not update the tile classes', ->
        # tile 1
        expect($('#tile-current-tile-1', $tiler)).to.have.class 'active'
        expect($('#tile-current-tile-1', $tiler)).to.have.class 'enter'
        expect($('#tile-current-tile-1', $tiler)).to.not.have.class 'previous'
        expect($('#tile-current-tile-1', $tiler)).to.not.have.class 'exit'

        # tile 2
        expect($('#tile-current-tile-2', $tiler)).to.have.class 'previous'
        expect($('#tile-current-tile-2', $tiler)).to.have.class 'exit'
        expect($('#tile-current-tile-2', $tiler)).to.not.have.class 'active'
        expect($('#tile-current-tile-2', $tiler)).to.not.have.class 'enter'

    context 'with events', ->
      viewportEventSpy = null
      enterTileSpy = null
      exitTileSpy = null

      before ->
        viewportEventSpy = sinon.spy()
        $tiler = $('#events')
        $tiler.one 'tiler.goto', (e, data) ->
          viewportEventSpy data.enterTile.attr('id'), data.exitTile.attr('id')

        enterTileSpy = sinon.spy()
        $('#tile-events-2', $tiler).one 'tiler.enter', ->
          enterTileSpy $(@).attr('id')

        exitTileSpy = sinon.spy()
        $('#tile-events-1', $tiler).one 'tiler.exit', ->
          exitTileSpy $(@).attr('id')

        $tiler.tiler()
        $tiler.tiler 'goTo', 2, false

      it 'should fire event on viewport', ->
        expect(viewportEventSpy).to.be.calledWith 'tile-events-2', 'tile-events-1'

      it 'should fire event on enter tile', ->
        expect(enterTileSpy).to.be.calledWith 'tile-events-2'

      it 'should fire event on exit tile', ->
        expect(exitTileSpy).to.be.calledWith 'tile-events-1'

    context 'isReversible', ->
      context 'is true', ->
        before ->
          $tiler = $('#is-reversible')
          $tiler.tiler
            isReversible: true
          $tiler.tiler 'goTo', 2, false
          $tiler.tiler 'goTo', 1, false

        it 'should set the reverse class', ->
          expect($('#tile-is-reversible-1', $tiler)).to.have.class 'reverse'
          expect($('#tile-is-reversible-2', $tiler)).to.have.class 'reverse'

      context 'is false', ->
        before ->
          $tiler.tiler
            isReversible: false
          $tiler.tiler 'goTo', 2, false
          $tiler.tiler 'goTo', 1, false

        it 'should set the reverse class', ->
          expect($('#tile-is-reversible-1', $tiler)).to.not.have.class 'reverse'
          expect($('#tile-is-reversible-2', $tiler)).to.not.have.class 'reverse'

    context 'with a custom animation', ->
      before ->
        clock = sinon.useFakeTimers()
        $tiler = $('#custom-animation')
        $tiler.tiler()
        $tiler.tiler 'goTo', 2, 'foo-animation'
        clock.tick 10

      it 'should enable animation', ->
        expect($tiler).to.not.have.class 'animation-disabled'

      it 'should add the animation class', ->
        expect($('#tile-custom-animation-2', $tiler)).to.have.class 'foo-animation'
        expect($('#tile-custom-animation-1', $tiler)).to.have.class 'foo-animation'

    context 'when animation is true or not passed', ->
      before ->
        clock = sinon.useFakeTimers()
        $tiler = $('#animation-true-or-undefined')
        $tiler.tiler()
        $tiler.tiler 'goTo', 2, true
        clock.tick 10

      it 'should enable animation', ->
        expect($tiler).to.not.have.class 'animation-disabled'

      it 'should use the animation of the tile', ->
        expect($('#tile-animation-true-or-undefined-1', $tiler)).to.have.class 'tile-animation-true-or-undefined-animation-2'
        expect($('#tile-animation-true-or-undefined-2', $tiler)).to.have.class 'tile-animation-true-or-undefined-animation-2'

    context 'when animation is false', ->
      before ->
        $tiler = $('#animation-false')
        $tiler.tiler()
        $tiler.tiler 'goTo', 2, false

      it 'should not enable animation', ->
        expect($tiler).to.have.class 'animation-disabled'

  describe 'refresh', ->
    before ->
      $tiler = $('#refresh')
      $tiler.tiler()
      $tiler.tiler 'goTo', 2, false
      $tiler.tiler 'refresh'

    it 'should stay on the current tile', ->
      expect($tiler.attr('data-tiler-active-tile')).to.equal 'tile-refresh-2'
