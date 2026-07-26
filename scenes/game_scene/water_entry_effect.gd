extends Area2D

@export var effect := preload("res://scenes/particle_fx/splash/splash.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and Vector2.DOWN.dot(body.linear_velocity) > 0.0 and body.linear_velocity.length() > 300.0:
		var effect_instance: Node2D = effect.instantiate()
		add_child(effect_instance)
		effect_instance.global_position = Vector2(body.global_position.x, global_position.y)
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 4
		add_child(timer)
		timer.timeout.connect(
			func():
				effect_instance.queue_free()
				timer.queue_free()
		)
		
