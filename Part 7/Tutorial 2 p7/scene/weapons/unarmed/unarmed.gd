extends Weapon


var ads_speed = 10
var is_ads = false


func aim_down_sights(value, delta):
	is_ads = value
	
	if is_ads == false and player.camera.fov == 70:
		return
	
	if is_ads:
		player.camera.fov = lerp(player.camera.fov, 50, ads_speed * delta)
	else:
		player.camera.fov = lerp(player.camera.fov, 70, ads_speed * delta)


func fire():
	pass

func fire_stop():
	pass

func reload():
	pass
