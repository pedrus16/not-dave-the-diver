class_name EntitySpot extends Marker2D

@export var can_hold_egg := false
@export var available_entities: EntityList = preload("res://config/default_floating_entity_list.tres")

var _entity: Node2D


## Spawns an entity in the spot, eventually freeing the former one if it exists.
func spawn_entity(scene: PackedScene) -> Node2D:
	if _entity != null:
		_entity.queue_free()
	
	_entity = scene.instantiate()
	add_child(_entity)
	
	return _entity


## Instantiate an entity in this spot, by randomly picking one from available_entities.
func populate(rng: RandomNumberGenerator) -> void:
	if available_entities == null:
		push_warning("null available_entities in %s" % get_path())
		return

	if available_entities.entities.is_empty():
		return
	
	var matching_entities := available_entities.entities.filter(
		func(entity: EntityListEntry):
			return absf(global_rotation_degrees) <= entity.max_vertical_angle
	)
	
	if matching_entities.is_empty():
		return
	
	var weights := PackedFloat32Array()
	weights.resize(matching_entities.size())
	
	for i in range(matching_entities.size()):
		weights[i] = matching_entities[i].weight
	
	var picked_entities := matching_entities[rng.rand_weighted(weights)] as EntityListEntry
	
	if picked_entities.scene == null:
		push_warning("null scene")
		return
	
	spawn_entity(picked_entities.scene)


func _sum_weights(sum: float, entry: EntityListEntry) -> float:
	return sum + entry.weight
