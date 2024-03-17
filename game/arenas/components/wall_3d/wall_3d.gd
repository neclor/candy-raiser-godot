class_name Wall3D


static var textures := {}
var texture_key : String


var points : PackedVector3Array


func _init(new_points : PackedVector3Array, new_texture_key : String):
	points = new_points
	texture_key = new_texture_key
