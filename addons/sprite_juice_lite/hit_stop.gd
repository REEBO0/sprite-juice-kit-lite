class_name JuiceLiteHitStop
extends Node
## Hit-stop: briefly slows the whole game down (Engine.time_scale).
## Safe to call many times: requests never stack the slow-down. A new request only extends the
## freeze to whichever end time is later, and the original time scale is restored exactly once.
## Timing uses real (wall-clock) time, so the freeze always ends, even at time_scale 0.

## Longest single freeze in seconds.
@export var max_duration := 0.5

var _active := false
var _end_usec := 0
var _saved_scale := 1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)


## Freeze for `duration` seconds. `slow_scale` is the time scale during the freeze (0.0 = full stop).
func freeze(duration: float, slow_scale := 0.05) -> void:
	if duration <= 0.0:
		return
	duration = minf(duration, max_duration)
	var end := Time.get_ticks_usec() + int(duration * 1000000.0)
	if not _active:
		_active = true
		_saved_scale = Engine.time_scale
		_end_usec = end
		Engine.time_scale = slow_scale
		set_process(true)
	else:
		_end_usec = maxi(_end_usec, end)
		Engine.time_scale = minf(Engine.time_scale, slow_scale)


func is_frozen() -> bool:
	return _active


func _process(_delta: float) -> void:
	if _active and Time.get_ticks_usec() >= _end_usec:
		_stop()


func _stop() -> void:
	if _active:
		Engine.time_scale = _saved_scale
	_active = false
	set_process(false)


func _exit_tree() -> void:
	_stop()
