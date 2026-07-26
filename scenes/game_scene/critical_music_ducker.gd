extends Node

const MUTE_DB := -60.0

## Buses silenced while oxygen is critical.
@export var ducked_buses: Array[StringName] = [&"Music", &"Ambiance"]

## Seconds to fade the buses out and back.
@export_range(0.0, 5.0) var music_fade_duration := 0.5

var _bus_indices: Array[int] = []
var _resting_volumes_db: Array[float] = []
var _duck_db := 0.0
var _is_critical := false
var _ended := false
var _tween: Tween


func _exit_tree() -> void:
	_apply_duck(0.0)


func _ready() -> void:
	for bus_name in ducked_buses:
		var index := AudioServer.get_bus_index(bus_name)

		if index < 0:
			push_warning("CriticalMusicDucker: no audio bus named '%s'" % bus_name)
			continue

		_bus_indices.append(index)
		_resting_volumes_db.append(AudioServer.get_bus_volume_db(index))


func _on_oxygen_level_monitor_level_changed(level: OxygenLevelMonitor.Level, _descending: bool) -> void:
	if _ended:
		return

	var critical := level == OxygenLevelMonitor.Level.ABOUT_TO_DIE

	if critical == _is_critical:
		return

	_is_critical = critical

	_fade_to(MUTE_DB if critical else 0.0)


func mute_for_end() -> void:
	if _ended:
		return

	_ended = true

	_fade_to(MUTE_DB)


func _fade_to(target_duck_db: float) -> void:
	if _tween != null && _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_method(_apply_duck, _duck_db, target_duck_db, music_fade_duration)


## Ducking is an offset applied to each bus's resting level, not an absolute
## value, so buses mixed at different volumes keep their balance while fading.
func _apply_duck(duck_db: float) -> void:
	_duck_db = duck_db

	for i in range(_bus_indices.size()):
		AudioServer.set_bus_volume_db(_bus_indices[i], _resting_volumes_db[i] + duck_db)
