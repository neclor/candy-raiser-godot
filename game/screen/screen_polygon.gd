class_name ScreenPolygon
extends Node


var texture : Texture2D
var points : PackedVector2Array
var distance : float


func _init(new_points, new_distance, new_texture):
	points = new_points
	distance = new_distance
	texture = new_texture
	#texture_key = new_texture_key
