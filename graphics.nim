# Vast majority of this is shamelessly pilfered from the examples
import sdl2/sdl, sdl2/sdl_image

const
  Title = "Duum"
  ScreenWidth = 1280 # Window width
  ScreenHeight = 720 # Window height
  WindowFlags = 0
  RendererFlags = RendererAccelerated or RendererPresentVsync

type
  Screen = ref ScreenObj
  ScreenObj = object
    window: Window # Window pointer
    renderer: Renderer # Rendering state pointer
  Image = ref ImageObj
  ImageObj = object of RootObj
    texture: Texture # Image texture
    w, h: int

var screen = Screen(window: nil, renderer: nil)

proc init*() =
  # Initialization sequence
  # Init SDL
  if sdl.init(InitVideo) != 0:
    echo "ERROR: Can't initialize SDL: ", sdl.getError()

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

  echo "SDL initialized successfully"

# Shutdown sequence
proc exit*() =
  screen.renderer.destroyRenderer()
  screen.window.destroyWindow()
  sdl.quit()
  echo "SDL shutdown completed"
  system.quit()

proc load(obj: Image, renderer: Renderer, file: string): bool =
  result = true
  # Load image to texture
  obj.texture = renderer.loadTexture(file)
  if obj.texture == nil:
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't load image %s: %s",
                    file, sdl_image.getError())
    return false
  # Get image dimensions
  var w, h: cint
  if obj.texture.queryTexture(nil, nil, addr(w), addr(h)) != 0:
    sdl.logCritical(sdl.LogCategoryError,
                    "Can't get texture attributes: %s",
                    sdl.getError())
    sdl.destroyTexture(obj.texture)
    return false
  obj.w = w
  obj.h = h

proc clearScreen*() =
  # Clear screen with draw color
  if screen.renderer.renderClear() != 0:
    echo "Warning: Can't clear screen: ", sdl.getError()

proc updateScreen*() =
  screen.renderer.renderPresent()

# proc drawScreen*() =
