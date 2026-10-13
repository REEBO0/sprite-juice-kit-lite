@tool
extends EditorPlugin
## Registers the JuiceLite autoload when the plugin is enabled (Project Settings > Plugins).
## You can also add the autoload by hand: name "JuiceLite", path res://addons/sprite_juice_lite/juice_lite.gd
## It uses different names than the paid Sprite Juice Kit 2D ("Juice"), so both can be installed together.

const AUTOLOAD_NAME := "JuiceLite"
const AUTOLOAD_PATH := "res://addons/sprite_juice_lite/juice_lite.gd"


func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)


func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
