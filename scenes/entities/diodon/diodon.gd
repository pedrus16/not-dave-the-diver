extends RigidBody2D

@export var inflated := false
@export var float_on_inflate := false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var ticks = Time.get_ticks_msec()
	if not inflated or not float_on_inflate:
		constant_force = Vector2(0, cos(ticks * 0.001)) * 100.0
	else:
		constant_force = Vector2(0, -200.0)


func _on_aggro_area_body_entered(body: Node2D) -> void:
	if inflated: return
	var character = BaseEffect.find_character(body)
	if character:
		%AnimationPlayer.play("blow")
