extends Control

class_name UIManager

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.UIManagerInstance = self
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func UpdateAmmoCount(currentAmmoCount : int, currentAmmoPool : int):
	$AmmoPanel/AmmoCount.text = "[center][b]" + str(currentAmmoCount) + " / " + str(currentAmmoPool)

func UpdateSprintBar(sprintTime : float, sprintTimeReset : float):
	$SprintBar.max_value = sprintTimeReset
	$SprintBar.value = sprintTime

