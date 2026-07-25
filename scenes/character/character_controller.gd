class_name CharacterController extends Node2D

@export var rigidBody2D: RigidBody2D
@export var sprite: AnimatedSprite2D
@export var inventory: CharacterInventory
@export var o2_counter: RefillableTimer
@export var movePower: float = 240.0
@export var buoyancy: float = 10.0
@export var refill_rate: float = 2.0

@export var disable_controls: bool = false

var sprite_rotation: float = 0.0
var is_swimming: bool = false
var in_water: bool = false
var _last_input_angle: float = 0.0
var _dir_changed_elapsed_time: float = 0.0
var _sprite_angle_offset = PI * 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if disable_controls == true: return
	
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	rigidBody2D.constant_force = input * movePower + Vector2(0, -buoyancy)
	
	is_swimming = not input.is_zero_approx()
	var input_angle = input.angle()
	if input.is_zero_approx(): return
	
	_dir_changed_elapsed_time += delta * Engine.time_scale
	
	if abs(sprite.rotation - (_last_input_angle + _sprite_angle_offset)) > 0.001:
		sprite_rotation = lerp_angle(sprite.rotation, _last_input_angle + _sprite_angle_offset, min(1.0, _dir_changed_elapsed_time))
	else:
		sprite_rotation = _last_input_angle + _sprite_angle_offset

	if _last_input_angle != input_angle:
		_dir_changed_elapsed_time = 0.0
		_last_input_angle = input_angle


func _process(delta: float) -> void:
	sprite.rotation = sprite_rotation
	if is_swimming:
		sprite.animation = "swimming"
	else:
		sprite.animation = "idle"
		
	if not in_water:
		o2_counter.add_time(refill_rate * delta)
		


## Adds a positive or negative number of seconds to o2 timer.
func add_o2_delta(seconds: float) -> void:
	o2_counter.add_time(seconds)


func take_item(item: Node2D) -> void:
	inventory.take_item(item)


func _on_breath_area_area_entered(area: Area2D) -> void:
	if not area.is_in_group("air"): return
	
	in_water = false


func _on_breath_area_area_exited(area: Area2D) -> void:
	if not area.is_in_group("air"): return
	
	in_water = true
