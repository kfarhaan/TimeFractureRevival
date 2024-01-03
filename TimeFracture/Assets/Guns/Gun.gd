extends RigidBody3D
class_name Gun

@export var BulletPackedScene : PackedScene

@export var AmmoPool : int = 40  # ammo in player's mag
var maxAmmoPool : int  # max ammo player can have in mag
@export var CurrentAmmo : int = 10  # total ammo player has
var maxCurrentAmmo : int  # max ammo player can hold
@export var Active = false

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	maxAmmoPool = AmmoPool
	maxCurrentAmmo = CurrentAmmo
	
	pass # Replace with function body.

func SetupGun(player):
	self.player = player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Active:
		GameManager.UIManagerInstance.UpdateAmmoCount(CurrentAmmo, AmmoPool)
	pass
	

func Shoot():
	if CurrentAmmo > 0 && self.Active:
			var bullet : Area3D = BulletPackedScene.instantiate()
			get_tree().root.add_child(bullet)
			bullet.SetUpBullet(player)
			bullet.global_transform = $BulletSpawner.global_transform
			CurrentAmmo -= 1
			print(CurrentAmmo)
			
			$AnimationPlayer.play("Shoot")

func Reload():
	if maxCurrentAmmo > AmmoPool:  #  if we have less ammo in pool than possible in gun
		CurrentAmmo = AmmoPool  #  set ammo in gun to ammo pool
		AmmoPool = 0  # 0 out ammo pool
	else:
		CurrentAmmo = maxCurrentAmmo
		AmmoPool -= maxCurrentAmmo  # otherwise subtract ammo from current ammo
