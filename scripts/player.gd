extends CharacterBody2D

# Velocidades
const VELOCIDAD = 150.0
const ACELERACION = 800.0
const FRICCION = 500.0
const FUERZA_SALTO = -300.0
const GRAVEDAD = 900.0

# Dash
const VELOCIDAD_DASH = 300.0
const TIEMPO_DASH = 0.2  # segundos

# Trepar
const VELOCIDAD_TREPADA = 100.0
const AGUANTE_MAXIMO = 2.0  # segundos que puede trepar

var esta_dasheando = false
var temporizador_dash = 0.0
var puede_dashear = true

var agarrando_pared = false
var aguante = AGUANTE_MAXIMO

func _physics_process(delta):
	var direccion_entrada = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Chequear si está tocando una pared
	var tocando_pared = is_on_wall()
	
	# Agarrarse de la pared
	if tocando_pared and Input.is_action_pressed("ui_grab") and aguante > 0:
		agarrando_pared = true
	else:
		agarrando_pared = false
	
	if agarrando_pared:
		# Mientras se agarra, puede trepar o bajar
		aguante -= delta
		velocity.y = 0  # detener la caída mientras se agarra
		
		if Input.is_action_pressed("ui_up"):
			velocity.y = -VELOCIDAD_TREPADA
		elif Input.is_action_pressed("ui_down"):
			velocity.y = VELOCIDAD_TREPADA
	else:
		# Si no se está agarrando
		if not esta_dasheando:
			# Aceleración horizontal
			if direccion_entrada != 0:
				velocity.x = move_toward(velocity.x, direccion_entrada * VELOCIDAD, ACELERACION * delta)
			else:
				# Frenado suave
				velocity.x = move_toward(velocity.x, 0, FRICCION * delta)

			# Gravedad
			if not is_on_floor():
				velocity.y += GRAVEDAD * delta
			else:
				velocity.y = 0
				puede_dashear = true
				aguante = AGUANTE_MAXIMO  # se reinicia el aguante al tocar el suelo

		# Salto
		if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or agarrando_pared):
			velocity.y = FUERZA_SALTO

			# Si salta desde la pared, impulso horizontal
			if agarrando_pared:
				if Input.get_action_strength("ui_right") > 0:
					velocity.x = -VELOCIDAD  # Salta hacia la izquierda
				elif Input.get_action_strength("ui_left") > 0:
					velocity.x = VELOCIDAD  # Salta hacia la derecha

	agarrando_pared = false  # Suelta la pared al saltar
	# Dash
	if Input.is_action_just_pressed("ui_select") and puede_dashear:
		esta_dasheando = true
		temporizador_dash = TIEMPO_DASH
		puede_dashear = false

		# Dirección del dash
		var direccion_dash = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized()

		if direccion_dash == Vector2.ZERO:
			direccion_dash = Vector2(1, 0)  # por defecto hacia la derecha

		velocity = direccion_dash * VELOCIDAD_DASH

	# Actualización del dash
	if esta_dasheando:
		temporizador_dash -= delta
		if temporizador_dash <= 0:
			esta_dasheando = false
	
	move_and_slide()
