extends Enemy


func _init():
	max_hp = 60
	hp = 60


func attack():
	create_bullet()


func create_bullet():
	var new_bullet = RED_BULLET.instantiate()
	new_bullet.position = self.position
	new_bullet.init((player.position - self.position).normalized(), randi_range(5, 25), target_group)
	get_parent().add_child(new_bullet)
