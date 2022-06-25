extends Spatial

signal on_fire
signal on_reloaded

enum State {
	IDLE,
	RELOAD
}
var state = State.IDLE

const AMMO_CLIP_MAX = 71
const AMMO_RESERVE_MAX = 180
var ammo_clip = AMMO_CLIP_MAX
var ammo_reserve = AMMO_RESERVE_MAX

const FIRE_DELAY: float = .12
var fire_timer: float = FIRE_DELAY

onready var anim_player: AnimationPlayer = $AnimationPlayer
var casing_particle = preload("res://casing_particle/casing_particle.tscn")
onready var casing_particle_spawn: Spatial = $Armature/Skeleton/GunAttachment/CasingParticleSpawn

func _process(delta):
	fire_timer = max(0, fire_timer - delta)

	match state:
		State.IDLE:
			if Input.is_action_pressed("shoot") and fire_timer <= 0 and ammo_clip > 0:
				anim_player.play("firing")
				ammo_clip -= 1
				emit_signal("on_fire")
				
				var particle = casing_particle.instance()
				get_tree().root.add_child(particle)
				particle.global_transform = casing_particle_spawn.global_transform
				var basis = global_transform.basis.z
				basis.y = 1
				particle.apply_central_impulse(Vector3(2, 4, 0)*basis)
				
				fire_timer = FIRE_DELAY
			elif ammo_clip < AMMO_CLIP_MAX and ammo_reserve > 0 and Input.is_action_just_pressed("reload"):
				anim_player.play("reload")
				state = State.RELOAD
			elif !anim_player.is_playing():
					anim_player.play("default-state")

		State.RELOAD:
			if !anim_player.is_playing():
				var ammo_needed = AMMO_CLIP_MAX - ammo_clip
				ammo_clip += min(ammo_needed, ammo_reserve)
				ammo_reserve = max(0, ammo_reserve - ammo_needed)

				emit_signal("on_reloaded")
				state = State.IDLE
