class_name EntitySpot extends Marker2D

@export var available_entities: EntityList


## Instantiate an entity in this spot, by randomly picking one from available_entities.
func populate(rng: RandomNumberGenerator) -> void:
	var weights := PackedFloat32Array()
	weights.resize(available_entities.entities.size())
	
	for i in range(available_entities.entities.size()):
		weights[i] = available_entities.entities[i].weight
	
	var picked_entities := available_entities.entities[rng.rand_weighted(weights)] as EntityListEntry
	
	if picked_entities.descriptor == null || picked_entities.descriptor.scene == null:
		# The empty entity is valid, so we return without error.
		return
	
	var node := picked_entities.descriptor.scene.instantiate()
	add_child(node)


func _sum_weights(sum: float, entry: EntityListEntry) -> float:
	return sum + entry.weight
