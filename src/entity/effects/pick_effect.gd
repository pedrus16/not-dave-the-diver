class_name PickEffect extends Node
## The hen picks the entity when triggering it.

@export var entity_root: Area2DTrigger


func _on_triggered(character: CharacterController, _delta: float) -> void:
	# We are not allowed to reparent the collider in collision callback.
	_pick.call_deferred(character)


func _pick(character: CharacterController) -> void:
	entity_root.monitorable = false
	entity_root.monitoring = false
	
	character.take_object(entity_root)
