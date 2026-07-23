class_name InteractableSpot extends Marker2D

@export var available_interactables: InteractableList


## Instantiate an interactable in this spot, by randomly picking one from available_interactables.
func populate(rng: RandomNumberGenerator) -> void:
	var weights := PackedFloat32Array()
	weights.resize(available_interactables.interactables.size())
	
	for i in range(available_interactables.interactables.size()):
		weights[i] = available_interactables.interactables[i].weight
	
	var picked_interactable := available_interactables.interactables[rng.rand_weighted(weights)] as InteractableListEntry
	
	if picked_interactable.descriptor == null || picked_interactable.descriptor.scene == null:
		# The empty interactor is valid, so we return without error.
		return
	
	var node := picked_interactable.descriptor.scene.instantiate()
	add_child(node)


func _sum_weights(sum: float, entry: InteractableListEntry) -> float:
	return sum + entry.weight
