extends Node

@export var victory_overlay: Control
@export var defeat_overlay: Control
@export var pause_overlay: Control


func _ready() -> void:
	_hide_all_overlays()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pause"):
		if pause_overlay.visible:
			exit_pause()
		elif !victory_overlay.visible && !defeat_overlay.visible:
			show_pause()


func show_victory() -> void:
	_show_overlay(victory_overlay)


func show_defeat() -> void:
	_show_overlay(defeat_overlay)


func show_pause() -> void:
	_hide_all_overlays()
	
	get_tree().paused = true
	pause_overlay.visible = true


func exit_pause() -> void:
	pause_overlay.visible = false
	get_tree().paused = false


func _show_overlay(overlay: Control) -> void:
	_hide_all_overlays()
	
	overlay.modulate.a = 0.0
	overlay.visible = true
	
	create_tween().tween_property(overlay, "modulate:a", 1.0, 1.0)


func _hide_all_overlays() -> void:
	victory_overlay.visible = false
	defeat_overlay.visible = false
	pause_overlay.visible = false
	
	get_tree().paused = false
