class_name JuiceLiteScreenShake
extends Node
## Trauma-based screen shake. Add as a child of a Camera2D (JuiceLite.shake does this for you).
## add_trauma() stacks up to 1.0; the shake strength is trauma squared, so small hits are subtle
## and big hits are violent. Trauma then decays linearly. The node stops processing when idle.
## It adds to camera.offset / camera.rotation and removes exactly what it added, so it does not
## fight your own camera code.

## Maximum offset in pixels at trauma 1.
@export var max_offset := Vector2(28.0, 20.0)
## Maximum rotation in radians at trauma 1.
@export var max_roll := 0.04
## Trauma lost per second.
@export var decay := 1.6
## How fast the noise moves (higher = more jittery).
@export var noise_speed := 90.0

var trauma := 0.0

var _camera: Camera2D
var _noise := FastNoiseLite.new()
var _time := 0.0
var _applied_offset := Vector2.ZERO
var _applied_roll := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_noise.seed = randi()
	_noise.frequency = 1.0
	_camera = get_parent() as Camera2D
	set_process(trauma > 0.0)


## Adds trauma (0..1). Values stack and clamp at 1.
func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)
	set_process(true)


func _process(delta: float) -> void:
	if _camera == null:
		set_process(false)
		return
	# Use real time so the shake still plays during hit-stop.
	var real_delta := delta / maxf(Engine.time_scale, 0.001)
	_time += real_delta * noise_speed
	trauma = maxf(trauma - decay * real_delta, 0.0)
	var power := trauma * trauma
	var off := Vector2(_noise.get_noise_2d(_time, 0.0), _noise.get_noise_2d(0.0, _time + 100.0)) * max_offset * power
	var roll := _noise.get_noise_2d(_time + 300.0, _time) * max_roll * power
	_camera.offset += off - _applied_offset
	_camera.rotation += roll - _applied_roll
	_applied_offset = off
	_applied_roll = roll
	if trauma <= 0.0:
		set_process(false)


func _exit_tree() -> void:
	if is_instance_valid(_camera):
		_camera.offset -= _applied_offset
		_camera.rotation -= _applied_roll
	_applied_offset = Vector2.ZERO
	_applied_roll = 0.0
