class_name OxygenLevelMonitor extends Node

signal level_changed(level: Level, descending: bool)

enum Level {
	GOOD,
	MODERATE,
	DANGEROUS,
	ABOUT_TO_DIE,
}

@export var timer: RefillableTimer

var _level := Level.GOOD
var _stopped := false


func _process(_delta: float) -> void:
	if _stopped || timer == null || timer.max_duration <= 0.0:
		return

	var level := _level_for(timer.time_left / timer.max_duration)

	if level == _level:
		return

	var descending := level > _level
	_level = level

	level_changed.emit(level, descending)


## Stops emitting. Called when the character dies.
func stop() -> void:
	_stopped = true


static func _level_for(ratio: float) -> Level:
	if ratio > 0.80:
		return Level.GOOD
	if ratio > 0.40:
		return Level.MODERATE
	if ratio > 0.15:
		return Level.DANGEROUS

	return Level.ABOUT_TO_DIE
