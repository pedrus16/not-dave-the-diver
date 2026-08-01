extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	%AnimatedSprite2D.play(&"default")
	await get_tree().create_timer(1.0).timeout
	%RigidBody2D.apply_central_impulse(Vector2(0.0, -100.0))


func _on_timer_2_timeout() -> void:
	pass
	#%Timer.start()
	#_on_timer_timeout()
