extends ImmediateGeometry

var points = []
var points2 = []
var lifePoints = []
export var width = 0.5
export var motionDelta = 0.1
export var clear_trail_motion_delta = .5
export var lifespan = 1.0
export var scaleTexture = true
export var startColor = Color(1.0, 1.0, 1.0, 1.0)
export var endColor = Color(1.0, 1.0, 1.0, 0.0)

var oldPos
var fadeCounter

func _ready():
	oldPos = get_global_transform().origin

func _process(delta):
	var dist_traveled = (oldPos - get_global_transform().origin).length()
	
	if dist_traveled > clear_trail_motion_delta:
		lifePoints.clear()
		points.clear()
		points2.clear()
	if  dist_traveled > motionDelta:
		appendPoint()
		oldPos = get_global_transform().origin
	
	var i = 0
	var max_points = points.size()
	while i < max_points:
		lifePoints[i] += delta
		if lifePoints[i] > lifespan:
			removePoint(i)
			i -= 1
			if (i < 0): i = 0
		
		max_points = points.size()
		i += 1
	
	clear()
	
	if points.size() < 2:
		return
	
	begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for j in range(points.size()):
		var t = float(j + 1) / points.size()
		var currColor = startColor.linear_interpolate(endColor, 1 - t)
		set_color(currColor)
		
		if scaleTexture:
			var t0 = motionDelta * j
			var t1 = motionDelta * (j + 1)
			set_uv(Vector2(t0, 0))
			add_vertex(to_local(points[j]))
			set_uv(Vector2(t1, 1))
			add_vertex(to_local(points2[j]))
		else:
			var t0 = j / points.size()
			var t1 = t
			
			set_uv(Vector2(t0, 0))
			add_vertex(to_local(points[j]))
			set_uv(Vector2(t1, 1))
			add_vertex(to_local(points2[j]))
	end()

func appendPoint():
	var widthVec = -(oldPos - get_global_transform().origin).cross(Vector3.UP).normalized() * width
	
	points.append(get_global_transform().origin + widthVec)
	points2.append(get_global_transform().origin - widthVec)
	lifePoints.append(0.0)
	
func removePoint(i):
	points.remove(i)
	points2.remove(i)
	lifePoints.remove(i)
