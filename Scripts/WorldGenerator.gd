extends Node2D
class_name WorldGenerator

# Configuración del mundo
@export var world_size: Vector2i = Vector2i(100, 100)
@export var chunk_size: int = 16
@export var noise_scale: float = 0.1
@export var resource_density: float = 0.05

# Referencias a nodos
@onready var tilemap: TileMap = $TileMap
@onready var resources_container: Node2D = $Resources

# Recursos para generar
var resource_scenes: Dictionary = {}
var generated_chunks: Dictionary = {}

# Noise para generación procedural
var terrain_noise: FastNoiseLite
var resource_noise: FastNoiseLite

# Tipos de terreno
enum TerrainType {
	GRASS,
	DIRT,
	STONE,
	WATER,
	SAND
}

func _ready():
	# Añadir al grupo de generadores de mundo
	add_to_group("world_generator")
	
	setup_noise()
	setup_resource_scenes()
	generate_initial_world()

func setup_noise():
	# Configurar noise para terreno
	terrain_noise = FastNoiseLite.new()
	terrain_noise.seed = GameManager.world_seed
	terrain_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	terrain_noise.frequency = noise_scale
	
	# Configurar noise para recursos
	resource_noise = FastNoiseLite.new()
	resource_noise.seed = GameManager.world_seed + 1000
	resource_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	resource_noise.frequency = 0.02

func setup_resource_scenes():
	# Aquí cargarías las escenas de recursos cuando las tengas
	# Por ahora crearemos recursos programáticamente
	pass

func generate_initial_world():
	# Generar chunks iniciales alrededor del jugador
	var player_chunk = Vector2i(0, 0)
	var render_distance = 3
	
	for x in range(-render_distance, render_distance + 1):
		for y in range(-render_distance, render_distance + 1):
			var chunk_pos = player_chunk + Vector2i(x, y)
			generate_chunk(chunk_pos)

func generate_chunk(chunk_pos: Vector2i):
	if generated_chunks.has(chunk_pos):
		return
	
	generated_chunks[chunk_pos] = true
	
	var start_pos = chunk_pos * chunk_size
	
	# Generar terreno
	for x in range(chunk_size):
		for y in range(chunk_size):
			var world_pos = start_pos + Vector2i(x, y)
			var terrain_type = get_terrain_type(world_pos)
			place_terrain_tile(world_pos, terrain_type)
			
			# Generar recursos
			if should_place_resource(world_pos, terrain_type):
				place_resource(world_pos, terrain_type)

func get_terrain_type(pos: Vector2i) -> TerrainType:
	var noise_value = terrain_noise.get_noise_2d(pos.x, pos.y)
	
	# Mapear valores de noise a tipos de terreno
	if noise_value < -0.3:
		return TerrainType.WATER
	elif noise_value < -0.1:
		return TerrainType.SAND
	elif noise_value < 0.2:
		return TerrainType.GRASS
	elif noise_value < 0.4:
		return TerrainType.DIRT
	else:
		return TerrainType.STONE

func place_terrain_tile(pos: Vector2i, terrain_type: TerrainType):
	var source_id = 0  # ID de la fuente del tileset
	var atlas_coords = Vector2i(0, 0)  # Coordenadas en el atlas
	
	# Mapear tipo de terreno a coordenadas del tileset
	match terrain_type:
		TerrainType.GRASS:
			atlas_coords = Vector2i(0, 0)  # Pasto
		TerrainType.DIRT:
			atlas_coords = Vector2i(1, 0)  # Tierra
		TerrainType.STONE:
			atlas_coords = Vector2i(2, 0)  # Piedra
		TerrainType.WATER:
			atlas_coords = Vector2i(3, 0)  # Agua
		TerrainType.SAND:
			atlas_coords = Vector2i(4, 0)  # Arena
	
	tilemap.set_cell(0, pos, source_id, atlas_coords)

func should_place_resource(pos: Vector2i, terrain_type: TerrainType) -> bool:
	if terrain_type == TerrainType.WATER:
		return false
	
	var resource_value = resource_noise.get_noise_2d(pos.x, pos.y)
	return resource_value > (1.0 - resource_density)

func place_resource(pos: Vector2i, terrain_type: TerrainType):
	var resource_type = get_resource_type_for_terrain(terrain_type)
	var resource_node = create_resource_node(resource_type)
	
	resource_node.position = Vector2(pos.x * 32, pos.y * 32)  # Asumiendo tiles de 32x32
	resources_container.add_child(resource_node)

func get_resource_type_for_terrain(terrain_type: TerrainType) -> ResourceNode.ResourceType:
	match terrain_type:
		TerrainType.GRASS:
			return [ResourceNode.ResourceType.TREE, ResourceNode.ResourceType.BERRY_BUSH][randi() % 2]
		TerrainType.DIRT:
			return ResourceNode.ResourceType.TREE
		TerrainType.STONE:
			return [ResourceNode.ResourceType.STONE, ResourceNode.ResourceType.METAL_ORE][randi() % 2]
		TerrainType.SAND:
			return ResourceNode.ResourceType.STONE
		_:
			return ResourceNode.ResourceType.TREE

func create_resource_node(resource_type: ResourceNode.ResourceType) -> ResourceNode:
	var resource_node = preload("res://Scenes/ResourceNode.tscn").instantiate()
	resource_node.resource_type = resource_type
	return resource_node

func update_world_around_player(player_pos: Vector2):
	var player_chunk = Vector2i(int(player_pos.x / (chunk_size * 32)), int(player_pos.y / (chunk_size * 32)))
	var render_distance = 3
	
	# Generar nuevos chunks si es necesario
	for x in range(-render_distance, render_distance + 1):
		for y in range(-render_distance, render_distance + 1):
			var chunk_pos = player_chunk + Vector2i(x, y)
			if not generated_chunks.has(chunk_pos):
				generate_chunk(chunk_pos)