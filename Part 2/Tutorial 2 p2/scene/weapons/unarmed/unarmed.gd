extends Weapon


func equip():
	update_ammo()

func unequip():
	pass

func is_equip_finished():
	return true

func is_unequip_finished():
	return true



func update_ammo(action = "Refresh"):
	
	var weapon_data = {
		"Name" : weapon_name
	}
	
	weapon_manager.update_hud(weapon_data)
