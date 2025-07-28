extends Node

# Singleton para manejar el estado global del juego
signal player_stats_changed
signal inventory_changed
signal day_night_changed

# Estadísticas del jugador
var player_health: int = 100
var player_max_health: int = 100
var player_hunger: int = 100
var player_thirst: int = 100
var player_stamina: int = 100
var player_level: int = 1
var player_experience: int = 0

# Sistema de inventario básico
var inventory: Dictionary = {}
var max_inventory_slots: int = 20

# Sistema día/noche
var current_time: float = 0.0
var day_length: float = 300.0  # 5 minutos por día
var is_day: bool = true

# Recursos del mundo
var world_seed: int = 0

func _ready():
	# Generar semilla aleatoria para el mundo
	world_seed = randi()
	print("Mundo generado con semilla: ", world_seed)

func _process(delta):
	update_time_system(delta)
	update_survival_stats(delta)

func update_time_system(delta):
	current_time += delta
	var time_of_day = fmod(current_time, day_length) / day_length
	
	var was_day = is_day
	is_day = time_of_day < 0.5  # Primera mitad del día es día, segunda es noche
	
	if was_day != is_day:
		day_night_changed.emit(is_day)

func update_survival_stats(delta):
	# Reducir hambre y sed gradualmente
	var stat_decrease_rate = 1.0  # puntos por segundo
	
	player_hunger = max(0, player_hunger - stat_decrease_rate * delta)
	player_thirst = max(0, player_thirst - stat_decrease_rate * delta)
	
	# Si hambre o sed están bajas, reducir salud
	if player_hunger <= 20 or player_thirst <= 20:
		player_health = max(0, player_health - stat_decrease_rate * delta)
	
	player_stats_changed.emit()

func add_to_inventory(item_name: String, quantity: int = 1) -> bool:
	if inventory.has(item_name):
		inventory[item_name] += quantity
	else:
		if inventory.size() >= max_inventory_slots:
			return false  # Inventario lleno
		inventory[item_name] = quantity
	
	inventory_changed.emit()
	return true

func remove_from_inventory(item_name: String, quantity: int = 1) -> bool:
	if not inventory.has(item_name) or inventory[item_name] < quantity:
		return false
	
	inventory[item_name] -= quantity
	if inventory[item_name] <= 0:
		inventory.erase(item_name)
	
	inventory_changed.emit()
	return true

func get_inventory_count(item_name: String) -> int:
	return inventory.get(item_name, 0)