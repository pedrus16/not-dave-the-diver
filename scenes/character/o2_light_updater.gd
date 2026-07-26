class_name O2LightUpdater extends Node

@export var o2_counter: RefillableTimer
@export var light: Light2D
@export var lowest_hp_color := Color(0.624, 0.114, 0.141)
@export var smooth_speed := 1.0
@export_range(0.0, 1.0) var darken_begin_ratio := 0.5

@onready var _initial_color := light.color


func _physics_process(delta: float) -> void:
	var ratio := 1.0 + (o2_counter.ratio / darken_begin_ratio - 1.0)
	
	var target_color := _initial_color.lerp(lowest_hp_color, 1.0 - ratio)
	light.color = lerp(light.color, target_color, smooth_speed * delta)
