class_name Bubble extends RigidBody2D

var _rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random_scale = _rng.randf_range(0.8, 1.2)
	%Scale.scale *= random_scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area.is_in_group("oxygen_consumer"): return

	%AnimationPlayer.play("consume")
