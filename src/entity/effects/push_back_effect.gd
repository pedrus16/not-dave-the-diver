class_name PushBackEffect extends BaseEffect
## Pushes back the hen when triggered.

@export var force := 400.0


func _on_trigger(character: CharacterController, _delta: float) -> void:
	var direction := (character.rigidBody2D.global_position - collision_object.global_position).normalized()
	
	character.rigidBody2D.apply_impulse(direction * force)
