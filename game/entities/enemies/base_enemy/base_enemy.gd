extends Entity


@onready var player = get_parent().get_node_or_null("Player")








#func move():
	#if player:
		#move_direction_vector = global_position.direction_to(player.global_position).normalized()
		#move_step()
	#else:
		#player = get_parent().get_node_or_null("Player")
