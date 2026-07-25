class_name PickEffect extends BaseEffect
## The hen picks the entity when triggering it.

@export var root_rigid_body: RigidBody2D


func _on_trigger(character: CharacterController, _delta: float) -> void:
	# We are not allowed to reparent the collider in collision callback.
	_pick.call_deferred(character)


func _pick(character: CharacterController) -> void:
	root_rigid_body.freeze = false
	
	character.take_item(root_rigid_body)
