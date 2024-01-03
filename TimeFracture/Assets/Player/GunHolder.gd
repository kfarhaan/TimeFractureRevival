extends Marker3D

var Weapons : Array
var WeaponIndex : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	Weapons = getWeapons()
	get_parent().get_parent()
	ChangeWeapon()  # Godot starts player of with weapon on start
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func Shoot():
	Weapons[WeaponIndex].Shoot()
	
func Reload():
	Weapons[WeaponIndex].Reload()
	
func getWeapons():
	var gunChildren = []
	for i in range(get_child_count()):
		var child = get_child(i)
		if child.is_class("RigidBody3D"):
			gunChildren.append(child)
			child.SetupGun(get_parent().get_parent())
	return gunChildren
	
func ChangeWeapon():
	if Weapons.size() <= 1:
		return Weapons[WeaponIndex]
	
	Weapons[WeaponIndex].hide()
	Weapons[WeaponIndex].Active = false
	if WeaponIndex == 1:  # allowable number of weapons
		WeaponIndex = 0
	else:
		WeaponIndex += 1
	
	Weapons[WeaponIndex].show()
	Weapons[WeaponIndex].Active = true
	
	return Weapons[WeaponIndex]

func aim(aiming):
	if !aiming:
		$AnimationPlayer.play("Aim")
	else:
		$AnimationPlayer.play_backwards("Aim")
