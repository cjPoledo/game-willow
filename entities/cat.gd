extends Area2D

signal caught(hid, hover, dodge)

const LIGHTEN = Color(2, 2, 2, 1)
const DEFAULT_COL = Color(1, 1, 1, 1)

@export var speed := 70
@export var jump_chance := 0.50

@onready var nav := $NavigationAgent2D
@onready var sprite := $AnimatedSprite2D
@onready var pause_timer := $InitPause
@onready var collision := $CollisionShape2D
@onready var anim_player := $AnimationPlayer
@onready var tease_sprite := $AnimatedSprite2D/AnimatedSprite2D

var can_be_picked = false
var mouse_hovered = false
var finished = true
var hide_spots := []
var last_hide_spot: Node2D = null
var invul_phase = false

# score counters
var hid := 0
var hovers := 0
var dodges := 0

func start_movement():
	pick_new_target()

func _input(event):
	if Input.is_action_just_pressed("interact") \
	and can_be_picked and mouse_hovered:
		if invul_phase or randf_range(0, 1) < jump_chance:
			anim_player.stop()
			anim_player.play("cat_jump")
			sprite.stop()
			sprite.play("jump")
			tease_sprite.visible = true
			invul_phase = true
			pause_timer.start()
			dodges += 1
			return
		emit_signal("caught", hid, hovers, dodges)
		pause_timer.stop()
		anim_player.stop()
		sprite.stop()
		invul_phase = true
		collision.disabled = true
		finished = true
		visible = false

func _physics_process(delta):
	if not finished:
		var direction = (nav.get_next_path_position() - position).normalized()
		if direction.x > 0:
			sprite.flip_h = false
		elif direction.x < 0:
			sprite.flip_h = true
		translate(direction * speed * delta)

func _on_mouse_entered():
	mouse_hovered = true
	if can_be_picked:
		Input.set_custom_mouse_cursor(GlobalObserver.open_hand_cursor)
		GlobalObserver.custom_mouse = true
		sprite.modulate = LIGHTEN


func _on_mouse_exited():
	if can_be_picked:
		hovers += 1
	mouse_hovered = false
	Input.set_custom_mouse_cursor(null)
	GlobalObserver.custom_mouse = false
	sprite.modulate = DEFAULT_COL

func set_can_be_picked(value):
	can_be_picked = value
	if mouse_hovered and can_be_picked:
		Input.set_custom_mouse_cursor(GlobalObserver.open_hand_cursor)
		GlobalObserver.custom_mouse = true
		sprite.modulate = LIGHTEN
	else:
		Input.set_custom_mouse_cursor(null)
		GlobalObserver.custom_mouse = false
		sprite.modulate = DEFAULT_COL


func pick_new_target():
	if not hide_spots.is_empty():
		var new_target = hide_spots.pick_random()
		while last_hide_spot == new_target:
			new_target = hide_spots.pick_random()
		nav.target_position = new_target.position + Vector2(randi_range(-5, 5), randi_range(-5, 5)) # to randomize which side the cat enters
		last_hide_spot = new_target
		#finished = false
		invul_phase = true
		visible = true
		finished = false
		pause_timer.start()


func _on_navigation_agent_2d_navigation_finished():
	finished = true
	visible = false
	position = last_hide_spot.position + Vector2(randi_range(-5, 5), randi_range(-5, 5))
	last_hide_spot.set_has_cat(self)
	last_hide_spot.cat_stay = randf_range(0, 3)
	hid += 1


func _on_init_pause_timeout():
	#finished = false
	invul_phase = false


func _on_animated_sprite_2d_animation_finished():
	sprite.play("default")
	tease_sprite.visible = false
