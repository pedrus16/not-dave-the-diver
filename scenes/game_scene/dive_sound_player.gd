extends AudioStreamPlayer

@export var dive_in_stream: AudioStream
@export var dive_out_stream: AudioStream

## Seconds before either dive sound can retrigger.
@export_range(0.0, 5.0) var retrigger_cooldown := 1.0

var _cooldown_remaining := 0.0


func _process(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining -= delta


func _on_character_entered_water() -> void:
	_play_dive_sound(dive_in_stream)


func _on_character_exited_water() -> void:
	_play_dive_sound(dive_out_stream)


func _play_dive_sound(dive_stream: AudioStream) -> void:
	if dive_stream == null || _cooldown_remaining > 0.0:
		return
	
	_cooldown_remaining = retrigger_cooldown
	stream = dive_stream
	play()
