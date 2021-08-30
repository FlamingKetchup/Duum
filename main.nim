import graphics, input, game

initGraphics()

while true:

  let actions = getActions()

  if exit in actions:
    quitGraphics()
    break

  playerAction(actions)
  update()

  drawEntities(entities)
