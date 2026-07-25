extends Node

@export var defeat_overlay: Control


func _ready() -> void:
	defeat_overlay.visible = false


func show_defeat() -> void:
	defeat_overlay.modulate.a = 0.0
	defeat_overlay.visible = true
	
	create_tween().tween_property(defeat_overlay, "modulate:a", 1.0, 1.0)
