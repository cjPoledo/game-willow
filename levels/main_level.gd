extends Node2D

const ENDPOINT = Vector2(320 - 16*5, 256)

@export var init_obstacles := 10
@export var obs_safe_radius := 20

@onready var nav_region := $NavigationRegion2D
@onready var spawn_location := $SpawnLoc
@onready var animation_player := $AnimationPlayer
@onready var camera := $StartCam
@onready var ui := $UI
@onready var tilemap := $NavigationRegion2D/TileMap
@onready var thud := $thud

var obstacles := []
var obstacle_scene := preload("res://entities/hide_spot.tscn")
var player_scene := preload("res://entities/player.tscn")
var cat_scene := preload("res://entities/cat.tscn")
var cat = null

func _ready():
	var cat_instance = cat_scene.instantiate()
	for i in init_obstacles:
		var obstacle_instance = obstacle_scene.instantiate()
		
		var looking_for_pos = true
		# check if obstacle is close to edge or other obstacles
		while looking_for_pos:
			obstacle_instance.position = Vector2(randi_range(obs_safe_radius, ENDPOINT.x - obs_safe_radius), \
												 randi_range(obs_safe_radius + 2*16, ENDPOINT.y - obs_safe_radius))
			looking_for_pos = false
			for obs in obstacles:
				if obstacle_instance.position.distance_to(obs.position) < obs_safe_radius:
					looking_for_pos = true
					break
		obstacle_instance.sprite_frame = randi_range(0, 1)
		obstacles.append(obstacle_instance)
		nav_region.add_child(obstacle_instance)
	cat_instance.hide_spots = obstacles
	nav_region.bake_navigation_polygon()
	# spawn cat
	cat_instance.position = spawn_location.position
	nav_region.add_child(cat_instance)
	cat_instance.start_movement()
	animation_player.play("start_zoom")
	
	cat_instance.connect("caught", ui.game_over)
	cat = cat_instance


func _on_animation_player_animation_finished(anim_name):
	# spawn player
	var player_instance = player_scene.instantiate()
	player_instance.position = spawn_location.position
	player_instance.connect("done_walking", end_scene)
	cat.connect("caught", player_instance.game_over)
	nav_region.add_child(player_instance)
	ui.started = true

func end_scene():
	await get_tree().create_timer(1).timeout
	tilemap.set_cell(0, Vector2i(19, 13), 0, Vector2i(3, 1))
	thud.play()
	await get_tree().create_timer(0.3).timeout
	tilemap.set_cell(0, Vector2i(19, 13), 0, Vector2i(3, 0))
	thud.play()
