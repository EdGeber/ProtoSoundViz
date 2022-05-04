extends Node2D

const epsilon: = 1e-1

var rel_pos: = Vector2(0.5, 0.5)
var lifetime: = 0.0
var soundIntensity: = 0.0
var radius: = 0.0
var color: Color = Color.peru
# the values taken by the curve are assumed to be between 0 and 1
export(PoolVector2Array) var intensity_control_points: = PoolVector2Array()
export(float, 1, 100) var scaler: = 50.0

var intensBezier: Bezier

var initialized: = false

func quadratic(t: float) -> float:
	# quadradic radius function
	var duration: float = 2.5  # seconds
	var max_radius: float = 25  # pixels
	
	var r = max_radius*(1 - pow(2*t/duration - 1, 2)) 
	return r

func equalsMinusZero(x: float) -> bool:
	return -epsilon <= x and x < 0

func initialize(
	rel_pos: = self.rel_pos,
	intensity_control_points: = self.intensity_control_points,
	scaler: float = self.scaler):
	
	self.rel_pos = rel_pos
	self.scaler = scaler
	self.intensBezier = Bezier.new(intensity_control_points)
	initialized = true
	return self

func updateLifetime(delta: float):
	lifetime += delta

func updateSoundIntensity():
	var i: = intensBezier.function(lifetime)
	if equalsMinusZero(i): i = 0
	soundIntensity = i

func updateSoundPitch():
	pass

func updateRadius():
	radius = scaler*soundIntensity

func updateColor():
	color.a = soundIntensity

func updateRelativePosition():
	pass

func getAbsolutePosition() -> Vector2:
	return System.toAbsolute(rel_pos)

func _ready():
	if not initialized:
		initialize()
	set_physics_process(false)
	yield(get_tree().create_timer(1.5), "timeout")
	set_physics_process(true)

func _draw():
	var abs_pos: = getAbsolutePosition()
	draw_circle(abs_pos, radius, color)

func _physics_process(delta):
	updateLifetime(delta)
	
	updateSoundIntensity()
	updateSoundPitch()
	
	updateRadius()
	updateColor()
	updateRelativePosition()
	
	if radius < 0:
		call_deferred("queue_free")
		set_physics_process(false)
	else:
		update()
