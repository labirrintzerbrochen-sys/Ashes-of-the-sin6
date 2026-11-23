extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_dead: bool = false

# Asegúrate de que el nodo se llame AnimatedSprite2D en tu escena
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Si está muerto, detiene el movimiento y mantiene la animación de muerte
	if is_dead:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	# Añadir la gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Manejar el salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Obtener la dirección de entrada y manejar el movimiento
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0 # Voltea el sprite según hacia dónde se mueva
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Mientras esté vivo (quieto, caminando o saltando), usa siempre "idle demon eye"
	animated_sprite.play("idle demon eye")

	move_and_slide()

# Llama a esta función cuando el personaje muera (por ejemplo, al recibir daño)
func die() -> void:
	if is_dead:
		return
	is_dead = true
	animated_sprite.play("death demon eye")
