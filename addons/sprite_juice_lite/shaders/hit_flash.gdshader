shader_type canvas_item;
// Sprite Juice Kit Lite - HIT FLASH
// Blends the sprite toward a solid color. Alpha is kept, so the sprite shape stays the same.
// Tip: tween flash_amount from 1.0 to 0.0, or just call JuiceLite.flash(node).

// Color the sprite flashes to (usually white or red).
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// 0 = normal sprite, 1 = solid flash color.
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	c.rgb = mix(c.rgb, flash_color.rgb, flash_amount);
	COLOR = c;
}
