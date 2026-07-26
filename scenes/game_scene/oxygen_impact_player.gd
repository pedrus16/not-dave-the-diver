extends AudioStreamPlayer

## Impact streams in severity order: moderate, worrying, dangerous, about_to_die.
@export var impact_streams: Array[AudioStream] = []

## Seconds before another impact can play.
@export_range(0.0, 5.0) var retrigger_cooldown := 1.0

var _cooldown_remaining := 0.0


func _process(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining -= delta


func _on_oxygen_level_monitor_level_changed(level: OxygenLevelMonitor.Level, descending: bool) -> void:
	if !descending || _cooldown_remaining > 0.0:
		return

	var index := int(level) - 1
	if index < 0 || index >= impact_streams.size():
		return

	var impact := impact_streams[index]

	if impact == null:
		return

	_cooldown_remaining = retrigger_cooldown
	stream = impact
	play()
