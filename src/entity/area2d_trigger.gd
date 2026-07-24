class_name Area2DTrigger extends Area2D
## Triggers the `triggered` signal when interacting with the player.

## The area was triggered.
##
## delta is the duration for which the trigger occured.
## For OnEnter and Oneshot modes, it is equal to 1.0.
signal triggered(character: CharacterController, delta: float)

@export var mode := Mode.OnEnter

var _entered_character: CharacterController = null
var _already_triggered := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if mode != Mode.WhileInside || !_entered_character:
		return
	
	triggered.emit(_entered_character, delta)


func _on_body_entered(body: Node2D) -> void:
	var character := _find_character(body)
	if character == null:
		return
	
	_entered_character = character
	
	if mode == Mode.OnEnter || (mode == Mode.Oneshot && !_already_triggered):
		_already_triggered = true
		triggered.emit(character, 1.0)


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
