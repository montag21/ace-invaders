extends KinematicBody2D

signal die
signal penetrate

var speed = 75
var gravity = 800
const JUMP_FORCE = 300
var velocity = Vector2()
var sprite_size = Vector2(64, 64)

onready var counter_node = get_parent().get_node("Fun/StacheGuyCounter")
var destination #set by dropship

func _ready():
	var sprite = $Sprite
	var variation = [0, 64, 128, 192, 256]
	var pick = rand_range(0, 5)
	sprite.region_rect.position = Vector2(variation[pick], 0)
	if position.x > destination:
		sprite.flip_h = true
	add_to_group("STACHE_GUYS")
	$ProjectileTracker.connect("area_entered", self, "_on_projectile_hit")
	

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.x = 0
	
	if position.x < destination - 20:
		velocity.x += speed
	elif position.x > destination + 20:
		velocity.x -= speed
	else:
		var previous_value = int(counter_node.get_text())
		counter_node.set_text(str(previous_value + 1))
		queue_free()
		emit_signal("penetrate")
		
	if randf() > 0.96:
		jump()
#		
	velocity = move_and_slide(velocity, Vector2.UP)

	for body in $FloorTracker.get_overlapping_bodies():
		if body.name == "Land":
			jump()

func jump():
	if is_on_floor():
		velocity.y -= JUMP_FORCE

func _on_projectile_hit(_projectile_area):
	set_physics_process(false)
	queue_free()
	emit_signal("die")
