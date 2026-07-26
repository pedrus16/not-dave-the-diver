extends AudioStreamPlayer

## Streams to choose between. One is picked at random per trigger.
@export var streams: Array[AudioStream] = []

## Seconds before another stream can play. Zero disables the cooldown.
@export_range(0.0, 30.0) var retrigger_cooldown := 0.0

var _cooldown_remaining := 0.0


func _process(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining -= delta


## Plays one of the streams at random, unless the cooldown is still running.
func play_random() -> void:
	if streams.is_empty() || _cooldown_remaining > 0.0:
		return

	_cooldown_remaining = retrigger_cooldown
	stream = streams[randi() % streams.size()]
	play()
