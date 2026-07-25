class_name BubbleSpawner extends Node2D

@export var scene: PackedScene

## Spawn rate in bubble/seconde
@export var rate := 0.25
@export var speed_randomness := 100.0
@export var angle_range_degree := 15.0
@export var spawn_power := 250.0
@export var enabled: bool = true:
	set(value):
		_timer.paused = not value
		enabled = value

var _timer := Timer.new()
var _rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(_timer)
	_timer.wait_time = 1.0 / rate
	_timer.timeout.connect(spawn_bubble)
	_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn_bubble() -> void:
	var node: RigidBody2D = scene.instantiate()
	add_child(node)
	var random_impulse_amount = _rng.randf_range(-speed_randomness, speed_randomness)
	var random_angle_degree = _rng.randf_range(-angle_range_degree, angle_range_degree)
	var impulse_vector = -global_transform.y.rotated(deg_to_rad(random_angle_degree)) * (spawn_power + random_impulse_amount)
	node.apply_impulse(impulse_vector)
