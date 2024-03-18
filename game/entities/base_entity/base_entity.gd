class_name Entity
extends CharacterBody2D


@onready var sprite_2d = $Sprite2D


var position_z := 0
var height := 16
var radius := 8


var speed := 75


var max_hp := 100
var hp := 100


var target_group := "entity"


func _physics_process(_delta):
	move()


func move():
	pass


func heal_hp(input_heal : int):
	if input_heal <= 0:
		return
	hp = clamp(hp + input_heal, 0, max_hp)


func take_damage(input_damage : int):
	if input_damage <= 0:
		return
	if input_damage < hp:
		hp -= input_damage
	else:
		die()


func die():
	pass
	#queue_free()
