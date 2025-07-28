extends Node

# Referencias
var player: CharacterBody2D
var world_generator: WorldGenerator

func _ready():
	# Buscar referencias en la escena
	player = get_tree().get_first_node_in_group("player")
	world_generator = get_tree().get_first_node_in_group("world_generator")

func _process(delta):
	if player and world_generator:
		# Actualizar mundo alrededor del jugador
		world_generator.update_world_around_player(player.global_position)
		
		# Manejar interacciones
		handle_interactions()

func handle_interactions():
	if Input.is_action_just_pressed("ui_accept"):  # Tecla Enter o Espacio
		interact_with_nearby_resources()

func interact_with_nearby_resources():
	if not player:
		return
	
	# Buscar recursos cercanos
	var space_state = player.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = player.global_position
	query.collision_mask = 1  # Layer de recursos
	
	var results = space_state.intersect_point(query, 10)
	
	for result in results:
		var body = result["collider"]
		if body.has_method("gather_resource"):
			body.gather_resource()
			break  # Solo interactuar con un recurso a la vez