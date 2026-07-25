class_name CharacterController extends Node2D

@export var rigidBody2D: RigidBody2D
@export var sprite: AnimatedSprite2D
@export var inventory: CharacterInventory
@export var o2_counter: RefillableTimer
@export var movePower := 240.0
@export var refill_rate := 2.0

@export var disable_controls := false

var sprite_rotation := 0.0
var is_swimming := false
var in_water := false
var _last_input := Vector2.ZERO
var _dir_changed_elapsed_time := 0.0
var _sprite_angle_offset := PI * 0.5
var _dead := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if disable_controls == true: return
	
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input_delta := input - _last_input
	rigidBody2D.add_constant_force(input_delta * movePower)
	
	if not Vector2(_last_input - input).is_zero_approx():
		_dir_changed_elapsed_time = 0.0
		_last_input = input
		
	is_swimming = not input.is_zero_approx()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_dir_changed_elapsed_time += delta * Engine.time_scale
	
	if _last_input.is_zero_approx(): return
	
	var last_input_angle = _last_input.angle()
	if abs(sprite.rotation - (last_input_angle + _sprite_angle_offset)) > 0.001:
		sprite_rotation = lerp_angle(sprite.rotation, last_input_angle + _sprite_angle_offset, min(1.0, _dir_changed_elapsed_time))
	else:
		sprite_rotation = last_input_angle + _sprite_angle_offset


func _process(delta: float) -> void:
	if _dead: return
	
	sprite.rotation = sprite_rotation
	if is_swimming:
		sprite.animation = "swimming"
	else:
		sprite.animation
		sprite.animation = "idle"
		
	if not in_water:
		o2_counter.add_time(refill_rate * delta)


func _on_breath_area_area_entered(area: Area2D) -> void:
	if not area.is_in_group("air"): return
	
	in_water = false
	#rigidBody2D.gravity_scale = 1.0


func _on_breath_area_area_exited(area: Area2D) -> void:
	if not area.is_in_group("air"): return
	
	in_water = true
	#rigidBody2D.gravity_scale = 0.0


func _on_o_2_counter_timeout() -> void:
	kill()


## Adds a positive or negative number of seconds to o2 timer.
func add_o2_delta(seconds: float) -> void:
	o2_counter.add_time(seconds)


func take_item(item: Node2D) -> void:
	inventory.take_item(item)


## Triggers death animation and disable controls
func kill() -> void:
	_dead = true
	sprite.animation = "dying"
	disable_controls = true
