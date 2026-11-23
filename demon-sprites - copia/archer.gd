extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_dead: bool = false
var is_hurt: bool = false
var is_shooting: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("idle archer")
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# 1. Si está muerto, detiene todo y aplica gravedad para que caiga
	if is_dead:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	# 2. Si está recibiendo daño o disparando, se queda quieto hasta que termine la animación
	if is_hurt or is_shooting:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	# --- FÍSICAS NORMALES (Gravedad, Salto y Movimiento) ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- GESTIÓN DE ANIMACIONES DE MOVIMIENTO E IDLE ---
	if is_on_floor():
		if direction != 0:
			animated_sprite.play("walk archer")
		else:
			animated_sprite.play("idle archer")
	else:
		# Si está saltando o cayendo, puedes usar idle o walk según prefieras
		animated_sprite.play("idle archer")

	# Ejemplo para disparar presionando una tecla (ej. 'ui_focus_next' o crea una acción "shoot")
	if Input.is_action_just_pressed("ui_focus_next") and is_on_floor():
		shoot()

	move_and_slide()

# --- FUNCIONES DE ESTADO (Disparo, Daño y Muerte) ---

func shoot() -> void:
	if is_shooting or is_hurt or is_dead:
		return
	is_shooting = true
	animated_sprite.play("archer shoot")
	
	# AQUÍ PUEDES INSTANCIAR TU FLECHA:
	# var flecha = preload("res://Escenas/flecha.tscn").instantiate()
	# get_parent().add_child(flecha)
	# flecha.global_position = $PuntoDisparo.global_position
	# flecha.set_direction(-1 if animated_sprite.flip_h else 1)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	is_hurt = true
	is_shooting = false
	animated_sprite.play("archer hurt")
	# Aquí puedes restarle vida a tu arquero

func die() -> void:
	if is_dead:
		return
	is_dead = true
	is_hurt = false
	is_shooting = false
	animated_sprite.play("death archer")

# --- CONTROLADOR DE FIN DE ANIMACIONES ---
func _on_animation_finished() -> void:
	if animated_sprite.animation == "archer shoot":
		is_shooting = false
	elif animated_sprite.animation == "archer hurt":
		is_hurt = false
	elif animated_sprite.animation == "death archer":
		# Opcional: Desactiva colisiones o elimina al personaje al terminar de morir
		# queue_free()
		pass
