# I'm Tiler.  I'm Perfect.
![Tiler](http://i.imgur.com/Kt5fVtz.gif)

## Dependencies
* jquery
* jquery ui

## Usage
### Tiles Markup

Define several `.tiler-tile` elements inside a single `.tiler-viewport` element.
* `tiler-animation` is the class that will be toggled to allow CSS animations or styles.
* If you use custom reverse styles, you need to signify that to tiler by appeneding a `<` to the class name __(example below)__

_Do __NOT__ add any additional classes to the `tiler-tile` elements.  They __WILL__ be overwritten._


```html
<div class="tiler-viewport">
  <div class="tiler-tile" data-tiler-animation="slide-horizontal" id="tile-1"></div>
  <div class="tiler-tile" data-tiler-animation="slide-vertical" id="tile-2"></div>

  <!-- note the `less-than` sign in the animation name -->
  <!-- that means this animation has a custom reverse defined -->
  <div class="tiler-tile" data-tiler-animation="fade<" id="tile-2"></div>
</div>
```

### CTA Markup

You can access tile data from an element by adding the `data-tiler-link` attribute.  Any element with this attribute, will have available all the data attributes from the tile prefixed with `tiler`.  This can be helpful when making custom links that navigate to a tile.

For example, if we want to make the CTA text match the name of the tile...

```html
<a class="tiler-link" data-tiler-link="tile-1"></a>
<div class="tiler-viewport">
  <div class="tiler-tile" id="tile-1" data-tiler-title="Tile One"></div>
</div>
```

```coffee
# sets the text of the CTA to match the title of the tile it links to
$('a.tiler-link').each ->
  title = $(@).data('tiler-title')
  $(@).text(title)
```

### CSS Animation Markup

Tiler animations can be easily defined with a simple convention in your CSS.

* `enter` the new tile becoming active
* `exit`  the previously active tile, that is becoming inactive
* `start` the beginning state of a CSS animation
  * This property is treated like a reset. If you use multiple animations, you need to make sure this property will reset ALL styles a given tile may be involved with.  For example if you animate using `top`, but you are defining a new animation that animates with `left`, you still need to set `top` to `0` in case it was set to something else from a _different_ animation. __<sup>example below -1-</sup>__
* `end`   the end state of a CSS animation
* `reverse` tiler can automatically reverse animations by switching using `start` as the `end` state, and vice-versa.  If you need to customize the reverse, you can nest additional animations under a `reverse` class.  __<sup>example below -2-</sup>__
* Only define `transition-property` on the specific animations, and only for the specific attributes you are animating. __<sup>example below -3-</sup>__

```sass
.tiler-tile

  // animation attributes
  // -3- `no transition-property` defined at this level
  transition-duration: 25s
  transition-timing-function: linear

  // slide left (slide in from the right)
  &.slide-horizontal

    // -3- `transition-property` defined only for the animation and attribute neccessary
    transition-property: left

    // -1- set to 0 in case we animate from `slide-vertical`
    top: 0

    &.enter
      &.start
        left: 100%
      &.end
        left: 0%
    &.exit
      &.start
        left: 0%
      &.end
        left: -100%

// slide up (slide in from the bottom)
&.slide-vertical

  // -3- `transition-property` defined only for the animation and attribute neccessary
  transition-property: top

  // -1- set to 0 in case we animate from `slide-horizontal`
  left: 0

  &.enter
    &.start
      top: 100%
    &.end
      top: 0%
  &.exit
    &.start
      top: 0%
    &.end
      top: -100%

&.fade

  // -3- `transition-property` defined only for the animation and attribute neccessary
  transition-property: opacity

  // -1- set to 0 in case we animate from `slide-horizontal` or `slide-vertical`
  top: 0
  left: 0

  &.enter
    &.start
      opacity: 0
    &.end
      opacity: 1
  &.exit
    &.start
      opacity: 1
    &.end
      opacity: 1

  // -2- reverse styles for when using the `<` convention (e.g. `fade<`)
  &.reverse
    &.enter
      &.start
        opacity: 1
      &.end
        opacity: 1
    &.exit
      &.start
        opacity: 1
      &.end
        opacity: 0
```

### Methods
#### goTo
Navigate to a given tile based on it's ID or an index
> _Arguments_

>```yaml
tile: html id value or index value (starts at 1 not 0) of a tile
activeClass: name of a CSS class to toggle for animations.
  * if nothing is passed, it checks for the `tiler-animation` data attribute on the tile
  * use `false` to disable animation
```
---
> _Usage_

>```coffee
# with ID
$('.tiler-viewport').tiler 'goTo', 'tile-1'
# with index
$('.tiler-viewport').tiler 'goTo', 1
```

#### refresh
If the size of your tiler-viewport changes, you will need to refresh the containting tiles

---
> _Usage_

>```coffee
$('.tiler-viewport').tiler 'refresh'
```

### Events
##### tiler.goto
Called on `.tiler-viweport`
> _Data_

>```yaml
enterTile: The currently active tile
exitTile: The previously active tile
```
---
> _Usage_
>```coffee
$('.tiler-viewport').on 'tiler.goto', (e, data) ->
  console.log data.enterTile, data.exitTile
```

#### tiler.enter
Called on `.tiler-tile` when it becomes the active tile
```coffee
$('.tiler-tile').on 'tiler.enter', ->
  console.log 'Tile Entered'
```

##### tiler.exit
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
