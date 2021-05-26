extends RigidBody


# Weapon parameters that will be transferred if this weapon is picked
export var weapon_name = "Weapon"
export var ammo_in_mag = 5
export var extra_ammo = 10
onready var mag_size = ammo_in_mag


func _ready():
	connect("sleeping_state_changed", self, "on_sleeping")



func get_weapon_pickup_data():
	return{
		"Name" : weapon_name,
		"Ammo" : ammo_in_mag,
		"ExtraAmmo" : extra_ammo,
		"MagSize" : mag_size
	}



# When the rigidbody goes to sleeping state after being idle for sometime, it will be made static
func on_sleeping():
	mode = MODE_STATIC
