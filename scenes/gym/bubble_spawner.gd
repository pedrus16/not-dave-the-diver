class_name BubbleSpawner extends Node2D

@export var scene: PackedScene

## Spawn rate in bubble/seconde
@export var rate := 0.25
@export var randomness := 100.0

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
	var random_impulse_vector = Vector2(_rng.randf_range(-randomness, randomness), _rng.randf_range(-randomness, randomness))
	node.apply_impulse(random_impulse_vector)
