extends Node2D

const epsilon: = 1e-1

var draw_rel_pos: = Vector2(0.5, 0.5)
var lifetime: = 0.0
var curr_radius: = 0.0
# the values taken by the curve are assumed to be between 0 and 1
export var duration: = 5.0
export var radius_control_points: = PoolVector2Array()
export(float, 1, 100) var scaler: = 50.0

var initialized: = false


func equalsMinusZero(x: float) -> bool:
	return -epsilon <= x and x < 0

func linear_interpolate(A: Vector2, B: Vector2, t: float) -> Vector2:
	return (1-t)*A + t*B

func quadratic(t: float) -> float:
	# quadradic radius function
	var duration: float = 2.5  # seconds
	var max_radius: float = 25  # pixels
	
	var r = max_radius*(1 - pow(2*t/duration - 1, 2)) 
	return r

func bezierCurve(t: float) -> Vector2:
	# uses the control points from radius_control_points
	var mid_points: PoolVector2Array = radius_control_points
	var n: = mid_points.size() - 1
	while n > 0:
		for i in range(n):
			var A = mid_points[i]
			var B = mid_points[i+1]
			mid_points[i] = linear_interpolate(A, B, t)
		n -= 1
	return mid_points[0]

func bezierFunc(x: float) -> float:
	var tMin: = 0.0
	var tMax: = 1.0
	var tMid: = 0.5
	var tolerance: = 1e-2
	var found: Vector2 = bezierCurve(tMid)
	while not(found.x <= x and x <= found.x + tolerance):
		if found.x < x: tMin = tMid
		else: tMax = tMid
		tMid = (tMin + tMax)/2
		found = bezierCurve(tMid)
	return found.y

func initialize(
	draw_rel_pos: = self.draw_rel_pos,
	radius_control_points: = self.radius_control_points,
	scaler: float = self.scaler):
	
	self.draw_rel_pos = draw_rel_pos
	self.radius_control_points = radius_control_points
	self.scaler = scaler
	initialized = true
	return self

func radius(time: float) -> float:
	return scaler*bezierFunc(time)


func _enter_tree():
	if not initialized:
		initialize()

func _ready():
	set_physics_process(false)
	yield(get_tree().create_timer(2.0), "timeout")
	set_physics_process(true)

func _draw():
	var abs_pos: Vector2 = System.toAbsolute(draw_rel_pos)
	draw_circle(abs_pos, curr_radius, Color.white)

func _physics_process(delta):
	lifetime += delta
	curr_radius = radius(lifetime)
	print(lifetime)
	
	if curr_radius < 0:
		call_deferred("queue_free")
		set_physics_process(false)
	
	update()
