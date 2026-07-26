class_name FishRandomMovement extends Node

@export var rigid_body: RigidBody2D
@export var sprite: AnimatedSprite2D
@export_enum("Left:-1", "Right:1") var sprite_direction: int = -1
@export_range(0.5, 20.0) var travel_time_min := 2.0
@export_range(0.5, 20.0) var travel_time_max := 8.0
@export_range(0.0, 1000.0) var speed := 50.0
@export_range(0.0001, 1.0) var float_speed := 0.001
@export_range(10.0, 1000.0) var float_amplitude := 100.0

var _direction := signf(randf() - 0.5)
var _floating_shift := randf() * 2.0 * PI
@onready var _time_before_flip := randf_range(travel_time_min, travel_time_max)


func _ready() -> void:
	if !is_equal_approx(_direction, sprite_direction):
		sprite.flip_h = true
	
	rigid_body.body_entered.connect(_flip.unbind(1))
	
	rigid_body.rotation_degrees = 0


func _physics_process(delta: float) -> void:
	var ticks := Time.get_ticks_msec()
	
	rigid_body.constant_force = Vector2(speed * _direction, float_amplitude * cos(ticks * float_speed + _floating_shift))
	
	_time_before_flip -= delta
	
	if _time_before_flip < 0:
		_flip()


func _flip() -> void:
	_time_before_flip = randf_range(travel_time_min, travel_time_max)
	_direction *= -1
	sprite.flip_h = !sprite.flip_h
