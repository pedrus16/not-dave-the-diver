extends AudioStreamPlayer

const MUTE_DB := -60.0

@export_range(1.0, 240.0) var fade_rate_db_per_second := 60.0

@onready var _sync_stream := stream as AudioStreamSynchronized

var _targets: Array[float] = []
var _volumes: Array[float] = []
var _ended := false


func _ready() -> void:
	for i in range(_sync_stream.stream_count):
		_targets.append(MUTE_DB)
		_volumes.append(MUTE_DB)
		_sync_stream.set_sync_stream_volume(i, MUTE_DB)

	playing = true


func _process(delta: float) -> void:
	var step := fade_rate_db_per_second * delta

	for i in range(_volumes.size()):
		if is_equal_approx(_volumes[i], _targets[i]):
			continue

		_volumes[i] = move_toward(_volumes[i], _targets[i], step)
		_sync_stream.set_sync_stream_volume(i, _volumes[i])


func _on_oxygen_level_monitor_level_changed(level: OxygenLevelMonitor.Level, _descending: bool) -> void:
	if _ended:
		return

	var active_index := int(level) - 1

	for i in range(_targets.size()):
		_targets[i] = 0.0 if i == active_index else MUTE_DB


func mute_for_end() -> void:
	if _ended:
		return

	_ended = true

	for i in range(_targets.size()):
		_targets[i] = MUTE_DB
