class_name Buoyancy extends Node

## Body that the buoyancy force is applied to
@export var rigidBody2D: RigidBody2D

## Area to detect if the body is in water or not
@export var area2D: Area2D

## Amount of buoyancy (force applied). A negative value makes the body sink.
@export var buoyancy := 10.0:
	set(value):
		buoyancy = value
		if rigidBody2D and not _buoyancy_applied:
			rigidBody2D.add_constant_force(Vector2(0, -buoyancy))
			_buoyancy_applied = true

var _buoyancy_applied := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if area2D:
		area2D.area_entered.connect(_on_area_entered)
		area2D.area_exited.connect(_on_area_exited)
	
	rigidBody2D.add_constant_force(Vector2(0, -buoyancy))
	_buoyancy_applied = true


func _on_area_entered(other: Area2D) -> void:
	if not other.is_in_group("air") or not _buoyancy_applied: return
	
	rigidBody2D.add_constant_force(Vector2(0, buoyancy))
	_buoyancy_applied = false

func _on_area_exited(other: Area2D) -> void:
	if not other.is_in_group("air") or _buoyancy_applied: return
	
	rigidBody2D.add_constant_force(Vector2(0, -buoyancy))
	_buoyancy_applied = true
