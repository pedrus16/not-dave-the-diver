class_name CharacterController extends Node2D

@export var rigidBody2D: RigidBody2D
@export var o2_counter: RefillableTimer
@export var movePower: float = 240.0
@export var buoyancy: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	rigidBody2D.constant_force = input * movePower + Vector2(0, -buoyancy)


## Adds a positive or negative number of seconds to o2 timer.
func add_o2_delta(seconds: float) -> void:
	o2_counter.add_time(seconds)
