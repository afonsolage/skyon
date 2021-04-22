extends Node

enum Direction {
	RIGHT = 0,
	UP = 1,
	LEFT = 2,
	DOWN = 3,
}

enum ItemCategory {
	MATERIAL,
	USABLE,
	EQUIPMENT,
	SPECIAL,
}

enum MaterialCategory {
	WOOD,
	STONE,
	IRON,
	MEAT,
}

enum UsableCategory {
	POTION,
	LOOTBOX,
	SCROLL,
}

enum EquipmentCategory {
	HELM,
	ARMOR,
	PANTS,
	GLOVES,
	BOOTS,
	ONE_HAND,
	TWO_HAND,
	OFF_HAND,
}

enum SpecialCategory {
	COIN,
	QUEST,
}

enum EquipmentSlot {
	HEAD,
	TORSO,
	LEGS,
	ARMS,
	FOOT,
	LEFT_HAND,
	RIGHT_HAND,
	LEFT_RING,
	RIGHT_RING,
	NECKLACE,
}

enum ItemActionID {
	HEAL,
	DROP,
}

enum ProficiencyID {
	WOOD,
	STONE,
	IRON,
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
}

const DIRS = [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]
