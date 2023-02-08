extends KinematicBody

class_name Player

const ACCEL = 2.0
const GRAVITY = -24.8
const MAX_SPEED = 10
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40

var vel: Vector3 = Vector3()
var dir: Vector3 = Vector3()

# camera
var minLookAngle = -90
var maxLookAngle = 90
var lookSensitivity = 10.0
var mouseDelta: Vector2 = Vector2()

onready var camera: Camera = get_node("Camera")


func _physics_process(delta : float) -> void:
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_key_pressed(KEY_Z):
		input_movement_vector.y += 1
	if Input.is_key_pressed(KEY_S):
		input_movement_vector.y -= 1
	if Input.is_key_pressed(KEY_Q):
		input_movement_vector.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_movement_vector.x = 1

	input_movement_vector = input_movement_vector.normalized()

	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	
	dir.y = 0
	dir = dir.normalized()

	#vel.y += delta*GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z
	
	vel = move_and_slide(vel,Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	
func _process(delta):
	camera.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	
	camera.rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	
	mouseDelta = Vector2()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
