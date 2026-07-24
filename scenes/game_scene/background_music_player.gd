extends AudioStreamPlayer

const MUTE_DB := -60.0

@export var player: Node2D
@export var top_reference: Node2D
@export_range(-60.0, 0.0) var fade_in_initial_volume := -5.0
@export_range(0.0, 10.0) var fade_in_duration := 2.0

@onready var _sync_stream := stream as AudioStreamSynchronized
var _tracks_count: int
var _max_depth: float
var _started := false

static var _module_connector_class_name := (ModuleConnector as Script).get_global_name()


func _ready() -> void:
	_tracks_count = _sync_stream.stream_count


func _process(_delta: float) -> void:
	var player_depth := player.global_position.y - top_reference.global_position.y

	if !_started:
		if player_depth > 0:
			_start()
		else:
			return

	var ratio := clampf(player_depth / _max_depth, 0.0, 1.0)
	
	_update_faders(ratio)


func _start() -> void:
	_init_max_depth()
	
	volume_db = fade_in_initial_volume
	get_tree().create_tween().tween_property(self, "volume_db", 0.0, fade_in_duration)
	
	playing = true
	_started = true


func _init_max_depth() -> void:
	var deepest_reduce := func(deepest: float, connector: Node2D) -> float: return maxf(deepest, connector.global_position.y)
	var connectors := get_tree().current_scene.find_children("", _module_connector_class_name, true, false)
	
	_max_depth = absf(connectors.reduce(deepest_reduce, 0.0))


func _update_faders(ratio: float) -> void:
	var playing_sections := _playing_sections(ratio)
	
	for i in range(_tracks_count):
		if !playing_sections.has(i):
			# Track isn't playing at all
			_sync_stream.set_sync_stream_volume(i, minf(MUTE_DB, 0.0))
			continue
		
		var gain := cos(playing_sections[i] * PI / 2.0)
		var volume := 20 * log(gain) / log(10)
		
		_sync_stream.set_sync_stream_volume(i, minf(volume, 0.0))


func _playing_sections(ratio: float) -> Dictionary[int, float]:
	var segment_size := 1.0 / _tracks_count
	var transition_length := segment_size / 2.0
	var half_transition := transition_length / 2.0
	
	for i in range(1, _tracks_count):
		var boundary := segment_size * i
		
		if absf(ratio - boundary) <= half_transition:
			var alpha := (ratio - (boundary - half_transition)) / transition_length
			
			return {
				i - 1: alpha,
				i: 1.0 - alpha,
			}
	
	return {
		mini(int(ratio / segment_size), _tracks_count - 1): 0.0
	}
