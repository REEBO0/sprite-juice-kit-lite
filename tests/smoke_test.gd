extends Node
## Smoke test for Sprite Juice Kit Lite. Run:
##   godot --headless --path <project> res://tests/smoke_test.tscn
## Loads the shader, builds the demo, exercises flash / shake / hit-stop, then prints PASS or
## FAIL and quits with exit code 0 / 1. (The headless dummy renderer does not compile shaders;
## run without --headless to also test that.)

var failures := 0
var checks := 0


func check(cond: bool, msg: String) -> void:
	checks += 1
	if cond:
		print("  ok   ", msg)
	else:
		failures += 1
		print("  FAIL ", msg)


func wait_real(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	print("== Sprite Juice Kit Lite smoke test ==")
	print("Godot ", Engine.get_version_info().string, "  renderer: ",
			RenderingServer.get_current_rendering_method(), "  driver: ", RenderingServer.get_current_rendering_driver_name())
	await _test_shader()
	await _test_demo()
	await _test_flash()
	await _test_shake()
	await _test_hitstop()
	await _test_cleanup()
	print("== checks: %d  failures: %d ==" % [checks, failures])
	print("SMOKE TEST " + ("PASS" if failures == 0 else "FAIL"))
	get_tree().quit(0 if failures == 0 else 1)


func _test_shader() -> void:
	print("-- shader")
	var sh := load("res://addons/sprite_juice_lite/shaders/hit_flash.gdshader") as Shader
	check(sh != null and sh.code.length() > 20, "loads hit_flash.gdshader")
	check(sh.get_shader_uniform_list().size() == 2, "hit_flash has 2 uniforms")
	var holder := Node2D.new()
	add_child(holder)
	var sp := Sprite2D.new()
	sp.texture = ImageTexture.create_from_image(_test_image())
	var mat := ShaderMaterial.new()
	mat.shader = sh
	sp.material = mat
	holder.add_child(sp)
	await get_tree().process_frame
	await get_tree().process_frame
	holder.queue_free()


func _test_image() -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in range(4, 28):
		for x in range(4, 28):
			img.set_pixel(x, y, Color(x / 32.0, y / 32.0, 0.6, 1.0))
	return img


func _test_demo() -> void:
	print("-- demo scene")
	check(get_node_or_null("/root/JuiceLite") != null, "JuiceLite autoload exists")
	var demo: Node = (load("res://demo/demo.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(demo)
	get_tree().current_scene = demo
	await get_tree().process_frame
	check(demo.targets.size() == 3, "demo has 3 target sprites")
	check(demo.link != null and demo.STORE_URL == "https://reebo0.itch.io/sprite-juice-kit-2d", "demo has the store link")
	check(demo.link.text.begins_with("Free sample: 3 of the Sprite Juice Kit's effects."), "promo line present")
	for i in demo.targets.size():
		demo.set_target(i)
		for id in ["flash", "shake", "hit"]:
			demo.trigger(id)
			await get_tree().process_frame
	await wait_real(0.6)
	demo.trigger("hitstop")
	await wait_real(0.4)
	check(is_equal_approx(Engine.time_scale, 1.0), "time scale back to 1.0 after demo hit-stop")


func _test_flash() -> void:
	print("-- hit flash")
	var demo := get_tree().current_scene
	var s: Sprite2D = demo.targets[0]
	await wait_real(0.5)
	check(s.material == null, "sprite starts without material")
	var tw := JuiceLite.flash(s, Color.RED, 0.1)
	check(tw != null, "flash returns a Tween")
	check(s.material is ShaderMaterial, "flash installs a ShaderMaterial")
	JuiceLite.flash(s, Color.WHITE, 0.1)
	await wait_real(0.35)
	check(s.material == null, "original (null) material restored after flash")
	JuiceLite.hit(s)
	await wait_real(0.6)
	check(s.material == null, "material restored after hit()")
	JuiceLite.flash(null)
	JuiceLite.hit(null)
	check(true, "null arguments are ignored")


func _test_shake() -> void:
	print("-- screen shake")
	var demo := get_tree().current_scene
	var cam: Camera2D = demo.camera
	var base_offset := cam.offset
	var base_rot := cam.rotation
	JuiceLite.shake(0.8)
	var shaker := cam.get_node_or_null("JuiceLiteScreenShake") as JuiceLiteScreenShake
	check(shaker != null, "shake adds a JuiceLiteScreenShake to the camera")
	await wait_real(0.2)
	JuiceLite.shake(1.0)
	check(shaker.trauma <= 1.0, "trauma is clamped to 1.0 (%f)" % shaker.trauma)
	await wait_real(1.5)
	check(shaker.trauma == 0.0, "trauma decays to 0")
	check(cam.offset.is_equal_approx(base_offset) and is_equal_approx(cam.rotation, base_rot), "camera offset and rotation return to base")


func _test_hitstop() -> void:
	print("-- hit-stop")
	Engine.time_scale = 1.0
	for i in 20:
		JuiceLite.hitstop(0.1)
	check(Engine.time_scale < 1.0, "time scale lowered during hit-stop")
	check(JuiceLite.is_hitstopped(), "is_hitstopped true")
	await wait_real(0.4)
	check(is_equal_approx(Engine.time_scale, 1.0), "20 stacked calls restore time_scale to exactly 1.0 (%f)" % Engine.time_scale)
	check(not JuiceLite.is_hitstopped(), "is_hitstopped false after")
	JuiceLite.hitstop(999.0)
	await wait_real(0.7)
	check(is_equal_approx(Engine.time_scale, 1.0), "huge duration is capped (restored within 0.7s)")


func _test_cleanup() -> void:
	print("-- cleanup")
	var demo := get_tree().current_scene
	for t in demo.targets:
		check(not t.has_meta(&"_juicelite_tween") and not t.has_meta(&"_juicelite_orig_material"), "no stray meta on " + t.name)
	print("orphan nodes: ", Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
