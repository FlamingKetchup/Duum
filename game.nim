import entity
export entities
from input import Action

const moveSpeed = 5

var
  player = newEntity(0, 0, "player")
  platform = newEntity(200, 400, "platform")
  jumpDelay = 0

player.addVelocity()
player.addCollider(48, 64)

platform.addCollider(50, 50)

proc playerAction*(actions: set[Action]) =
  player.vel.x = 0
  if left in actions: player.vel.x = -moveSpeed
  if right in actions: player.vel.x = moveSpeed
  if jump in actions and jumpDelay == 0:
    player.vel.y = -20
    jumpDelay = 35

proc collision(coord1, coord2: var int, half1, half2: int, vel: var int) =
  if coord1 + half1 + vel > coord2 - half2 and
      coord1 - half1 + vel < coord2 + half2:
    vel = 0
    if coord1 < coord2 - half2:
      coord1 = coord2 - half2 - half1
    elif coord1 > coord2 + half2:
      coord1 = coord2 + half2 + half1
  else:
    coord1 += vel

proc update*() =
  for entity in velocityEntities:
    if entity in colliderEntities:
      for e in colliderEntities:
        if e != entity:
          if abs(entity.y - e.y) < entity.col.halfH + e.col.halfH:
            collision(entity.x, e.x, entity.col.halfW, e.col.halfW, entity.vel.x)
          else:
            entity.x += entity.vel.x
          if abs(entity.x - e.x) < entity.col.halfW + e.col.halfW:
            collision(entity.y, e.y, entity.col.halfH, e.col.halfH, entity.vel.y)
          else:
            entity.y += entity.vel.y
    else:
      entity.x += entity.vel.x
      entity.y += entity.vel.y

    if entity.vel.y < 20: entity.vel.y = entity.vel.y + 1
    if jumpDelay > 0: jumpDelay -= 1
