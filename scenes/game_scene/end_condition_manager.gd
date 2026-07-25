extends Node

signal victory
signal defeat

@export var character: CharacterController
@export var surface_node: Node2D
@export var items_root: Node
@export var egg_scene: PackedScene
@export var bubble_counter: Control

var _ended := false


func _process(_delta: float) -> void:
	if _ended:
		return
	
	if character.rigidBody2D.global_position.y < surface_node.global_position.y:
		for child in items_root.get_children():
			if child.scene_file_path == egg_scene.resource_path:
				_play_victory()


func _play_victory() -> void:
	if _ended:
		return

	_hide_bubble_counter()
	
	character.disable_controls = true
	
	_ended = true
	victory.emit()


func _on_character_died() -> void:
	if _ended:
		return

	_ended = true
	
	await character.sprite.animation_finished
	
	_hide_bubble_counter()
	defeat.emit()


func _hide_bubble_counter() -> void:
	create_tween().tween_property(bubble_counter, "alpha", 0.0, 1.0)
