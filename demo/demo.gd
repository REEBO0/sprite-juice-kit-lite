extends Node2D
## Sprite Juice Kit Lite - demo of the 3 free effects. All art is generated in code.
## Keys: 1 = hit flash, 2 = screen shake, 3 = hit-stop, 4 = all three. Click a sprite to hit it.
## Space cycles the target. Esc quits.

const Art := preload("res://demo/placeholder_art.gd")
const STORE_URL := "https://reebo0.itch.io/sprite-juice-kit-2d"
const PROMO := "Free sample: 3 of the Sprite Juice Kit's effects. Get the full kit (squash & stretch, damage numbers, afterimages, transitions, 8 more sprite shaders)"

var targets: Array[Sprite2D] = []
var target_index := 0
var camera: Camera2D
var status: Label
var link: LinkButton
var _marker: Label


func _ready() -> void:
	_build_world()
	_build_ui()


func _build_world() -> void:
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)
	add_child(camera)
	var bg := ColorRect.new()
	bg.color = Color(0.11, 0.09, 0.2)
	bg.position = Vector2(-200, -200)
	bg.size = Vector2(1680, 1120)
	bg.z_index = -10
	add_child(bg)
	var floor_rect := TextureRect.new()
	floor_rect.texture = Art.floor_tile()
	floor_rect.stretch_mode = TextureRect.STRETCH_TILE
	floor_rect.position = Vector2(-200, 470)
	floor_rect.size = Vector2(1680, 450)
	floor_rect.z_index = -9
	add_child(floor_rect)
	var defs := [[Art.hero(), Vector2(300, 400)], [Art.slime(), Vector2(640, 420)], [Art.gem_sheet(), Vector2(980, 400)]]
	for d in defs:
		var s := Sprite2D.new()
		s.texture = d[0]
		s.position = d[1]
		s.scale = Vector2(6, 6)
		if (d[0] as Texture2D).get_width() == 96:
			s.hframes = 3
			s.frame = 1
		add_child(s)
		targets.append(s)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_centered(layer, "Sprite Juice Kit Lite", 24, 40, Color(1.0, 0.9, 0.4))
	_centered(layer, "1 Hit flash    2 Screen shake    3 Hit-stop    4 All three    Click a sprite to hit it    Space: next target", 84, 20, Color(0.85, 0.85, 1.0))
	status = _centered(layer, "", 122, 18, Color(0.7, 1.0, 0.8))
	_marker = Label.new()
	_marker.text = "v"
	_marker.add_theme_font_size_override("font_size", 32)
	_marker.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	layer.add_child(_marker)
	link = LinkButton.new()
	link.text = PROMO
	link.underline = LinkButton.UNDERLINE_MODE_ALWAYS
	link.add_theme_font_size_override("font_size", 17)
	link.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	link.add_theme_color_override("font_hover_color", Color.WHITE)
	link.position = Vector2(20, 672)
	link.pressed.connect(open_store)
	layer.add_child(link)
	set_target(0)


func _centered(parent: Node, text: String, y: float, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.position = Vector2(0, y)
	l.size.x = 1280
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	parent.add_child(l)
	return l


## Opens the full kit's page in the browser (the LinkButton has no uri set, so it opens only once).
func open_store() -> void:
	OS.shell_open(STORE_URL)


func set_target(i: int) -> void:
	target_index = posmod(i, targets.size())
	var t := targets[target_index]
	_marker.position = Vector2(t.position.x - 10, t.position.y - 190)


func trigger(id: String) -> void:
	var t := targets[target_index]
	match id:
		"flash":
			JuiceLite.flash(t, Color.WHITE, 0.25)
			status.text = "JuiceLite.flash(sprite)"
		"shake":
			JuiceLite.shake(0.6)
			status.text = "JuiceLite.shake(0.6)"
		"hitstop":
			JuiceLite.hitstop(0.12)
			status.text = "JuiceLite.hitstop(0.12)"
		"hit":
			JuiceLite.hit(t, Color(1.0, 0.35, 0.3), 0.5, 0.08)
			status.text = "JuiceLite.hit(sprite)  =  flash + shake + hit-stop"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: trigger("flash")
			KEY_2: trigger("shake")
			KEY_3: trigger("hitstop")
			KEY_4: trigger("hit")
			KEY_SPACE: set_target(target_index + 1)
			KEY_ESCAPE: get_tree().quit()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var p := get_global_mouse_position()
		for i in targets.size():
			var t := targets[i]
			var half := (t.texture.get_size() / Vector2(t.hframes, t.vframes)) * t.scale * 0.5
			if Rect2(t.position - half, half * 2.0).has_point(p):
				set_target(i)
				trigger("hit")
				return
