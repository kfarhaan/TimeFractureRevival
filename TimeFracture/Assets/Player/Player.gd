extends CharacterBody3D


const SPEED = 5.0
const SPRINTSPEED = 8.0
const JUMP_VELOCITY = 4.5

@export_range(0, 10, 0.01) var Sensitivity : float = 3  #  controllable Sensitivity variable in 0.01 increments
@export var SprintTime : float = 5  # 5 seconds of sprint time
@export var Controlled : bool

var sprintTimeReset : float

var minPitch = deg_to_rad(-80)
var maxPitch = deg_to_rad(90)
var speed : float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var grapplePosition : Vector3 = Vector3(0,0,0)  # base grapple position
var direction : Vector3 = Vector3(0,0,0)
var playerIsDead
@export var health : float = 100

signal PlayerDeath(player, killer)

var aiming : bool
var cameraStartUpFOV : int

func _ready():
	Input.mouse_mode = Input. MOUSE_MODE_CAPTURED  # captures mouse to keep it in the game window
	sprintTimeReset = SprintTime
	if Controlled:
		$Camera3D.current = true
		cameraStartUpFOV = $Camera3D.fov

func _physics_process(delta):
	if Controlled && !playerIsDead:
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle jump.
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		#Handle Shoot
		if Input.is_action_just_pressed("Shoot"):
			if speed != SPRINTSPEED:  # cannot shoot while sprinting
				shoot()
			
		#Handle Reload
		if Input.is_action_just_pressed("Reload"):
			reload()
		
		#Handle Weapon Change
		if Input.is_action_just_pressed("ChangeWeapon"):
			changeWeapon()
		
		handleSprint(delta)
		
		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("StrafeLeft", "StrafeRight", "Forward", "Backwards")
		if is_on_floor():
			direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		#direction = handleGrapple(direction)	
		
		if Input.is_action_just_pressed("Aim"):
			aim()
			
		if direction and is_on_floor():
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if grapplePosition != Vector3(0,0,0):
				velocity.y = direction.y * speed
		elif !is_on_floor():
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if grapplePosition != Vector3(0,0,0):
				velocity.y = direction.y * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		
		move_and_slide()
		
func _input(event):
	if Controlled && !playerIsDead:
		if event is InputEventMouseMotion:
			rotation.y -= event.relative.x / 1000 * Sensitivity
			
			$Camera3D.rotation.x -= event.relative.y / 1000 * Sensitivity
			
			$Camera3D.rotation.x = clamp($Camera3D.rotation.x, minPitch, maxPitch)  # clamps camera to prevent full flipping
			rotation.y = fmod(rotation.y, PI * 2)

func shoot():
	$Camera3D/GunHolder.Shoot()
	
func reload():
	$Camera3D/GunHolder.Reload()

func changeWeapon():
	$Camera3D/GunHolder.ChangeWeapon()

func handleSprint(delta):
	if Input.is_action_pressed("Sprint"):
		if aiming:
			aim()
		speed = SPRINTSPEED
		SprintTime -= delta
		if SprintTime <= 0:
			speed = SPEED
	else:
		speed = SPEED
		if SprintTime < sprintTimeReset:
			SprintTime += delta * 1  # resets sprint at 1:1 rate
	GameManager.UIManagerInstance.UpdateSprintBar(SprintTime, sprintTimeReset)

#func handleGrapple(direction : Vector3) -> Vector3:
	#if Input.is_action_pressed("Grapple"):
		#
		#if $Camera3D/GrappleRaycast.is_colliding():  # if collides
			#var collider = $Camera3D/GrappleRaycast.get_collider()
			#
			#if collider.is_in_group("Grappleable"):  # verify if object is "Grappleable"
				#grapplePosition = $Camera3D/GrappleRaycast.get_collision_point()  # sets grapple position as collision point
				#
	#if Input.is_action_pressed("Grapple"):  # if grapple button is held
		#direction = (grapplePosition - $Camera3D.global_position).normalized()  # gives direction (?)
	#else:
		#grapplePosition = Vector3(0,0,0)  # return None
	#return direction
	
func TakeDamage(damageAmount : float, player, head : bool = false):
	if head: 
		health -= damageAmount * 2
	else:
		health -= damageAmount
	if health <= 0:
		Die(player)  # player passed in to keep track of who killed who

func Die(player):
	if !playerIsDead:
		PlayerDeath.emit(self, player)
		playerIsDead = true

func RespawnPlayer(spawnPosition : Vector3, spawnRotation : Vector3):
	global_position = spawnPosition
	rotation_degrees = spawnRotation
	playerIsDead = false
	health = 100

func aim():
	$Camera3D/GunHolder.aim(aiming)
	# $Camera3D.fov = cameraStartUpFOV if aiming else 80
	if aiming:
		$Camera3D.fov = cameraStartUpFOV  # starting fov
	else:
		$Camera3D.fov = 50  #zoom for ADS
	aiming = !aiming



