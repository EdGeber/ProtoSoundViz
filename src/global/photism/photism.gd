extends Node2D

const epsilon: = 1e-1

var i = 1

var testing: = false
var colorPallet:= {
	"0": [Color(255,0,0), 0.5], #Vermelho
	"1": [Color(0, 255, 0), 0.1], #Verde
	"2": [Color(0, 0, 255), 0.2], #Azul 
	"3": [Color(255, 255, 0), 0.3], #Amarelo 
	"4": [Color(200, 162, 200), 0.4] #Lilas
}
var lifetime: = 0.0
var soundIntensity: float = 0
var soundPitch: float
var soundTimbre: String = "0"
var radius: float
var baseColor: Color
var color: Color 
var rel_pos: Vector2
var timestamp: int = 0
# the values taken by the curve are assumed to be between 0 and 1
export(PoolVector2Array) var intensity_control_points: = PoolVector2Array()
export(PoolVector2Array) var pitch_control_points: = PoolVector2Array()
export(float, 1, 100) var radiusScaler: = 50.0

var maxLifetime: float

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
func setYColor(timbre: String):
	baseColor = colorPallet[timbre][0]
	rel_pos.y  = colorPallet[timbre][1]

func initialize(
	intensity_control_points: = self.intensity_control_points,
	pitch_control_points: = self.pitch_control_points,
	soundTimbre: String = self.soundTimbre,
	radiusScaler: float = self.radiusScaler,
	timestamp: int = self.timestamp):
	
	self.intensBezier = Bezier.new(intensity_control_points)
	self.pitchBezier = Bezier.new(pitch_control_points)
	self.radiusScaler = radiusScaler
	self.setYColor(soundTimbre)
	self.timestamp = timestamp

	var num_intens_points: int = intensity_control_points.size() - 1
	var max_intens_x: float = intensity_control_points[num_intens_points].x
	
	var num_pitch_points: int = pitch_control_points.size() - 1
	var max_pitch_x: float =  intensity_control_points[num_pitch_points].x
	self.maxLifetime = min(max_intens_x, max_pitch_x)
	
	initialized = true
	return self

func updateLifetime(delta: float):
	lifetime += delta
	lifetime = min(maxLifetime, lifetime)

func updateSoundIntensity():
	var i: = intensBezier.function(lifetime)
	if equalsMinusZero(i): i = 0
	soundIntensity = i

func updateSoundPitch():
	var i: = pitchBezier.function(lifetime)
	if equalsMinusZero(i): i = 0
	soundPitch = i

func updateRadius():
	radius = radiusScaler*soundIntensity

func updateColor():
	color = baseColor*soundPitch*0.01
	color.a = soundIntensity

func updateRelativePosition():
	rel_pos.x = soundPitch

func getAbsolutePosition() -> Vector2:
	return System.toAbsolute(rel_pos)

func _ready():
	if not initialized:
		testing = true
		initialize()
	set_physics_process(false)
	yield(get_tree().create_timer(timestamp), "timeout")
	set_physics_process(true)

func _draw():
	var abs_pos: = getAbsolutePosition()
	draw_circle(abs_pos, radius, color)

func _physics_process(delta):
	if soundIntensity < 0:
		call_deferred("queue_free")
		set_physics_process(false)
		return

	updateSoundIntensity()
	updateSoundPitch()
	updateRadius()
	updateColor()
	updateRelativePosition()
	updateLifetime(delta)
	update()
	
