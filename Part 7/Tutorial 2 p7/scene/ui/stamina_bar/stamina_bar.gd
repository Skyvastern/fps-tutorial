extends TextureProgress

export(float) var increase_speed = 2
export(float) var decrease_speed = 2


func increase():
	
	$Decrease.stop_all()
	
	if $Increase.is_active() == false:
		var time = (100 - value) / increase_speed
		
		$Increase.interpolate_property(self, "value", value, 100.0, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Increase.start()


func decrease():
	
	$Increase.stop_all()
	
	if $Decrease.is_active() == false:
		var time = value / decrease_speed
		
		$Decrease.interpolate_property(self, "value", value, 0.0, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Decrease.start()
