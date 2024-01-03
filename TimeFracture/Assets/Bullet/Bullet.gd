extends Area3D

@export var SPEED : float = 1
@export var DamangeAmount : float = 20
var timeToLive : float = 10
var playerWhoShot

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position + -global_transform.basis.z * SPEED  # movement of bullet
	position.y = position.y + gravity * delta  # gravity on bullet
	timeToLive -= delta
	if timeToLive <= 0:
			queue_free()
	pass

func SetUpBullet(player):
	playerWhoShot = player

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Hit Player.")
		body.TakeDamage(DamangeAmount, playerWhoShot)
	pass # Replace with function body.
