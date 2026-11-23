extends CharacterBody2D

const SPEED = 250.0
var is_dead: bool = false

# Referencia al nodo AnimatedSprite2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("idle flying demon")
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Si muere, cae por gravedad y no puede moverse
	if is_dead:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity += get_gravity() * delta # Cae al suelo al morir
		move_and_slide()
		return

	# --- MOVIMIENTO VOLADOR (4 DIRECCIONES) ---
	# Nota: Si es un enemigo controlado por IA, reemplaza estas 4 líneas por la lógica de persecución
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		# Voltea el sprite horizontalmente según hacia dónde vuele
		if direction.x != 0:
			animated_sprite.flip_h = direction.x < 0
	else:
		# Frenado suave en el aire
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	# Mantiene la animación de vuelo tanto quieto en el aire como moviéndose
	animated_sprite.play("idle flying demon")

	move_and_slide()

# Llama a esta función cuando el demonio reciba daño fatal
func die() -> void:
	if is_dead:
		return
	is_dead = true
	animated_sprite.play("death flying demon")

# Elimina el nodo cuando termina la animación de muerte (opcional)
func _on_animation_finished() -> void:
	if animated_sprite.animation == "death flying demon":
		queue_free()
