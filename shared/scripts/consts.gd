extends Node

enum ItemCategory {
	MATERIAL,
	USABLE,
	EQUIPMENT,
	SPECIAL,
}

enum MaterialCategory {
	WOOD,
	STONE,
	ORE,
	HIDE,
	FIBER,
	PLANK,
	BRICK,
	METAL,
	LEATHER,
	CLOTH,
}

enum UsableCategory {
	POTION,
	LOOTBOX,
	FOOD,
}

enum EquipmentCategory {
	LIGHT,
	MEDIUM,
	HEAVY,
	ONE_H_SWORD,
	SHIELD,
	TWO_H_SWORD,
	BOW,
	STAFF,
}

enum SpecialCategory {
	COIN_BAG,
}

enum EquipmentSlot {
	HEAD,
	CHEST,
	LEGS,
	ARM,
	SHOES,
	LEFT_HAND,
	RIGHT_HAND,
}

enum ItemActionID {
	HEAL,
	DROP,
}

enum ProficiencyID {
	NONE,
	WOOD,
	STONE,
	ORE,
	HIDE,
	FIBER,
	PLANK,
	BRICK,
	METAL,
	LEATHER,
	CLOTH,
	LIGHT_HELM,
	LIGHT_ARMOR,
	LIGHT_PANTS,
	LIGHT_GLOVES,
	LIGHT_BOOTS,
	MEDIUM_HELM,
	MEDIUM_ARMOR,
	MEDIUM_PANTS,
	MEDIUM_GLOVES,
	MEDIUM_BOOTS,
	HEAVY_HELM,
	HEAVY_ARMOR,
	HEAVY_PANTS,
	HEAVY_GLOVES,
	HEAVY_BOOTS,
	ONE_H_SWORD,
	SHIELD,
	TWO_H_SWORD,
	BOW,
	STAFF,
}

enum SkillID {
	SLASH,
	DOUBLE_SLASH,
	FIRE_BALL,
	TRIPLE_SHOT,
}

enum AttributeID {
	HEALTH,
	MANA,
	STAMINA,
	PHYSICAL_ATTACK,
	MAGICAL_ATTACK,
	PHYSICAL_DEFENSE,
	MAGICAL_DEFENSE,
	ATTACK_SPEED,
	CAST_SPEED,
	MOVE_SPEED,
	ATTACK_RANGE,
}

const DIRS = [
	Vector2.RIGHT,
	Vector2.UP,
	Vector2.LEFT,
	Vector2.DOWN,
]

enum Direction {
	RIGHT = 0,
	UP = 1,
	LEFT = 2,
	DOWN = 3,
}
