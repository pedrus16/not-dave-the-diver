extends Label

@export var remove_in_release := true

func _ready() -> void:
	if remove_in_release && !OS.is_debug_build():
		queue_free()


func _process(_delta: float) -> void:
	text = "FPS: %s" % Engine.get_frames_per_second()
