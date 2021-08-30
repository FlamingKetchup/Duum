import tables, hashes

type
  Entity* = ref object
    x*, y*: int
    id*: string

  Velocity = ref object
    x*, y*: int

  Collider = ref object
    halfW*, halfH*: int

var
  entities*: seq[Entity]
  velocityEntities*: seq[Entity]
  colliderEntities*: seq[Entity]
  velocities = initTable[Entity, Velocity]()
  colliders = initTable[Entity, Collider]()

proc hash(entity: Entity): Hash =
  result = entity.id.hash

proc newEntity*(x, y: int, id: string): Entity =
  result = Entity(x: x, y: y, id: id)
  entities.add(result)

proc addVelocity*(entity: Entity) =
  velocities[entity] = Velocity(x: 0, y: 0)
  velocityEntities.add(entity)

proc addCollider*(entity: Entity, halfW, halfH: int) =
  colliders[entity] = Collider(halfW: halfW, halfH: halfH)
  colliderEntities.add(entity)

proc vel*(entity: Entity): Velocity {.inline.} = return velocities[entity]

proc col*(entity: Entity): Collider {.inline.} = return colliders[entity]
