describe 'Tiler', ->
  tiler = null

  before ->
    tiler = $('.tiler-viewport').tiler()

  describe '#buildGrid', ->
    it 'should build a grid based on markup', ->
      expect($('.tiler', tiler).eq(0).data('tiler-row')).to.equal 1
      expect($('.tiler', tiler).eq(0).data('tiler-col')).to.equal 1

      expect($('.tiler', tiler).eq(1).data('tiler-row')).to.equal 2
      expect($('.tiler', tiler).eq(1).data('tiler-col')).to.equal 1

      expect($('.tiler', tiler).eq(2).data('tiler-row')).to.equal 2
      expect($('.tiler', tiler).eq(2).data('tiler-col')).to.equal 2

      expect($('.tiler', tiler).eq(3).data('tiler-row')).to.equal 3
      expect($('.tiler', tiler).eq(3).data('tiler-col')).to.equal 1
