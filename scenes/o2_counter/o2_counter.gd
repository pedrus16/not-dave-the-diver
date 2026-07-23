class_name O2Counter extends MarginContainer

@export var timer: RefillableTimer

@onready var _progress_bar: ProgressBar = %ProgressBar


func _ready() -> void:
	# Dummy values in case timer is not set
	_progress_bar.max_value = 10.0
	_progress_bar.value = 10.0
	
	_update_progress_bar()


func _process(_delta: float) -> void:
	_update_progress_bar()


func _update_progress_bar() -> void:
	if timer == null:
		return
	
	_progress_bar.max_value = timer.initial_duration
	_progress_bar.value = timer.time_left
