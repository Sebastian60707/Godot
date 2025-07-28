extends Control

# Referencias a elementos de UI
@onready var health_bar = $VBoxContainer/HealthBar
@onready var hunger_bar = $VBoxContainer/HungerBar
@onready var thirst_bar = $VBoxContainer/ThirstBar
@onready var time_label = $VBoxContainer/TimeLabel
@onready var inventory_label = $VBoxContainer/InventoryLabel

func _ready():
	# Conectar señales del GameManager
	GameManager.player_stats_changed.connect(_on_player_stats_changed)
	GameManager.inventory_changed.connect(_on_inventory_changed)
	GameManager.day_night_changed.connect(_on_day_night_changed)
	
	# Actualizar UI inicial
	update_all_ui()

func _process(delta):
	update_time_display()

func _on_player_stats_changed():
	update_stats_bars()

func _on_inventory_changed():
	update_inventory_display()

func _on_day_night_changed(is_day: bool):
	if is_day:
		time_label.text = "DÍA"
		time_label.modulate = Color.YELLOW
	else:
		time_label.text = "NOCHE"
		time_label.modulate = Color.BLUE

func update_all_ui():
	update_stats_bars()
	update_inventory_display()

func update_stats_bars():
	if health_bar:
		health_bar.value = GameManager.player_health
		health_bar.max_value = GameManager.player_max_health
	
	if hunger_bar:
		hunger_bar.value = GameManager.player_hunger
	
	if thirst_bar:
		thirst_bar.value = GameManager.player_thirst

func update_inventory_display():
	if inventory_label:
		var inventory_text = "Inventario:\n"
		for item in GameManager.inventory:
			inventory_text += item + ": " + str(GameManager.inventory[item]) + "\n"
		inventory_label.text = inventory_text

func update_time_display():
	var time_of_day = fmod(GameManager.current_time, GameManager.day_length) / GameManager.day_length
	var hours = int(time_of_day * 24)
	var minutes = int((time_of_day * 24 - hours) * 60)
	
	# No actualizar el label de tiempo aquí para evitar conflictos
	# El tiempo se muestra en _on_day_night_changed