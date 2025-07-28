extends CharacterBody2D

# Configuración del jugador
@export var speed: float = 100.0
@export var acceleration: float = 500.0
@export var friction: float = 500.0

# Referencias a nodos
@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D

# Variables de estado
var last_direction = Vector2.DOWN
var is_moving = false

func _ready():
	# Añadir al grupo de jugadores
	add_to_group("player")
	
	# Configurar la cámara
	camera.enabled = true
	# Inicializar animación
	animated_sprite.play("Abajo")

func _physics_process(delta):
	handle_input()
	apply_movement(delta)
	update_animation()

func handle_input():
	# Obtener input del jugador
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ARRIBA"):
		input_vector.y -= 1
	if Input.is_action_pressed("ABAJO"):
		input_vector.y += 1
	if Input.is_action_pressed("IZQUIERDA"):
		input_vector.x -= 1
	if Input.is_action_pressed("DERECHA"):
		input_vector.x += 1
	
	# Normalizar para movimiento diagonal consistente
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		last_direction = input_vector
		is_moving = true
	else:
		is_moving = false
	
	# Aplicar aceleración o fricción
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * get_physics_process_delta_time())
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * get_physics_process_delta_time())

func apply_movement(delta):
	move_and_slide()

func update_animation():
	if is_moving:
		# Determinar qué animación reproducir basada en la dirección
		if abs(last_direction.x) > abs(last_direction.y):
			if last_direction.x > 0:
				animated_sprite.play("Derecha")
			else:
				animated_sprite.play("Izquierda")
		else:
			if last_direction.y > 0:
				animated_sprite.play("Abajo")
			else:
				animated_sprite.play("Arriba")
	else:
		# Detener animación pero mantener el frame actual
		animated_sprite.stop()