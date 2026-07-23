class_name RefillableTimer extends Node

## Emitted when the timer reaches the end.
signal timeout

## Initial duration in seconds
@export var initial_duration := 10.0

## If true, the timer will start immediately when it enters the scene tree.
@export var autostart := false

var time_left: float

var _started := false


func _ready() -> void:
	if autostart:
		start()


func _process(delta: float) -> void:
	if !_started:
		return
	
	time_left -= delta
	
	if time_left <= 0:
		_started = false
		timeout.emit()


## Start the timer
func start() -> void:
	time_left = initial_duration
	_started = true


## Add time to the timer
func add_time(seconds: float) -> void:
	time_left += seconds
