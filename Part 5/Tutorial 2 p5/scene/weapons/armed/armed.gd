extends Weapon
class_name Armed

# Rigidbody Version
export(PackedScene) var weapon_pickup

# References
var animation_player

# Weapon States
var is_firing = false
var is_reloading = false

# Weapon Parameters
export var ammo_in_mag = 15
export var extra_ammo = 30
onready var mag_size = ammo_in_mag

export var damage = 10
export var fire_rate = 1.0

# The offset of the weapon from the camera
export var equip_pos = Vector3.ZERO

# Effects
export(PackedScene) var impact_effect
export(NodePath) var muzzle_flash_path
onready var muzzle_flash = get_node(muzzle_flash_path)

# Optional
export var equip_speed = 1.0
export var unequip_speed = 1.0
export var reload_speed = 1.0

# Sway
var sway_pivot = null

# ADS
export var ads_pos = Vector3.ZERO
var ads_speed = 10
var is_ads = false



func _ready():
	set_as_toplevel(true)
	call_deferred("create_sway_pivot")



# Fire Cycle
func fire():
	if not is_reloading:
		if ammo_in_mag > 0:
			if not is_firing:
				is_firing = true
				animation_player.get_animation("Fire").loop = true
				animation_player.play("Fire", -1.0, fire_rate)
			
			return
		
		elif is_firing:
			fire_stop()

func fire_stop():
	is_firing = false
	animation_player.get_animation("Fire").loop = false


func fire_bullet():    # Will be called from the animation track
	muzzle_flash.emitting = true
	update_ammo("consume")
	
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var impact = Global.instantiate_node(impact_effect, ray.get_collision_point())
		impact.emitting = true




# Reload
func reload():
	if ammo_in_mag < mag_size and extra_ammo > 0:
		is_firing = false
		
		animation_player.play("Reload", -1.0, reload_speed)
		is_reloading = true





# Equip/Unequip Cycle
func equip():
	animation_player.play("Equip", -1.0, equip_speed)
	is_reloading = false

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
		"Reload":
			is_reloading = false
			update_ammo("reload")



# Update Ammo
func update_ammo(action = "Refresh", additional_ammo = 0):
	
	match action:
		"consume":
			ammo_in_mag -= 1
		
		"reload":
			var ammo_needed = mag_size - ammo_in_mag
			
			if extra_ammo > ammo_needed:
				ammo_in_mag = mag_size
				extra_ammo -= ammo_needed
			else:
				ammo_in_mag += extra_ammo
				extra_ammo = 0
		
		"add":
			extra_ammo += additional_ammo
	
	
	var weapon_data = {
		"Name" : weapon_name,
		"Image" : weapon_image,
		"Ammo" : str(ammo_in_mag),
		"ExtraAmmo" : str(extra_ammo)
	}
	
	weapon_manager.update_hud(weapon_data)


# Drops weapon on the ground, by instancing weapon_pickup, and removing itself from the tree
func drop_weapon():
	var pickup = Global.instantiate_node(weapon_pickup, global_transform.origin - player.global_transform.basis.z.normalized())
	pickup.ammo_in_mag = ammo_in_mag
	pickup.extra_ammo = extra_ammo
	pickup.mag_size = mag_size
	
	queue_free()



# Creates the pivot node, which helps in performing weapon sway
func create_sway_pivot():
	sway_pivot = Spatial.new()
	get_parent().add_child(sway_pivot)
	sway_pivot.transform.origin = equip_pos
	sway_pivot.name = weapon_name + "_Sway"


# Performs Weapon Sway, by slerping rotation of the weapon towards the pivot node
func sway(delta):
	global_transform.origin = sway_pivot.global_transform.origin
	
	var self_quat = global_transform.basis.get_rotation_quat()
	var pivot_quat = sway_pivot.global_transform.basis.get_rotation_quat()
	
	var new_quat = Quat()
	
	if is_ads == false:
		new_quat = self_quat.slerp(pivot_quat, 25 * delta)
	else:
		new_quat = pivot_quat
	
	global_transform.basis = Basis(new_quat)



# ADS by interpolating/lerping Sway Pivot and Camera's FOV towards a certain value
func aim_down_sights(value, delta):
	is_ads = value
	
	if is_ads == false and player.camera.fov == 70:
		return
	
	if is_ads:
		sway_pivot.transform.origin = sway_pivot.transform.origin.linear_interpolate(ads_pos, ads_speed * delta)
		player.camera.fov = lerp(player.camera.fov, 50, ads_speed * delta)
	else:
		sway_pivot.transform.origin = sway_pivot.transform.origin.linear_interpolate(equip_pos, ads_speed * delta)
		player.camera.fov = lerp(player.camera.fov, 70, ads_speed * delta)



# When this node gets deleted
func _exit_tree():
	sway_pivot.queue_free()
