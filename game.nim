import action, tables, hashes

const moveSpeed = 5

type
  Entity* = ref object
    x*, y*: int
    id*: string

  Velocity = ref object
    x, y: int

var
  entities*: seq[Entity]
  velocities = initTable[Entity, Velocity]()
  colliders = initTable[Entity, Collider]()
  jumpDelay = 0

proc hash(entity: Entity): Hash =
  result = entity.id.hash

proc newEntity(x, y: int, id: string): Entity =
  result = Entity(x: x, y: y, id: id)
  entities.add(result)

proc addVelocity(entity: Entity) =
  velocities[entity] = Velocity(x: 0, y: 0)

var player = newEntity(0, 0, "player")

player.addVelocity()

proc playerAction*(actions: set[Action]) =
  if left in actions: player.x -= moveSpeed
  if right in actions: player.x += moveSpeed
  if jump in actions and jumpDelay == 0:
    velocities[player].y = -20
    jumpDelay = 40

proc update*() =
  for entity, vel in velocities.pairs:
    entity.x += vel.x
    entity.y += vel.y
    if vel.y < 20: vel.y += 1
    if jumpDelay > 0: jumpDelay -= 1
