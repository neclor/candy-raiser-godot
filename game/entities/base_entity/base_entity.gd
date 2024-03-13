class_name Entity
extends CharacterBody2D


var position_z := 0
var height := 32


var speed := 100


var max_hp := 100
var hp := 100


func _physics_process(_delta):
	move()


func move():
	pass


func heal_hp(input_heal : int):
	if input_heal <= 0:
		return
	hp += input_heal
	if hp > max_hp:
		hp = max_hp


func take_damage(input_damage : int):
	if input_damage <= 0:
		return
	if input_damage < hp:
		hp -= input_damage
	else:
		die()


func die():
	queue_free()
