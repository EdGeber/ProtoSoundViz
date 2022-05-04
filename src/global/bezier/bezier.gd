class_name Bezier

var control_points: PoolVector2Array

var cached_pabs: = PoolVector2Array()  # a 'pabs' is a pair (t, x) of a parametric curve
var cache_size: = 50
var last_closest_pabs_index: = 0  # last left closest point index


func _init(
	control_points: PoolVector2Array,
	cache_size: = self.cache_size):
	
	self.control_points = control_points
	self.cache_size = cache_size
	cachePabs()
	return self

func linear_interpolate(A, B, t: float):
	return (1-t)*A + t*B

func curveAbscissa(t: float) -> float:
	# uses the control points from radius_control_points
	var mid_points: = control_points
	
	var n: = mid_points.size() - 1
	while n > 0:
		for i in range(n):
			var a: float = mid_points[i].x
			var b: float = mid_points[i+1].x
			mid_points[i].x = linear_interpolate(a, b, t)
		n -= 1
	return mid_points[0].x

func curve(t: float) -> Vector2:
	# uses the control points from radius_control_points
	var mid_points: PoolVector2Array = control_points
	var n: = mid_points.size() - 1
	while n > 0:
		for i in range(n):
			var A = mid_points[i]
			var B = mid_points[i+1]
			mid_points[i] = linear_interpolate(A, B, t)
		n -= 1
	return mid_points[0]

func cachePabs():
	var t: = 0.0
	var increment: = 1.0/(cache_size-1)
	while t < 1.0:
		cached_pabs.append(Vector2(t, curveAbscissa(t)))
		t += increment
	var final_control_point: = control_points[control_points.size()-1]
	cached_pabs.append(Vector2(1, final_control_point.x))

func findLeftClosestCachedPabsIndex(x: float) -> int:
	var start: = last_closest_pabs_index
	var closest_pabs_index: = start
	var closest_pabs: = cached_pabs[closest_pabs_index]
	
	var curr_pabs: Vector2
	
	var closest_dist: = abs(x - closest_pabs[1])
	var curr_dist: float
	
	# +1 because checking start would be redundant
	# -1 so that the chosen pabs is not the last one
	for i in range(start+1, cache_size-1):
		curr_pabs = cached_pabs[i]
		curr_dist = abs(x - curr_pabs[1])
		if curr_dist > closest_dist: break
		closest_pabs_index = i
		closest_dist = curr_dist
		closest_pabs = curr_pabs
	
	if x < closest_pabs[1]:
		return closest_pabs_index-1
	return closest_pabs_index

func function(x: float) -> float:
	var tolerance: = 1e-4
	var max_iterations = 100
	
	var i: = findLeftClosestCachedPabsIndex(x)
	var tMin: = cached_pabs[i][0]
	var tMax: = cached_pabs[i+1][0]
	var tMid: = (tMin + tMax)/2.0
	var found: Vector2 = curve(tMid)
	while not(found.x - tolerance <= x and x <= found.x + tolerance):
		if found.x < x: tMin = tMid
		else: tMax = tMid
		tMid = (tMin + tMax)/2.0
		found = curve(tMid)
	return found.y
