extends StaticBody2D

const RED = Color(0.89, 0.0534, 0.0534, 1)
const LRED = Color(0.94, 0.145, 0.056, 1)
const GREEN = Color(0.2079, 0.77, 0.2266, 1)

@onready var anim_player = $AnimationPlayer

var elapsed_time = 0
var can_be_picked = false
var mouse_hovered = false
var interacting = false
var cat: Node2D = null
var cat_stay := 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.modulate = RED

func _input(event):
	if Input.is_action_just_pressed("interact") \
	and can_be_picked and mouse_hovered:
		interacting = true
		anim_player.play("interacted")
		

func _physics_process(delta):
	if can_be_picked and interacting:
		if cat:
			if cat_stay < elapsed_time:
				cat.pick_new_target()
				elapsed_time = 0
			else:
				elapsed_time += delta
		else:
			elapsed_time = 0
	else:
		if anim_player.is_playing():
			anim_player.stop()
		interacting = false
		if not cat:
			elapsed_time = 0


func _on_mouse_entered():
	mouse_hovered = true
	if can_be_picked:
		$Sprite2D.modulate = LRED


func _on_mouse_exited():
	mouse_hovered = false
	$Sprite2D.modulate = RED

func set_can_be_picked(value):
	can_be_picked = value
	if mouse_hovered:
		$Sprite2D.modulate = LRED
