class_name UUID
extends Object

const MOD = 256

static func v4() -> String:
	randomize()
	var b = [
		randi() % MOD, randi() % MOD, randi() % MOD, randi() % MOD,
		randi() % MOD, randi() % MOD, ((randi() % MOD) & 0x0f) | 0x40, randi() % MOD,
		((randi() % MOD) & 0x3f) | 0x80, randi() % MOD, randi() % MOD, randi() % MOD,
		randi() % MOD, randi() % MOD, randi() % MOD, randi() % MOD,
	]

	return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
		b[0], b[1], b[2], b[3],
		b[4], b[5],
		b[6], b[7],
		b[8], b[9],
		b[10], b[11], b[12], b[13], b[14], b[15]
	]
