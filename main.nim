import graphics
import sdl2/sdl

while true:
  clearScreen()
  updateScreen()

  var e: Event

  while pollEvent(addr(e)) != 0:
      case e.kind
      of Quit: exit()
      of KeyDown:
        case e.key.keysym.sym
        of K_Escape: exit()
        else: discard
      else: discard

exit()
