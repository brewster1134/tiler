###
# * tiler
# * https://github.com/brewster1134/tiler
# *
# * Copyright (c) 2014 Ryan Brewster
# * Licensed under the MIT license.
###

((root, factory) ->
  if typeof define == 'function' && define.amd
    define [
      'jquery'
    ], ($) ->
      factory $
  else
    factory jQuery
) @, ($) ->

