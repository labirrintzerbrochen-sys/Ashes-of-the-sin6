extends CharacterBody2D

@export var damage: int = 25
var is_exploding: bool = false

# Referencias a los nodos (asegúrate de que se llamen así en tu escena)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea

func _ready() -> void:
	# Reproducir la animación inicial
	animated_sprite.play("idle demon mine")
	
	# Conectar las señales por código para detectar al jugador y el fin de la explosión
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Si ya está explotando, detenemos cualquier física o movimiento
	if is_exploding:
		return

	# Mantener la gravedad por si la mina está en el aire al iniciar
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

# Se activa cuando un cuerpo entra en el Area2D
func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_exploding:
		return
	
	# Verifica si el cuerpo que entró pertenece al grupo "player" (o se llama "Player")
	if body.is_in_group("player") or body.name == "Player":
		explode(body)

func explode(target: Node2D) -> void:
	is_exploding = true
	
	# Reproducir la animación de explosión
	animated_sprite.play("death demon mine")
	
	# Aplicar daño si el jugador tiene una función llamada "take_damage"
	if target.has_method("take_damage"):
		target.take_damage(damage)

# Se activa automáticamente cuando termina la animación de explosión
func _on_animation_finished() -> void:
	if animated_sprite.animation == "death demon mine":
		queue_free() # Elimina la mina de la escena
