extends Node2D

@export var character: Node2D
@export var anvil: Node2D

var rope: CRope2D
var nominal_length: float
var anvil_anchor: CRopeAnchor
var character_anchor: CRopeAnchor

var retract_counter: float

func _ready() -> void:
	_create_rope()


func _physics_process(delta: float) -> void:
	retract_counter += delta
	
	if Input.is_key_pressed(KEY_SPACE):
		character_anchor.pull_strength = 3000.0
		
		if rope.data.get_count() <= 2:
			return
		
		if retract_counter < 0.1:
			return
		
		retract_counter = 0.0
		
		rope.data.remove()
		# Update anvil anchor index
		anvil_anchor.index = rope.data.get_count() - 1
		
		return

	character_anchor.pull_strength = 0.0

	# Extend the rope if necessary
	
	# Average of the last 2 segments
	var pts := rope.data.points
	var last := rope.data.get_count() - 1
	var avg_segment := 0.5 * (pts[last].distance_to(pts[last-1]) + pts[last-1].distance_to(pts[last-2]))
	
	if avg_segment <= nominal_length * 1.1:
		return
	
	# Add one point
	var pt_anvil := pts[last]
	var to_prev := pts[last - 1] - pt_anvil
	var d := to_prev.length()
	if d < 0.001:
		return
	
	rope.data.append(pt_anvil + to_prev / d * minf(nominal_length, d * 0.5), last)
	# Update anvil anchor index
	anvil_anchor.index = rope.data.get_count() - 1
	
	print(rope.data.get_count())


func _create_rope() -> void:
	var data := CRopeData.new()
	data.create_line_by_count(character.global_position, anvil.global_position, 10)
	
	rope = CRope2D.new()
	rope.data = data
	
	# anvil is the last index, because it is more performant to append points at the end
	
	character_anchor = CRopeAnchor.new()
	character_anchor.index = 0
	character_anchor.node_path = character.get_path()
	character_anchor.collision_resolve = false
	character_anchor.pull_strength = 0.0
	
	anvil_anchor = CRopeAnchor.new()
	anvil_anchor.index = 10
	anvil_anchor.node_path = anvil.get_path()
	anvil_anchor.collision_resolve = false
	anvil_anchor.pull_strength = 0.0
	
	rope.anchors = [character_anchor, anvil_anchor]
	
	# Modules
	rope.force_modules = [CRopeGravityForceMod.new()]

	var smooth = CRopeSmoothLineMod.new()
	var simplify = CRopeSimplifyLineMod.new()
	rope.line_modules = [smooth, simplify]
	
	var renderer = CRopeDirectRenderMod.new()
	renderer.width = 5.0
	renderer.color = Color.BROWN
	rope.render_modules = [renderer]

	add_child(rope)
	
	nominal_length = data.segment_length
