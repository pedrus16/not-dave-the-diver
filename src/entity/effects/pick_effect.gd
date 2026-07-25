class_name PickEffect extends BaseEffect
## The hen picks the entity when triggering it.

@export var root_rigid_body: RigidBody2D

@onready var _initial_parent := get_parent()


func _on_trigger(character: CharacterController, _delta: float) -> void:
	# We are not allowed to reparent the collider in collision callback.
	_pick.call_deferred(character)


func _pick(character: CharacterController) -> void:
	root_rigid_body.freeze = false
	
	character.take_item(root_rigid_body, _on_drop)


func _on_drop() -> void:
	reparent(_initial_parent)
	
	# Wait a bit so we don't immediately re-pick the same item
	await get_tree().create_timer(1.0).timeout
	
	_already_triggered = false
