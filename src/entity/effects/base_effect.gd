@abstract class_name BaseEffect extends Node

@export var mode := Mode.OnEnter
@export var collision_object: Area2D

var _entered_character: CharacterController = null
var _already_triggered := false


## Function to implement, called when the effect is triggered.
##
## delta is the duration for which the trigger occured.
## For OnEnter and Oneshot modes, it is equal to 1.0.
@abstract func _on_trigger(character: CharacterController, delta: float) -> void


func _ready() -> void:
	collision_object.body_entered.connect(_on_body_entered)
	collision_object.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if mode != Mode.WhileInside || !_entered_character:
		return
	
	_on_trigger(_entered_character, delta)


func _on_body_entered(body: Node2D) -> void:
	var character := _find_character(body)
	if character == null:
		return
	
	_entered_character = character
	
	if mode == Mode.OnEnter || (mode == Mode.Oneshot && !_already_triggered):
		_already_triggered = true
		_on_trigger(character, 1.0)


func _on_body_exited(body: Node2D) -> void:
	var character := _find_character(body)
	if character == null:
		return
	
	_entered_character = null


func _find_character(node: Node) -> CharacterController:
	while node:
		if node is CharacterController:
			return node
		
		node = node.get_parent()
	
	return null


enum Mode {
	OnEnter,
	Oneshot,
	WhileInside,
}
