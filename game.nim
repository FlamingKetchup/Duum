import entity, std/monotimes, random
export entities
from input import Action
from math import ceil, round

type
  AxialCollisionType = enum
    noAxialCollision, leftOrTop, rightOrBottom
  CollisionType = enum
    noCollision, left, right, top, bottom

const moveSpeed = 3

let startTime = getMonoTime()

var
  player* = newEntity(0, 0, "player")
  canJump = false
  lastUpdate = getMonoTime()
  updates = 0

player.addVelocity()
player.addCollider(8, 8)

proc playerAction*(actions: set[Action]) =
  player.vel.x = 0
  if Action.left in actions: player.vel.x = -moveSpeed
  if Action.right in actions: player.vel.x = moveSpeed
  if jump in actions and canJump:
    player.vel.y = -10

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

proc update() =
  canJump = false
  for entity in velocityEntities:
    var
      candidateX = entity.x + entity.vel.x
      candidateY = entity.y + entity.vel.y
    if entity in colliderEntities:
      for e in colliderEntities:
        if entity != e:
          case collide(entity, e)
          of left:
            entity.vel.x = 0
            candidateX = e.x - entity.col.halfW - e.col.halfW
          of right:
            entity.vel.x = 0
            candidateX = e.x + entity.col.halfW + e.col.halfW
          of top:
            entity.vel.y = 0
            candidateY = e.y - entity.col.halfH - e.col.halfH
            if entity == player:
              canJump = true
          of bottom:
            entity.vel.y = 0
            candidateY = e.y + entity.col.halfH + e.col.halfH
          of noCollision:
            discard
    entity.x = candidateX
    entity.y = candidateY

    if entity.vel.y < 20: entity.vel.y = entity.vel.y + 1

proc cumulativeUpdate*() =
  while lastUpdate.ticks - startTime.ticks > updates * 20000000:
    updates += 1
    update()
  lastUpdate = getMonoTime()

proc generateLevel*() =
  randomize()
  var
    currentDirection = if rand(1) == 0: Action.left else: Action.right
    nextPlatformUpdate = 0
  for i in 0 .. 1000:
    if rand(49) == 0:
      if currentDirection == Action.left:
        currentDirection = Action.right
      else:
        currentDirection = Action.left
    playerAction({currentDirection, jump})

    if i == nextPlatformUpdate:
      var platform = newEntity(toInt(round(player.x/16)) * 16,
                               toInt(ceil((player.y + player.col.halfH + 8)/16)) * 16,
                               "platform")
      platform.addCollider(8, 8)
      nextPlatformUpdate += rand(10..30)

    update()

  player.x = 0
  player.y = 0
