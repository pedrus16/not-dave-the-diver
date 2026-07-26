class_name Preloader extends Node
## Preloads resources to avoid freezes

signal loaded

@export var audio_folder := "res://audio"
@export var preload_shaders: Array[Shader]
@export var game_scene: PackedScene

var _mute_audio_player := AudioStreamPlayer.new()
var _hidden_node_2d := Node2D.new()
var _hidden_sprite := Sprite2D.new()

var _audio_paths_to_load: Array[String] = []
var _shaders_to_load: Array[Shader]
var _loaded: Dictionary[String, Variant]

var _rope_lib_loaded := false
var _hidden_game_loaded := false
var _busy := false


func _ready() -> void:
	_audio_paths_to_load.append_array(_list_audio_files(audio_folder))
	
	_shaders_to_load = preload_shaders.duplicate()
	
	_hidden_node_2d.visible = false
	_hidden_node_2d.global_position = Vector2(100000, 100000)
	add_child(_hidden_node_2d)
	
	_hidden_sprite.global_position = Vector2(100000, 100000)
	add_child(_hidden_sprite)
	
	_mute_audio_player.volume_db = -80
	add_child(_mute_audio_player)


func _process(_delta: float) -> void:
	if !_audio_paths_to_load.is_empty():
		_load_next_audio()
		return
	
	if !_rope_lib_loaded:
		_load_rope_lib()
		return
	
	if !_shaders_to_load.is_empty():
		_load_shaders()
		return
	
	if !_hidden_game_loaded:
		_spawn_hidden_game()
		return

	loaded.emit()
	print("Loaded all resources")
	set_process(false)
	_hidden_node_2d.queue_free()
	_hidden_sprite.queue_free()
	_mute_audio_player.queue_free()


func _load_next_audio() -> void:
	if _busy:
		return
	
	_busy = true
	
	var path := _audio_paths_to_load.pop_back() as String
	_loaded[path] = ResourceLoader.load(path)
	
	_mute_audio_player.stream = _loaded[path]
	_mute_audio_player.play()
	
	await get_tree().process_frame
	
	_busy = false


func _load_rope_lib() -> void:
	if _busy:
		return
	
	_busy = true
	
	var rope := CRope2D.new()
	rope.data = CRopeData.new()
	_hidden_node_2d.add_child(rope)
	rope.queue_free()
	
	_rope_lib_loaded = true
	_busy = false


func _load_shaders() -> void:
	if _busy:
		return
	
	_busy = true
	
	var shader := _shaders_to_load.pop_back() as Shader
	var mat := ShaderMaterial.new()
	mat.shader = shader
	_hidden_sprite.material = mat
	
	_busy = false


func _spawn_hidden_game() -> void:
	if _busy:
		return
	
	_busy = true
	
	var game := game_scene.instantiate()
	_hidden_node_2d.add_child(game)
	
	for audio_player in game.find_children("", "AudioStreamPlayer", true, false):
		(audio_player as AudioStreamPlayer).bus = &"MuteBus"
	
	for hud in game.find_children("", "CanvasLayer", true, false):
		hud.free()
	
	if !game.is_node_ready():
		await game.ready
	
	game.queue_free()
	
	_hidden_game_loaded = true
	_busy = false


func _list_audio_files(path: String) -> Array[String]:
	var paths: Array[String] = []
	
	var dir := DirAccess.open(path)
	if dir == null:
		return []
	
	dir.list_dir_begin()
	
	while true:
		var file := dir.get_next()
		if file == "":
			break
	
		if dir.current_is_dir():
			continue
	
		if file.ends_with(".ogg") or file.ends_with(".wav") or file.ends_with(".mp3"):
			paths.append(path.path_join(file))

	dir.list_dir_end()
	
	return paths
