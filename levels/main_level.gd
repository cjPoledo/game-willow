extends Node2D

const ENDPOINT = Vector2(1920, 1080)

@export var init_obstacles := 10
@export var obs_safe_radius := 150

@onready var nav_region := $NavigationRegion2D
@onready var cat := $Cat

var obstacles := []
var obstacle_scene := preload("res://entities/hide_spot.tscn")

func _ready():
	for i in init_obstacles:
		var obstacle_instance = obstacle_scene.instantiate()
		
		var looking_for_pos = true
		# check if obstacle is close to edge or other obstacles
		while looking_for_pos:
			obstacle_instance.position = Vector2(randi_range(obs_safe_radius, ENDPOINT.x - obs_safe_radius), \
												 randi_range(obs_safe_radius, ENDPOINT.y - obs_safe_radius))
			looking_for_pos = false
			for obs in obstacles:
				if obstacle_instance.position.distance_to(obs.position) < obs_safe_radius:
					looking_for_pos = true
					break
			
		obstacles.append(obstacle_instance)
		nav_region.add_child(obstacle_instance)
		cat.hide_spots.append(obstacle_instance.position)
	nav_region.bake_navigation_polygon()
	cat.start_movement()
