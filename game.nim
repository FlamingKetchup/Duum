import entity
export entities
from input import Action

type
  CollisionType = enum
    none, leftOrTop, rightOrBottom,

const moveSpeed = 5

var
  player = newEntity(0, 0, "player")
  platform = newEntity(50, 120, "platform")
  canJump = false

player.addVelocity()
player.addCollider(8, 8)

platform.addCollider(16, 16)

proc playerAction*(actions: set[Action]) =
  player.vel.x = 0
  if left in actions: player.vel.x = -moveSpeed
  if right in actions: player.vel.x = moveSpeed
  if jump in actions and canJump:
    player.vel.y = -15

proc collision(coord1, coord2: var int, half1, half2: int, vel: var int): CollisionType {.discardable.} =
  if coord1 + half1 + vel > coord2 - half2 and
      coord1 - half1 + vel < coord2 + half2:
    vel = 0
    if coord1 < coord2 - half2:
      coord1 = coord2 - half2 - half1
      result = leftOrTop
    elif coord1 > coord2 + half2:
      coord1 = coord2 + half2 + half1
      result = rightOrBottom
  else:
    coord1 += vel
    result = none

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
            if collision(entity.y, e.y, entity.col.halfH, e.col.halfH, entity.vel.y) == leftOrTop: canJump = true
            else: canJump = false
          else:
            canJump = false
            entity.y += entity.vel.y
    else:
      entity.x += entity.vel.x
      entity.y += entity.vel.y

    if entity.vel.y < 20: entity.vel.y = entity.vel.y + 1
