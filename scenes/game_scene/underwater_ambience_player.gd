extends AudioStreamPlayer


func _on_character_entered_water() -> void:
	if playing:
		return
	
	play()
