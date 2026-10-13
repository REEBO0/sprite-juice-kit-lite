# Sprite Juice Kit Lite (free) for Godot 4

A free sample of **Sprite Juice Kit 2D**, the paid game-feel addon by REEBOO Labs. It contains
exactly three of the full kit's effects, with the same code:

| Effect | What it does |
|---|---|
| Hit flash (`hit_flash.gdshader`) | Blends a sprite to a solid color (usually white or red), then fades back |
| Screen shake (`screen_shake.gd`) | Trauma-based shake for a `Camera2D` (offset + roll from noise, strength = trauma squared) |
| Hit-stop (`hit_stop.gd`) | Brief time-scale freeze. Repeated calls never stack the slow-down and the time scale is restored exactly once |

Plus one small helper autoload, `JuiceLite` (`juice_lite.gd`), that wires them together.

![Sprite Juice Kit Lite demo](screenshots/01_demo_overview.png)

Download page (zip): https://reebo0.itch.io/sprite-juice-kit-lite

**Requirements:** Godot 4.4 or newer (tested on 4.4.1, Windows, Compatibility renderer, plus a
headless smoke test). The shader is a plain `canvas_item` shader.

## Install

1. Copy the `addons/sprite_juice_lite` folder into your project's `addons/` folder.
2. Open **Project > Project Settings > Plugins** and enable **Sprite Juice Kit Lite**. This adds
   the `JuiceLite` autoload. (Or add it by hand under **Project Settings > Globals > Autoload**:
   path `res://addons/sprite_juice_lite/juice_lite.gd`, name `JuiceLite`.)
3. Call it from any script:

```gdscript
func _on_enemy_hurt(enemy: Sprite2D) -> void:
	JuiceLite.hit(enemy)           # flash + screen shake + tiny hit-stop

JuiceLite.flash(sprite, Color.RED, 0.12)   # just the flash
JuiceLite.shake(0.5)                       # needs a current Camera2D
JuiceLite.hitstop(0.06)                    # freeze for 0.06 s
```

Everything is named differently from the paid kit (`JuiceLite` instead of `Juice`, folder
`sprite_juice_lite`, classes `JuiceLiteHitStop` / `JuiceLiteScreenShake`), so you can have both
installed in one project without clashes.

## API

| Call | Notes |
|---|---|
| `JuiceLite.flash(node, color = white, time = 0.12) -> Tween` | Works on any `CanvasItem`. Restores the node's previous material afterwards |
| `JuiceLite.shake(amount = 0.5)` | Trauma 0..1, stacks and clamps at 1. Does nothing without a current `Camera2D` |
| `JuiceLite.hitstop(seconds = 0.06, slow_scale = 0.05)` | Longest single freeze is 0.5 s (`max_duration` on the node) |
| `JuiceLite.is_hitstopped() -> bool` | True while a hit-stop runs |
| `JuiceLite.hit(node, color, shake_amount, stop_time)` | Flash + shake + hit-stop in one call |

## Demo

Open the project in Godot and press F5. Keys: `1` hit flash, `2` screen shake, `3` hit-stop,
`4` all three, click a sprite to hit it, `Space` to change target. The demo's sprites are drawn
by code; there is no imported art and no third-party assets.

## Smoke test

```
godot --headless --path <project> res://tests/smoke_test.tscn
```

Prints `SMOKE TEST PASS` and exits 0 on success. (The headless renderer does not compile
shaders; run it without `--headless` to cover that too.)

## What is in the full kit

This free sample has 3 effects. The full **Sprite Juice Kit 2D** ($6) has:

- 9 sprite shaders (hit flash plus outline that is safe for sprite sheets, dissolve, shine,
  wobble, palette swap, pixelate, grayscale, silhouette), so 8 more than this sample
- 5 game-feel helpers (screen shake and hit-stop as here, plus squash and stretch, afterimage
  ghost trails and floating damage numbers), so 3 more than this sample
- 6 scene transitions (fade, circle, diamond, slide, dissolve, pixelate)
- The one-line `Juice` API, a bigger demo with a control for every effect, and a full README

Get it here: https://reebo0.itch.io/sprite-juice-kit-2d

## License

MIT, see `LICENSE`. Free for any use, including commercial. (The paid kit has its own license.)
Made by REEBOO Labs with the help of an AI coding assistant.
