class_name ScreenPolygon
extends Node


var texture_key : String


var points : PackedVector2Array


func _init(new_points, new_texture_key):
	points = new_points
	texture_key = new_texture_key
