extends Area2D

const RED = Color(0.89, 0.0534, 0.0534, 1)
const GREEN = Color(0.2079, 0.77, 0.2266, 1)

var elapsed_time = 0
var interacting = false
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.modulate = RED

func _physics_process(delta):
	if interacting:
		elapsed_time += delta
		$Sprite2D/ProgressBar.value = snapped(elapsed_time, 0.01)

func interact(value):
	interacting = value

func _on_progress_bar_value_changed(value):
	if value == $Sprite2D/ProgressBar.max_value:
		$Sprite2D.modulate = GREEN
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
