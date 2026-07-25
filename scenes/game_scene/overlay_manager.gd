extends Node

@export var victory_overlay: Control
@export var defeat_overlay: Control


func _ready() -> void:
	_hide_all_overlays()


func show_victory() -> void:
	_show_overlay(victory_overlay)


func show_defeat() -> void:
	_show_overlay(defeat_overlay)


func _show_overlay(overlay: Control) -> void:
	_hide_all_overlays()
	
	overlay.modulate.a = 0.0
	overlay.visible = true
	
	create_tween().tween_property(overlay, "modulate:a", 1.0, 1.0)


func _hide_all_overlays() -> void:
	victory_overlay.visible = false
	defeat_overlay.visible = false
