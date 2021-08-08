import action, entity

const moveSpeed = 5

var entities*: seq[Entity]

proc initEntity(x, y: int, id: string):Entity =
  result = Entity(x: x, y: y, id: id)
  entities.add(result)

var player = initEntity(0, 0, "player")

proc playerAction*(actions: set[Action]) =
  if left in actions: player.x -= moveSpeed
  if right in actions: player.x += moveSpeed
  if up in actions: player.y -= moveSpeed
  if down in actions: player.y += moveSpeed
  echo $player.x & ", " & $player.y
