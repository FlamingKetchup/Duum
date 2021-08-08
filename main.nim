import graphics, input, action, game

initGraphics()

while true:

  drawEntities(entities)

  let actions = getActions()

  if exit in actions:
    quitGraphics()
    break

  playerAction(actions)
