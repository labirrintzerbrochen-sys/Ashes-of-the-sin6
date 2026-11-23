extends CharacterBody2D

const SPEED = 200.0
var is_dead: bool = false
var is_attacking: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("idle large skull")
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Si está muerto, cae por gravedad y no procesa más acciones
	if is_dead:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity += get_gravity() * delta
		move_and_slide()
		return

	# Si está atacando, se detiene para lanzar las llamas
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# --- MOVIMIENTO VOLADOR ---
	# Aquí puedes cambiar esto por una IA de persecución o usar teclas de prueba
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		if direction.x != 0:
			animated_sprite.flip_h = direction.x < 0
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	# Animación por defecto cuando se mueve o está en reposo flotando
	animated_sprite.play("idle large skull")

	# Ejemplo para activar el ataque presionando la tecla 'E' (puedes cambiarlo por tu lógica de IA)
	if Input.is_action_just_pressed("ui_focus_next"): # O usa una tecla personalizada de tu Input Map
		attack()

	move_and_slide()

# Función para iniciar el ataque de fuego
func attack() -> void:
	if is_attacking or is_dead:
		return
	is_attacking = true
	animated_sprite.play("atack large skull")
	
	# AQUÍ PUEDES INSTANCIAR TU PROYECTIL DE LLAMA
	# Ejemplo:
	# var llama = preload("res://Escenas/llama.tscn").instantiate()
	# get_parent().add_child(llama)
	# llama.global_position = $PuntoSalidaLlama.global_position

# Función para activar la muerte del jefe
func die() -> void:
	if is_dead:
		return
	is_dead = true
	is_attacking = false
	animated_sprite.play("death large skull")

# Detecta cuándo terminan las animaciones de ataque o muerte
func _on_animation_finished() -> void:
	if animated_sprite.animation == "atack large skull":
		# Regresa a la normalidad cuando termina de lanzar las llamas
		is_attacking = false
		animated_sprite.play("idle large skull")
	elif animated_sprite.animation == "death large skull":
		# Elimina al jefe de la escena al terminar su animación de muerte (opcional)
		queue_free()
