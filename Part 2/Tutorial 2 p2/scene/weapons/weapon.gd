extends Spatial
class_name Weapon

# References
var weapon_manager = null
var player = null
var animation_player

# Weapon States
var is_equipped = false
var is_firing = false
var is_reloading = false

# Weapon Parameters
export var weapon_name = "Weapon"

# Optional
export var equip_speed = 1.0
export var unequip_speed = 1.0



# Equip/Unequip Cycle
func equip():
	animation_player.play("Equip", -1.0, equip_speed)
	#update_ammo()

func unequip():
	animation_player.play("Unequip", -1.0, unequip_speed)

func is_equip_finished():
	if is_equipped:
		return true
	else:
		return false

func is_unequip_finished():
	if is_equipped:
		return false
	else:
		return true



# Show/Hide Weapon
func show_weapon():
	visible = true

func hide_weapon():
	visible = false



# Animation Finished
func on_animation_finish(anim_name):
	match anim_name:
		"Unequip":
			is_equipped = false
		"Equip":
			is_equipped = true



# Update Ammo
func update_ammo(action = "Refresh"):
	
	var weapon_data = {
		"Name" : weapon_name
	}
	
	weapon_manager.update_hud(weapon_data)
