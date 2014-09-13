# I'm Tiler.  I'm Perfect.
![Tiler](http://i.imgur.com/Kt5fVtz.gif)

## Dependencies
* jquery
* jquery ui

## Usage
#### Tiles Markup
```html
<div class="tiler-viewport">
  <div class="tiler-tile" id="tile-1"></div>
  <div class="tiler-tile" id="tile-2"></div>
</div>
```

#### CTA Markup
```html
<a data-tiler-link="tile-1"></a>
```

Any data attributes prefixed with `tiler` on the `.tiler-tile` elements, will be availble to the CTAs.

```html
<a class="tiler-link" data-tiler-link="tile-1"></a>
<div class="tiler-viewport">
  <div class="tiler-tile" id="tile-1" data-tiler-title="Tile One"></div>
</div>
```

```coffee
# sets the text of the CTA to match the title of the tile it links to
$('a.tiler-link').each ->
  $(@).text($(@).data('tiler-title'))
```

#### Methods
###### goTo
Navigate to a given tile based on it's ID or an index
> _Arguments_
```yaml
idOrIndex: html id value or index value (starts at 1 not 0)
```
---
> _Usage_
```haml
.tiler-viewport
  .tiler-tile#tile-1
```

```coffee
# with ID
$('.tiler-viewport').tiler 'goTo', 'tile-1'

# with index
$('.tiler-viewport').tiler 'goTo', 1
```

###### refresh
If the size of your tiler-viewport changes, you will need to refresh the containting tiles

---
> _Usage_
```coffee
$('.tiler-viewport').tiler 'refresh'
```

#### Events
###### tiler.goto
Called on `.tiler-viweport`
> _Data_
```yaml
enterTile: The currently active tile
exitTile: The previously active tile
```
---
> _Usage_
```coffee
$('.tiler-viewport').on 'tiler.goto', (e, data) ->
  console.log data.enterTile, data.exitTile
```

###### tiler.enter
Called on `.tiler-tile` when it becomes the active tile
```coffee
$('.tiler-tile').on 'tiler.enter', ->
  console.log 'Tile Entered'
```

###### tiler.exit
Called on `.tiler-tile` after being the active tile
```coffee
$('.tiler-tile').on 'tiler.exit', ->
  console.log 'Tile Exited'
```

## Development

### Dependencies

```shell
gem install yuyi
yuyi -m https://raw.githubusercontent.com/brewster1134/tiler/master/yuyi_menu
bundle install
npm install
bower install
```

Do **NOT** modify any `.js` files!  Modify the coffee files in the `src` directory.  Guard will watch for changes and compile them to the `lib` directory.

### Compiling & Testing
Run `testem`
