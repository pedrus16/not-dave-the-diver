class_name PlayAnimationEffect extends BaseEffect

@export var sprite: AnimatedSprite2D
@export var trigger_animation: StringName
@export var after_trigger_animation: StringName


func _on_trigger(_character: CharacterController, _delta: float) -> void:
	if !sprite.animation_finished.is_connected(_reset_animation):
		sprite.play(trigger_animation)
		sprite.animation_finished.connect(_reset_animation, CONNECT_ONE_SHOT)


func _reset_animation() -> void:
	sprite.play(after_trigger_animation)
