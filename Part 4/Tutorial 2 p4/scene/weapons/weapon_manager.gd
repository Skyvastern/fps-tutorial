extends Spatial


# All weapons in the game
var all_weapons = {}

# Carrying Weapons
var weapons = {}

#HUD
var hud

var current_weapon # Reference to the current weapon equipped
var current_weapon_slot = "Empty" # The current weapon slot

var changing_weapon = false
var unequipped_weapon = false

var weapon_index = 0 # For switching weapons through mouse wheel


func _ready():
	
	hud = owner.get_node("HUD")
	get_parent().get_node("Camera/RayCast").add_exception(owner) # Adds exception of player to the shooting raycast
	
	all_weapons = {
		"Unarmed" : preload("res://scene/weapons/unarmed/unarmed.tscn"),
		"Pistol_A" : preload("res://scene/weapons/armed/pistol/pistol_a/pistol_a.tscn"),
		"Pistol_B" : preload("res://scene/weapons/armed/pistol/pistol_b/pistol_b.tscn"),
		"Rifle_A" : preload("res://scene/weapons/armed/rifle/rifle_a/rifle_a.tscn"),
		"Rifle_B" : preload("res://scene/weapons/armed/rifle/rifle_b/rifle_b.tscn")
	}
	
	weapons = {
		"Empty" : $Unarmed,
		"Primary" : $Pistol_B,
		"Secondary" : $Rifle_B
	}
	
	# Initialize references for each weapons
	for w in weapons:
		if is_instance_valid(weapons[w]):
			weapon_setup(weapons[w])
	
	# Set current weapon to unarmed
	current_weapon = weapons["Empty"]
	change_weapon("Empty")
	
	# Disable process
	set_process(false)


# Initializes Weapon's values
func weapon_setup(w):
	w.weapon_manager = self
	w.player = owner
	w.ray = get_parent().get_node("Camera/RayCast")
	w.visible = false


# Process will be called when changing weapons
func _process(delta):
	
	if unequipped_weapon == false:
		if current_weapon.is_unequip_finished() == false:
			return
		
		unequipped_weapon = true
		
		current_weapon = weapons[current_weapon_slot]
		current_weapon.equip()
	
	if current_weapon.is_equip_finished() == false:
		return
	
	changing_weapon = false
	set_process(false)



func change_weapon(new_weapon_slot):
	
	if new_weapon_slot == current_weapon_slot:
		current_weapon.update_ammo() # Refresh
		return
	
	if is_instance_valid(weapons[new_weapon_slot]) == false:
		return
	
	current_weapon_slot = new_weapon_slot
	changing_weapon = true
	
	weapons[current_weapon_slot].update_ammo() # Updates the weapon data on UI, as soon as we change a weapon
	update_weapon_index()
	
	# Change Weapons
	if is_instance_valid(current_weapon):
		unequipped_weapon = false
		current_weapon.unequip()
	
	set_process(true)




# Scroll weapon change
func update_weapon_index():
	match current_weapon_slot:
		"Empty":
			weapon_index = 0
		"Primary":
			weapon_index = 1
		"Secondary":
			weapon_index = 2

func next_weapon():
	weapon_index += 1
	
	if weapon_index >= weapons.size():
		weapon_index = 0
	
	change_weapon(weapons.keys()[weapon_index])

func previous_weapon():
	weapon_index -= 1
	
	if weapon_index < 0:
		weapon_index = weapons.size() - 1
	
	change_weapon(weapons.keys()[weapon_index])





# Firing and Reloading
func fire():
	if not changing_weapon:
		current_weapon.fire()

func fire_stop():
	current_weapon.fire_stop()

func reload():
	if not changing_weapon:
		current_weapon.reload()


# Ammo Pickup
func add_ammo(amount):
	if is_instance_valid(current_weapon) == false || current_weapon.name == "Unarmed":
		return false
	
	current_weapon.update_ammo("add", amount)
	return true



# Add weapon to an existing empty slot
func add_weapon(weapon_data):
	
	if not weapon_data["Name"] in all_weapons:
		return
	
	if is_instance_valid(weapons["Primary"]) == false:
		
		# Instance the new weapon
		var weapon = Global.instantiate_node(all_weapons[weapon_data["Name"]], Vector3.ZERO, self)
		
		# Initialize the new weapon references
		weapon_setup(weapon)
		weapon.ammo_in_mag = weapon_data["Ammo"]
		weapon.extra_ammo = weapon_data["ExtraAmmo"]
		weapon.mag_size = weapon_data["MagSize"]
		weapon.transform.origin = weapon.equip_pos
		
		# Update the dictionary and change weapon
		weapons["Primary"] = weapon
		change_weapon("Primary")
		
		return
	
	if is_instance_valid(weapons["Secondary"]) == false:
		
		# Instance the new weapon
		var weapon = Global.instantiate_node(all_weapons[weapon_data["Name"]], Vector3.ZERO, self)
		
		# Initialize the new weapon references
		weapon_setup(weapon)
		weapon.ammo_in_mag = weapon_data["Ammo"]
		weapon.extra_ammo = weapon_data["ExtraAmmo"]
		weapon.mag_size = weapon_data["MagSize"]
		weapon.transform.origin = weapon.equip_pos
		
		# Update the dictionary and change weapon
		weapons["Secondary"] = weapon
		change_weapon("Secondary")
		
		return



# Will be called from player.gd
func drop_weapon():
	if current_weapon_slot != "Empty":
		current_weapon.drop_weapon()
		
		# Need to be set to Unarmed in order call change_weapon() function
		current_weapon_slot = "Empty"
		current_weapon = weapons["Empty"]
		
		# Update HUD
		current_weapon.update_ammo()



# Switch Weapon / Replace Weapon
func switch_weapon(weapon_data):
	
	# Checks whether there's any empty slot available
	# If there is, then we simply add that new weapon to the empty slot
	for i in weapons:
		if is_instance_valid(weapons[i]) == false:
			add_weapon(weapon_data)
			return
	
	
	# If we are unarmed, and pickup a weapon
	# Then the weapon at the primary slot will be dropped and replaced with the new weapon
	if current_weapon.name == "Unarmed":
		weapons["Primary"].drop_weapon()
		yield(get_tree(), "idle_frame")
		add_weapon(weapon_data)
	
	
	# If the weapon to be picked up and the current weapon are same
	# Theb the ammo of the new weapon is added to the currently equipped weapon
	elif current_weapon.weapon_name == weapon_data["Name"]:
		add_ammo(weapon_data["Ammo"] + weapon_data["ExtraAmmo"])
	
	
	# If we already have an equipped weapon, then we drop it
	# And equip the new weapon
	else:
		drop_weapon()
		
		yield(get_tree(), "idle_frame")
		add_weapon(weapon_data)


# Interaction Prompt
func show_interaction_prompt(weapon_name):
	var desc = "Add Ammo" if current_weapon.weapon_name == weapon_name else "Equip"
	hud.show_interaction_prompt(desc)

func hide_interaction_prompt():
	hud.hide_interaction_prompt()


# Searches for weapon pickups, and based on player input executes further tasks (will be called from player.gd)
func process_weapon_pickup():
	var from = global_transform.origin
	var to = global_transform.origin - global_transform.basis.z.normalized() * 2.0
	var space_state = get_world().direct_space_state
	var collision = space_state.intersect_ray(from, to, [owner], 1)
	
	if collision:
		var body = collision["collider"]
		
		if body.has_method("get_weapon_pickup_data"):
			var weapon_data = body.get_weapon_pickup_data()
			
			show_interaction_prompt(weapon_data["Name"])
			
			if Input.is_action_just_pressed("interact"):
				switch_weapon(weapon_data)
				body.queue_free()
		else:
			hide_interaction_prompt()



# Update HUD
func update_hud(weapon_data):
	var weapon_slot = "1"
	
	match current_weapon_slot:
		"Empty":
			weapon_slot = "1"
		"Primary":
			weapon_slot = "2"
		"Secondary":
			weapon_slot = "3"
	
	hud.update_weapon_ui(weapon_data, weapon_slot)


