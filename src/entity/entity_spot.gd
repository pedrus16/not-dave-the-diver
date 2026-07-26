class_name EntitySpot extends Marker2D

@export var can_hold_egg := false
@export var available_entities: EntityList = preload("res://config/default_floating_entity_list.tres")

var _entity: Node2D


## Spawns an entity in the spot, eventually freeing the former one if it exists.
func spawn_entity(scene: PackedScene) -> Node2D:
	if _entity != null:
		_entity.queue_free()
	
	_entity = scene.instantiate() as Node2D
	add_child(_entity)
	
	var anchor := _entity.find_child("EntityAnchor", false) as Node2D
	if anchor != null:
		_entity.position = -anchor.position
	
	return _entity


## Instantiate an entity in this spot, by randomly picking one from available_entities.
##
## Returns true if an entity was successfully instantiated.
func populate(cell: Vector2i, rng: RandomNumberGenerator) -> bool:
	if available_entities == null:
		push_warning("null available_entities in %s" % get_path())
		return false

	if available_entities.entities.is_empty():
		return false
	
	var matching_entities := available_entities.entities.filter(
		func(entity: EntityListEntry):
			return absf(global_rotation_degrees) <= entity.max_vertical_angle
	)
	
	if matching_entities.is_empty():
		return false
	
	var weights := PackedFloat32Array()
	weights.resize(matching_entities.size())
	var weights_sum := 0.0
	
	for i in range(matching_entities.size()):
		var entity := matching_entities[i] as EntityListEntry
		weights[i] = entity.weight
		weights[i] *= entity.cell_weight_factor(cell)
		weights_sum += weights[i]
	
	if is_zero_approx(weights_sum):
		return false
	
	var picked_entities := matching_entities[rng.rand_weighted(weights)] as EntityListEntry
	
	if picked_entities.scene == null:
		push_warning("null scene")
		return false
	
	spawn_entity(picked_entities.scene)
	
	return true


func _sum_weights(sum: float, entry: EntityListEntry) -> float:
	return sum + entry.weight
