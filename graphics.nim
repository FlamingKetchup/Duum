# Graphics functions
# Majority of this is shamelessly pilfered from the examples
import tables, sdl2/sdl, sdl2/sdl_image
from entity import Entity

const
  Title = "Duum"
  ScreenWidth = 1280
  ScreenHeight = 720
  ScreenScale = 4
  WindowFlags = 0
  RendererFlags = RendererAccelerated or RendererPresentVsync

type
  Screen = object
    window: Window # Window pointer
    renderer: Renderer # Rendering state pointer
  Sprite = ref object
    texture: Texture
    w, h: int

var
  screen: Screen
  initialized = false
  sprites = initTable[string, Sprite]()


proc load(obj: var Sprite, file: string) =
  # Load texture to image
  obj.texture = screen.renderer.loadTexture(file)
  if obj.texture == nil:
    echo  "Can't load sprite %s: %s", file, sdl_image.getError()
  # Get image dimensions
  var w, h: cint
  if obj.texture.queryTexture(nil, nil, addr(w), addr(h)) != 0:
    echo "Can't get texture attributes: ", sdl.getError()
    sdl.destroyTexture(obj.texture)
  obj.w = w
  obj.h = h

proc render(obj: Sprite, x: int, y: int) =
  var rect = sdl.Rect(x: x - int(obj.w/2), y: y - int(obj.h/2), w: obj.w, h: obj.h)
  discard screen.renderer.renderCopy(obj.texture, nil, addr(rect))

proc initGraphics*() =
  # Initialization sequence
  # Init SDL
  if sdl.init(InitVideo) != 0:
    echo "ERROR: Can't initialize SDL: ", sdl.getError()

    if sdl_image.init(InitPng) != 0:
      echo "ERROR: Can't initialize SDL_Image: ", sdl.getError()

  # Create window
  screen.window = sdl.createWindow(
    Title,
    sdl.WindowPosUndefined,
    sdl.WindowPosUndefined,
    ScreenWidth,
    ScreenHeight,
    WindowFlags)
  if screen.window == nil:
    echo "ERROR: Can't create window: ", sdl.getError()

  # Create renderer
  screen.renderer = createRenderer(screen.window, -1, RendererFlags)
  if screen.renderer == nil:
    echo "ERROR: Can't create renderer: ", sdl.getError()

  # Set draw color
  if screen.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF) != 0:
    echo "ERROR: Can't set draw color: ", sdl.getError()

  discard screen.renderer.renderSetScale(ScreenScale, ScreenScale)

  initialized = true
  echo "SDL initialized successfully"

# Shutdown sequence
proc quitGraphics*() =
  screen.renderer.destroyRenderer()
  screen.window.destroyWindow()
  sdl.quit()
  echo "SDL shutdown completed"

proc draw*(entities: openArray[Entity], cameraCenter: Entity) =
  # Clear screen with draw color
  if not initialized:
    echo "Graphics are not initialized"
    return
  if screen.renderer.renderClear() != 0:
    echo "Warning: Can't clear screen: ", sdl.getError()

  for i in entities:
    if i.id notin sprites:
      var sprite = Sprite(texture: nil, w: 0, h: 0)
      sprite.load("assets/sprites/" & i.id & ".png")
      sprites[i.id] = sprite
    sprites[i.id].render(i.x - cameraCenter.x + int(ScreenWidth/2/ScreenScale),
                         i.y - cameraCenter.y + int(ScreenHeight/2/ScreenScale))

  screen.renderer.renderPresent()
