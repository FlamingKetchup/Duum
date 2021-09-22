import entity, std/monotimes
export entities
from input import Action

type
  AxialCollisionType = enum
    noAxialCollision, leftOrTop, rightOrBottom
  CollisionType = enum
    noCollision, left, right, top, bottom

const moveSpeed = 5

let startTime = getMonoTime()

var
  player = newEntity(50, 10, "player")
  platform = newEntity(50, 120, "platform")
#  platform1 = newEntity(120, 100, "platform")
  canJump = false
  lastUpdate = getMonoTime()
  updates = 0

player.addVelocity()
player.addCollider(8, 8)

platform.addCollider(32, 8)
#platform1.addCollider(32, 8)

proc playerAction*(actions: set[Action]) =
  player.vel.x = 0
  if Action.left in actions: player.vel.x = -moveSpeed
  if Action.right in actions: player.vel.x = moveSpeed
  if jump in actions and canJump:
    player.vel.y = -12

proc axialCollide(coord1, coord2: int, half1, half2: int, vel: int): AxialCollisionType =
  if coord1 + half1 + vel > coord2 - half2 and coord1 - half1 + vel < coord2 + half2:
    if coord1 < coord2 - half2:
      result = leftOrTop
    elif coord1 > coord2 + half2:
      result = rightOrBottom
  else:
    result = noAxialCollision

proc collide(e1, e2: Entity): CollisionType =
  if abs(e1.y - e2.y) < e1.col.halfH + e2.col.halfH:
    case axialCollide(e1.x, e2.x, e1.col.halfW, e2.col.halfW, e1.vel.x)
    of leftOrTop: return left
    of rightOrBottom: return right
    of noAxialCollision: discard
  if abs(e1.x - e2.x) < e1.col.halfW + e2.col.halfW:
    case axialCollide(e1.y, e2.y, e1.col.halfH, e2.col.halfH, e1.vel.y)
    of leftOrTop: return top
    of rightOrBottom: return bottom
    of noAxialCollision: discard
  result = noCollision

proc update*() =
  while lastUpdate.ticks - startTime.ticks > updates * 16666667:
    updates += 1
    canJump = false
    for entity in velocityEntities:
      if entity in colliderEntities:
        for e in colliderEntities:
          if entity != e:
            case collide(entity, e)
            of left:
              entity.x = e.x - entity.col.halfW - e.col.halfW
              entity.y += entity.vel.y
            of right:
              entity.x = e.x + entity.col.halfW + e.col.halfW
              entity.y += entity.vel.y
            of top:
              entity.x += entity.vel.x
              entity.y = e.y - entity.col.halfH - e.col.halfH
              if entity == player:
                canJump = true
            of bottom:
              entity.x += entity.vel.x
              entity.y = e.y + entity.col.halfH + e.col.halfH
            of noCollision:
              entity.x += entity.vel.x
              entity.y += entity.vel.y
      else:
        entity.x += entity.vel.x
        entity.y += entity.vel.y

      if entity.vel.y < 20: entity.vel.y = entity.vel.y + 1

  lastUpdate = getMonoTime()
