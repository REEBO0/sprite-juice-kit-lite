extends Node
## JuiceLite - the free sample of Sprite Juice Kit 2D. Register as an autoload named "JuiceLite".
## Three effects:
##   JuiceLite.hitstop(0.06)            # brief game freeze
##   JuiceLite.shake(0.5)               # screen shake (needs a current Camera2D)
##   JuiceLite.flash(sprite)            # hit-flash shader, fades back
##   JuiceLite.hit(sprite)              # all three at once
## The full kit adds squash & stretch, damage numbers, afterimages, scene transitions and more.

const HitStopScript := preload("res://addons/sprite_juice_lite/hit_stop.gd")
const ShakeScript := preload("res://addons/sprite_juice_lite/screen_shake.gd")
const HIT_FLASH := preload("res://addons/sprite_juice_lite/shaders/hit_flash.gdshader")

const META_ORIG := &"_juicelite_orig_material"
const META_TWEEN := &"_juicelite_tween"

var _hitstop: JuiceLiteHitStop


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_hitstop = HitStopScript.new()
	_hitstop.name = "HitStop"
	add_child(_hitstop)


## Flash + screen shake + tiny hit-stop in one call.
func hit(node: CanvasItem, color := Color.WHITE, shake_amount := 0.35, stop_time := 0.05) -> void:
	if not is_instance_valid(node):
		return
	flash(node, color, 0.14)
	if shake_amount > 0.0:
		shake(shake_amount)
	if stop_time > 0.0:
		hitstop(stop_time)


## Flash the sprite to `color` and fade back. The node's old material is restored afterwards.
func flash(node: CanvasItem, color := Color.WHITE, time := 0.12) -> Tween:
	if not is_instance_valid(node):
		return null
	if node.has_meta(META_TWEEN):
		var old: Tween = node.get_meta(META_TWEEN)
		if old != null and old.is_valid():
			old.kill()
	if not node.has_meta(META_ORIG):
		node.set_meta(META_ORIG, node.material)
	var mat := ShaderMaterial.new()
	mat.shader = HIT_FLASH
	mat.set_shader_parameter("flash_color", color)
	mat.set_shader_parameter("flash_amount", 1.0)
	node.material = mat
	var tw := node.create_tween()
	node.set_meta(META_TWEEN, tw)
	tw.tween_property(mat, "shader_parameter/flash_amount", 0.0, maxf(time, 0.01))
	tw.finished.connect(_restore.bind(node))
	return tw


## Screen shake on the current Camera2D. amount is trauma 0..1 (stacks, max 1).
func shake(amount := 0.5) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var s := cam.get_node_or_null("JuiceLiteScreenShake") as JuiceLiteScreenShake
	if s == null:
		s = ShakeScript.new()
		s.name = "JuiceLiteScreenShake"
		cam.add_child(s)
	s.add_trauma(amount)


## Freeze the game briefly. Repeated calls never stack the slow-down.
func hitstop(seconds := 0.06, slow_scale := 0.05) -> void:
	_hitstop.freeze(seconds, slow_scale)


## True while a hit-stop is running.
func is_hitstopped() -> bool:
	return _hitstop.is_frozen()


func _restore(node: CanvasItem) -> void:
	if not is_instance_valid(node):
		return
	if node.has_meta(META_TWEEN):
		node.remove_meta(META_TWEEN)
	if node.has_meta(META_ORIG):
		node.material = node.get_meta(META_ORIG)
		node.remove_meta(META_ORIG)
