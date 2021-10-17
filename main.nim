import graphics, input, game

initGraphics()
generateLevel()

while true:

  let actions = getActions()

  if exit in actions:
    quitGraphics()
    break

  playerAction(actions)
  cumulativeUpdate()

  entities.draw(player)
