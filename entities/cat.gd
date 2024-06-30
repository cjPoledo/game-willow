extends Area2D

@export var speed := 800

@onready var nav := $NavigationAgent2D

var can_be_picked = false
var mouse_hovered = false
var finished = true
var hide_spots := []
var last_hide_spot: Node2D = null

func start_movement():
	pick_new_target()

func _input(event):
	if Input.is_action_just_pressed("interact") \
	and can_be_picked and mouse_hovered:
		print("you win")
		finished = true
		$CollisionShape2D.disabled = true

func _physics_process(delta):
	if not finished:
		var direction = (nav.get_next_path_position() - position).normalized()
		translate(direction * speed * delta)

func _on_mouse_entered():
	mouse_hovered = true


func _on_mouse_exited():
	mouse_hovered = false

func set_can_be_picked(value):
	can_be_picked = value


func pick_new_target():
	if last_hide_spot:
		last_hide_spot.cat = null
	if not hide_spots.is_empty():
		var new_target = hide_spots.pick_random()
		while nav.target_position.distance_squared_to(new_target) <= 200:
			new_target = hide_spots.pick_random()
		nav.target_position = new_target + Vector2(randi_range(-10, 10), randi_range(-10, 10)) # to randomize which side the cat enters
		finished = false
		visible = true


func _on_navigation_agent_2d_navigation_finished():
	finished = true
	visible = false
	position = last_hide_spot.position + Vector2(randi_range(-50, 50), randi_range(-50, 50))


func _on_body_entered(body):
	if body.is_in_group("hide_spot"):
		last_hide_spot = body
		body.cat = self
		body.cat_stay = randf_range(0, 3)
