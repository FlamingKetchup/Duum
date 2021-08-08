import sdl2/sdl, action, tables

const keybindings = {exit: @[K_ESCAPE],
                     left: @[K_a, K_LEFT],
                     right: @[K_d, K_RIGHT],
                     up: @[K_w, K_UP],
                     down: @[K_s, K_DOWN]}.toTable

proc getActions*(): set[Action] =
  var e: Event

  if pollEvent(addr(e)) != 0:
    if e.kind == Quit: result = result + {exit}

  let keyboard = sdl.getKeyboardState(nil)

  for action, keys in keybindings.pairs:
    for keybind in keys:
      if keyboard[getScancodeFromKey(keybind)] > 0:
        result = result + {action}
