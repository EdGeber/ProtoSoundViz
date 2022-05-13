extends Node2D

const epsilon: = 1e-1

var index = 1

var lifetime: = 0.0
var sound_intensity: float
var sound_pitch: float
var radius: float
var base_color: Color
var color: Color 
var rel_pos: Vector2
var timestamp: float
var duration: float
var strength: float  # 0 to 1
# the values taken by the curve are assumed to be between 0 and 1
var intensity_control_points: PoolVector2Array
var pitch_control_points: PoolVector2Array
var radius_scaler: = 50.0

var intensBezier: Bezier
var pitchBezier: Bezier

var initialized: = false

func quadratic(t: float) -> float:
	# quadradic radius function
	var duration: float = 2.5  # seconds
	var max_radius: float = 25  # pixels
	
	var r = max_radius*(1 - pow(2*t/duration - 1, 2)) 
	return r

func equalsMinusZero(x: float) -> bool:
	return -epsilon <= x and x < 0

# Olha no dicionário de cor, e seta a cor do circulo
func setYColor(base_color: Color, rel_height: float):
	self.base_color = base_color
	rel_pos.y  = rel_height

func initialize(
	intensity_control_points: PoolVector2Array,
	pitch_control_points: PoolVector2Array,
	base_color: Color,
	rel_height: float,
	timestamp: float,
	radius_scaler: float = self.radius_scaler, 
	duration: float = self.duration,
	strength: float = self.strength):
	
	self.intensBezier = Bezier.new(intensity_control_points)
	self.pitchBezier = Bezier.new(pitch_control_points)
	self.radius_scaler = radius_scaler
	self.setYColor(base_color, rel_height)
	self.timestamp = timestamp
	self.duration = duration
	self.strength = strength 

	initialized = true
	return self

func updateLifetime(delta: float):
	lifetime += delta
	lifetime = min(duration, lifetime)

func updatesound_intensity():
	var i: = intensBezier.function(lifetime/duration, index)*strength
	sound_intensity = max(i, 0.0)

func updatesound_pitch():
	var i: = pitchBezier.function(lifetime/duration, index)
	if equalsMinusZero(i): i = 0
	sound_pitch = i

func updateRadius():
	radius = radius_scaler*sound_intensity

func updateColor():
	color = base_color*sound_pitch*0.1
	color.a = 1 #sound_intensity

func updateRelativePosition():
	rel_pos.x = sound_pitch

func getAbsolutePosition() -> Vector2:
	return System.toAbsolute(rel_pos)

func _ready():
	if not initialized:
		push_error("Uninitilized photism")
		assert(false)
	set_physics_process(false)
	yield(get_tree().create_timer(timestamp), "timeout")
	set_physics_process(true)

func _draw():
	var abs_pos: = getAbsolutePosition()
	draw_circle(abs_pos, radius, color)

func _physics_process(delta):
	index += 1
	
	if lifetime >= duration:
		call_deferred("queue_free")
		set_physics_process(false)
		return

	updatesound_intensity()
	updatesound_pitch()
	updateRadius()
	updateColor()
	updateRelativePosition()
	updateLifetime(delta)
	update()
	
