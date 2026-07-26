class_name LifeRopeController extends Node

@export var debug_print_points_count := false

@export var character_body: RigidBody2D
@export var surface_anchor: Node2D
@export var rope_parent: Node2D

@export_group("Rope behavior")
@export_range(100, 2000) var max_points := 600
@export_range(1.0, 500.0) var max_attach_distance := 100.0
@export_range(5.0, 200.0) var segments_length := 40.0
@export_range(1.05, 5.0) var grow_ratio := 1.1
@export_range(1.0, 100.0) var retract_speed := 10.0
@export_range(0.0, 100000.0, 1.0, "exp") var retract_pull_strength := 3000.0
@export_flags_2d_physics var collision_mask: int

@export_group("Rope render")
@export var color: Color = Color.BROWN
@export var shader: Shader = preload("res://scenes/character/rope.gdshader")
@export_range(1.0, 30.0) var width := 10.0
@export_range(0.01, 1.0) var stripe_width := 0.5
@export_range(0.0, 0.5) var outline_width := 0.2

var retracting := false:
	set(val):
		if val != retracting:
			retracting = val
			_on_retracting_changed()

var _rope: CRope2D
var _character_anchor: CRopeAnchor
var _surface_anchor: CRopeAnchor
var _is_character_attached: bool
var _retract_timer: float


func _physics_process(delta: float) -> void:
	if _rope == null || !_is_character_attached:
		return
	
	if retracting:
		_process_retractation(delta)
	else:
		_process_expansion()


func create() -> void:
	if _rope != null:
		push_error("Rope already created")
		return

	var data := CRopeData.new()
	data.create_line_by_length(character_body.global_position, surface_anchor.global_position, segments_length)
	
	_rope = CRope2D.new()
	_rope.damping = 1.0 # avoids the rope to go up very fast when detaching it form the character
	_rope.collision_stride = 1 # avoids glitches with colliders
	_rope.collision_mask = collision_mask
	_rope.data = data

	# Surface anchor has last index, because it is more performant to append points to the end
	
	_character_anchor = CRopeAnchor.new()
	_character_anchor.index = 0
	_character_anchor.node_path = character_body.get_path()
	_character_anchor.collision_resolve = false
	_character_anchor.pull_strength = 0.0
	
	_surface_anchor = CRopeAnchor.new()
	_surface_anchor.index = data.get_count() - 1
	_surface_anchor.node_path = surface_anchor.get_path()
	_surface_anchor.collision_resolve = false
	_surface_anchor.pull_strength = 0.0

	_rope.anchors = [_surface_anchor, _character_anchor]
	_is_character_attached = true

	# Modules
	_rope.force_modules = [CRopeGravityForceMod.new()]
	
	var smooth = CRopeSmoothLineMod.new()
	var simplify = CRopeSimplifyLineMod.new()
	_rope.line_modules = [smooth, simplify]
	
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("rope_color1", color.darkened(0.7))
	mat.set_shader_parameter("rope_color2", color)
	mat.set_shader_parameter("stripe_width", stripe_width)
	mat.set_shader_parameter("outline_width", outline_width)
	_rope.material = mat
	
	var renderer := CRopeDirectRenderMod.new()
	renderer.width = width
	renderer.begin_cap_mode = Line2D.LINE_CAP_ROUND
	renderer.end_cap_mode = Line2D.LINE_CAP_ROUND
	renderer.joint_mode = Line2D.LINE_JOINT_SHARP
	
	_rope.render_modules = [renderer]

	rope_parent.add_child(_rope)


func is_character_attached() -> bool:
	return _is_character_attached


func detach_character() -> void:
	_rope.anchors = [_surface_anchor]
	_is_character_attached = false


## Attempt to attach the character to the rope.
##
## Returns false if he is too far from it.
##
## TODO: may be resource intensive, try not to call it too often
func try_attach_character() -> bool:
	var point_dict := _closest_point(character_body.global_position)
	
	if point_dict["square_dist"] > max_attach_distance ** 2:
		return false
	
	_character_anchor.index = point_dict["index"]
	_rope.anchors = [_surface_anchor, _character_anchor]
	
	_is_character_attached = true
	
	return true


func _closest_point(from: Vector2) -> Dictionary:
	var points := _rope.data.get_global_points()
	
	var closest_index := -1
	var closest_dist := INF
	
	# 0 is reserved for surface anchor
	for i in range(1, points.size()):
		var dist := from.distance_squared_to(points[i])
		
		if dist < closest_dist:
			closest_index = i
			closest_dist = dist
	
	return {
		"index": closest_index,
		"square_dist": closest_dist,
	}
	

func _process_retractation(delta: float) -> void:
	_retract_timer += delta
	
	if _retract_timer < 1.0 / retract_speed || _rope.data.get_count() <= 2:
		return
	
	_retract_timer = 0.0
	
	_rope.data.remove()
	_update_surface_anchor_index()


func _process_expansion() -> void:
	# We grow the rope if avg of 2 last segments is > than a threshold
	var data := _rope.data
	var pts := data.points
	var last := data.get_count() - 1
	var avg_segment := 0.5 * (pts[last].distance_to(pts[last-1]) + pts[last-1].distance_to(pts[last-2]))
	
	if avg_segment <= segments_length * grow_ratio:
		return
	
	# If the rope has reached its maximum size, the character drops it
	if last + 1 >= max_points:
		detach_character()
		return
	
	var last_pt := pts[last]
	var to_prev := pts[last - 1] - last_pt
	var d := to_prev.length()
	if d < 0.001:
		return
	
	data.append(last_pt + to_prev / d * minf(segments_length, d * 0.5), last)
	_update_surface_anchor_index()


func _on_retracting_changed() -> void:
	if _character_anchor == null:
		return
	
	if retracting:
		_retract_timer = 1.0 / retract_speed
		_character_anchor.pull_strength = retract_pull_strength
	else:
		_character_anchor.pull_strength = 0.0


func _update_surface_anchor_index() -> void:
	var count := _rope.data.get_count()
	_surface_anchor.index = count - 1
	
	if debug_print_points_count:
		print("%d points in rope" % count)
