extends Area2D
class_name ResourceNode

# Tipos de recursos
enum ResourceType {
	TREE,
	STONE,
	BERRY_BUSH,
	WATER_SOURCE,
	METAL_ORE
}

@export var resource_type: ResourceType = ResourceType.TREE
@export var resource_name: String = "Madera"
@export var max_resources: int = 5
@export var respawn_time: float = 30.0
@export var required_tool: String = ""  # Herramienta necesaria para recolectar

var current_resources: int
var is_depleted: bool = false
var respawn_timer: float = 0.0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var interaction_area = $InteractionArea

signal resource_gathered(resource_name: String, amount: int)

func _ready():
	current_resources = max_resources
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	
	# Configurar apariencia según el tipo de recurso
	setup_resource_appearance()

func _process(delta):
	if is_depleted:
		respawn_timer += delta
		if respawn_timer >= respawn_time:
			respawn_resource()

func setup_resource_appearance():
	# Aquí configurarías los sprites según el tipo de recurso
	# Por ahora usamos colores diferentes para distinguir
	match resource_type:
		ResourceType.TREE:
			modulate = Color.BROWN
			resource_name = "Madera"
		ResourceType.STONE:
			modulate = Color.GRAY
			resource_name = "Piedra"
		ResourceType.BERRY_BUSH:
			modulate = Color.PURPLE
			resource_name = "Bayas"
		ResourceType.WATER_SOURCE:
			modulate = Color.BLUE
			resource_name = "Agua"
		ResourceType.METAL_ORE:
			modulate = Color.YELLOW
			resource_name = "Mineral"

func _on_player_entered(body):
	if body.name == "CharacterBody2D" and not is_depleted:
		# Mostrar indicador de interacción
		show_interaction_prompt(true)

func _on_player_exited(body):
	if body.name == "CharacterBody2D":
		show_interaction_prompt(false)

func show_interaction_prompt(show: bool):
	# Aquí mostrarías un indicador visual de que se puede interactuar
	# Por ahora solo cambiamos el brillo
	if show:
		modulate = modulate * 1.2
	else:
		modulate = modulate / 1.2

func gather_resource() -> bool:
	if is_depleted or current_resources <= 0:
		return false
	
	# Verificar si el jugador tiene la herramienta necesaria
	if required_tool != "" and not has_required_tool():
		print("Necesitas: ", required_tool)
		return false
	
	var gathered_amount = randi_range(1, min(3, current_resources))
	current_resources -= gathered_amount
	
	# Añadir al inventario del jugador
	GameManager.add_to_inventory(resource_name, gathered_amount)
	
	resource_gathered.emit(resource_name, gathered_amount)
	print("Recolectado: ", gathered_amount, " ", resource_name)
	
	if current_resources <= 0:
		deplete_resource()
	
	return true

func has_required_tool() -> bool:
	# Verificar si el jugador tiene la herramienta en el inventario
	return GameManager.get_inventory_count(required_tool) > 0

func deplete_resource():
	is_depleted = true
	respawn_timer = 0.0
	visible = false
	collision.disabled = true

func respawn_resource():
	is_depleted = false
	current_resources = max_resources
	visible = true
	collision.disabled = false
	print(resource_name, " ha reaparecido!")