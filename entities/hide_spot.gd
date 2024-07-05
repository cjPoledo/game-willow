extends StaticBody2D

const LIGHTEN = Color(2, 2, 2, 1)
const DEFAULT_COL = Color(1, 1, 1, 1)
const NUM_OBJ = 2

@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var thud = $thud

var elapsed_time = 0
var can_be_picked = false
var mouse_hovered = false
var interacting = false
var cat: Node2D = null
var cat_stay := 3
var sprite_frame = 0

func _ready():
	sprite.frame = sprite_frame

func _input(event):
	if Input.is_action_just_pressed("interact") \
	and can_be_picked and mouse_hovered:
		interacting = true
		anim_player.play("interacted")
		thud.play()

func _physics_process(delta):
	if can_be_picked and interacting:
		if cat:
			if cat_stay < elapsed_time:
				cat.pick_new_target()
				set_has_cat(null)
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
		Input.set_custom_mouse_cursor(GlobalObserver.open_hand_cursor)
		GlobalObserver.custom_mouse = true
		$Sprite2D.modulate = LIGHTEN


func _on_mouse_exited():
	mouse_hovered = false
	Input.set_custom_mouse_cursor(null)
	GlobalObserver.custom_mouse = false
	$Sprite2D.modulate = DEFAULT_COL

func set_can_be_picked(value):
	can_be_picked = value
	if mouse_hovered and value:
		Input.set_custom_mouse_cursor(GlobalObserver.open_hand_cursor)
		GlobalObserver.custom_mouse = true
		$Sprite2D.modulate = LIGHTEN
	else:
		Input.set_custom_mouse_cursor(null)
		GlobalObserver.custom_mouse = false
		$Sprite2D.modulate = DEFAULT_COL

func set_has_cat(value):
	cat = value
	if cat:
		sprite.frame = sprite_frame + NUM_OBJ
	else:
		sprite.frame = sprite_frame
