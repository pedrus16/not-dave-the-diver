extends Node

const MUTE_DB := -60.0

@export_range(0.0, 5.0) var music_fade_duration := 0.5

@onready var _music_index := AudioServer.get_bus_index(&"Music")
@onready var _resting_volume_db := AudioServer.get_bus_volume_db(_music_index)

var _is_critical := false
var _ended := false
var _tween: Tween


func _exit_tree() -> void:
	AudioServer.set_bus_volume_db(_music_index, _resting_volume_db)


func _on_oxygen_level_monitor_level_changed(level: OxygenLevelMonitor.Level, _descending: bool) -> void:
	if _ended:
		return

	var critical := level == OxygenLevelMonitor.Level.ABOUT_TO_DIE

	if critical == _is_critical:
		return

	_is_critical = critical

	_fade_music_to(MUTE_DB if critical else _resting_volume_db)


func mute_for_end() -> void:
	if _ended:
		return

	_ended = true

	_fade_music_to(MUTE_DB)


func _fade_music_to(target_db: float) -> void:
	if _tween != null && _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_method(_set_music_volume, AudioServer.get_bus_volume_db(_music_index), target_db, music_fade_duration)


func _set_music_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(_music_index, value)
