extends Panel

# Update the actor display
func update_actor(actor):
	get_node("TextureRect").texture = actor.get_portrait()
	get_node("NameLabel").text = actor.get_name()
	get_node("HealthLabel").text = str(actor.get_health())
