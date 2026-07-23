class_name O2DeltaEffect extends Node
## Add or remove time to O2 bottle when _on_triggered is called.

## O2 to add (or remove if negative).
##
## In seconds.
## For WhileInside triggers, this amount is given for each second inside the area.
@export var o2_delta := 5.0


func _on_triggered(character: CharacterController, delta: float) -> void:
	character.add_o2_delta(o2_delta * delta)
