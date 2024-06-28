extends Area2D

var player = null

func interact(value):
	print("you win")
	player.set_can_interact(false, null)
	$CollisionShape2D.disabled = true

func _on_body_entered(body):
	if body.name == "Player":
		body.set_can_interact(true, self)
		player = body


func _on_body_exited(body):
	if body.name == "Player":
		body.set_can_interact(false, null)
		player = null
