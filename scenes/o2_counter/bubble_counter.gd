extends TextureRect

@export var timer: RefillableTimer

@export var alpha: float:
	set(val):
		alpha = val
		_shader_mat.set_shader_parameter(&"alpha", val)
		

@onready var _shader_mat := material as ShaderMaterial


func _ready() -> void:
	_shader_mat.set_shader_parameter(&"chargement", 1.0)
	_update_progress_bar()


func _process(_delta: float) -> void:
	_update_progress_bar()


func _update_progress_bar() -> void:
	if timer == null || is_zero_approx(timer.max_duration):
		return
	
	var t := clampf(timer.time_left / timer.max_duration, 0.0, 1.0)
	
	_shader_mat.set_shader_parameter(&"chargement", t)
