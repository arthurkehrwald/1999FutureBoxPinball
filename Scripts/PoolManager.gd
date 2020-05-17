extends Spatial

enum {
	MONEY_TEXT,
	WIREFRAME_FLASH,
	PINBALL_APPEAR,
	PROJECTILE_LASERED,
	PROJECTILE_DISAPPEAR,
	ENEMY_EXPLOSION,
	BUMPER_HIT,
	SLINGSHOT_HIT,
	DAMAGEABLE_HIT,
	MULTIBALL_LOCK,
	MULTIBALL_SHOT,
	MOON_TRIGGERED,
	STAR_GATE_ENTER,
	STAR_GATE_EXIT,
	BOMB_EXPLOSION
}

const Pool = preload("res://Scripts/Pool.gd")

var effect_info = {
	MONEY_TEXT: Pool.new(preload("res://Scenes/MoneyTextFX.tscn"), 50),
	WIREFRAME_FLASH: Pool.new(preload("res://Scenes/WireframeFlashFX.tscn"), 10),
	PINBALL_APPEAR: Pool.new(preload("res://Scenes/PinballAppearFX.tscn"), 1),
	PROJECTILE_LASERED: Pool.new(preload("res://Scenes/ProjectileLaseredFX.tscn"), 5),
	PROJECTILE_DISAPPEAR: Pool.new(preload("res://Scenes/ProjectileDisappearFX.tscn"), 7),
	ENEMY_EXPLOSION: Pool.new(preload("res://Scenes/EnemyExplosionFX.tscn"), 7),
	BUMPER_HIT: Pool.new(preload("res://Scenes/BumperHitFX.tscn"), 50),
	SLINGSHOT_HIT: Pool.new(preload("res://Scenes/SlingshotHitFX.tscn"), 5),
	DAMAGEABLE_HIT: Pool.new(preload("res://Scenes/DamageableHitFX.tscn"), 10),
	MULTIBALL_LOCK: Pool.new(preload("res://Scenes/MultiballLockFX.tscn"), 3),
	MULTIBALL_SHOT: Pool.new(preload("res://Scenes/MultiballShotFX.tscn"), 1),
	MOON_TRIGGERED: Pool.new(preload("res://Scenes/MoonTriggeredFX.tscn"), 1),
	STAR_GATE_ENTER: Pool.new(preload("res://Scenes/StarGateEnterFX.tscn"), 3),
	STAR_GATE_EXIT: Pool.new(preload("res://Scenes/StarGateExitFX.tscn"), 3),
	BOMB_EXPLOSION: Pool.new(preload("res://Scenes/BombExplosionFX.tscn"), 5)
}


func request(type, pos):
	effect_info[type].deploy(pos)
