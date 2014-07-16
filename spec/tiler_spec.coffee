describe 'Tiler', ->
  tiler = null

  before ->
    tiler = new Tiler
      foo: 'bar'

  it 'should initialize with options', ->
    expect(tiler).to.exist
    expect(tiler.options.foo).to.equal 'bar'

  describe '#buildGrid', ->
    it 'should build a grid based on markup', ->
      grid = tiler.buildGrid()
      expect(grid[0][0]).to.exist
      expect(grid[1][0]).to.exist
      expect(grid[1][1]).to.exist
      expect(grid[2][0]).to.exist
