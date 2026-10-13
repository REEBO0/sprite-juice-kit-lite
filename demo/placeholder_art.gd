extends RefCounted
## Procedurally drawn placeholder sprites for the demo. Everything is generated from code with
## Image.set_pixel: no imported art, no third-party assets. Replace with your own sprites.


static func _blank(w: int, h: int) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	return img


## Filled ellipse with simple top-left lighting. `base` is the mid tone.
static func _blob(img: Image, cx: float, cy: float, rx: float, ry: float, base: Color) -> void:
	for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
		for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
			if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
				continue
			var dx := (x + 0.5 - cx) / rx
			var dy := (y + 0.5 - cy) / ry
			var d := dx * dx + dy * dy
			if d > 1.0:
				continue
			var light := clampf(0.55 - (dx * 0.45 + dy * 0.55) * 0.6, 0.0, 1.0)
			var shade := 0.45 + light * 0.9
			if d > 0.72:
				shade *= 0.72
			img.set_pixel(x, y, Color(base.r * shade, base.g * shade, base.b * shade, 1.0))


static func _rect(img: Image, x0: int, y0: int, w: int, h: int, c: Color) -> void:
	for y in range(y0, y0 + h):
		for x in range(x0, x0 + w):
			if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
				img.set_pixel(x, y, c)


static func _eyes(img: Image, x: int, y: int, gap: int) -> void:
	for s in [-1, 1]:
		var ex: int = x + s * gap
		_rect(img, ex - 2, y - 2, 4, 5, Color.WHITE)
		_rect(img, ex - 1 + (1 if s > 0 else 0), y, 2, 3, Color(0.08, 0.08, 0.15))


## Blue knight blob with a red plume. 32 x 40 pixels.
static func hero() -> ImageTexture:
	var img := _blank(32, 40)
	_rect(img, 9, 33, 5, 4, Color(0.2, 0.15, 0.3))
	_rect(img, 18, 33, 5, 4, Color(0.2, 0.15, 0.3))
	_blob(img, 16, 22, 12, 13, Color(0.25, 0.5, 0.95))
	_blob(img, 16, 26, 7, 6, Color(0.7, 0.85, 1.0))
	_blob(img, 16, 9, 4, 5, Color(0.95, 0.25, 0.25))
	_rect(img, 5, 16, 22, 3, Color(0.75, 0.78, 0.85))
	_rect(img, 5, 19, 22, 1, Color(0.4, 0.42, 0.5))
	_eyes(img, 16, 25, 4)
	_rect(img, 14, 29, 4, 1, Color(0.1, 0.1, 0.2))
	return ImageTexture.create_from_image(img)


## Green slime. 32 x 32 pixels.
static func slime() -> ImageTexture:
	var img := _blank(32, 32)
	_blob(img, 16, 20, 13, 10, Color(0.3, 0.85, 0.35))
	_blob(img, 11, 15, 4, 2.5, Color(0.85, 1.0, 0.85))
	_eyes(img, 16, 20, 5)
	_rect(img, 13, 25, 6, 1, Color(0.05, 0.25, 0.1))
	return ImageTexture.create_from_image(img)


## Three-frame sprite sheet (96 x 32): a gem that spins, drawn with 2 texel padding so it
## can show the atlas-safe outline. Use Sprite2D hframes = 3.
static func gem_sheet() -> ImageTexture:
	var img := _blank(96, 32)
	var widths := [11, 7, 3]
	for f in 3:
		var ox := f * 32 + 16
		var w: int = widths[f]
		for y in range(2, 30):
			var t := 1.0 - absf(float(y) - 15.5) / 13.5
			var half := int(round(float(w) * clampf(t * 1.3, 0.0, 1.0)))
			for x in range(ox - half, ox + half):
				var lit := 0.55 + 0.45 * float(x - (ox - half)) / maxf(float(half * 2), 1.0) * (1.0 if y < 15 else 0.6)
				var edge := 0.0 if (x == ox - half or x == ox + half - 1 or y == 2 or y == 29) else 1.0
				var c := Color(0.2, 0.9, 0.95) * lit * (0.7 + 0.3 * edge)
				if y < 12 and x > ox - 2:
					c = c.lerp(Color(0.9, 1.0, 1.0), 0.5)
				c.a = 1.0
				img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


## Plain dark grid texture for the stage floor.
static func floor_tile() -> ImageTexture:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.13, 0.12, 0.2))
	for i in 64:
		img.set_pixel(i, 0, Color(0.2, 0.19, 0.3))
		img.set_pixel(0, i, Color(0.2, 0.19, 0.3))
	return ImageTexture.create_from_image(img)
