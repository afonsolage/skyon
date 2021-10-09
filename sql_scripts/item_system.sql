CREATE TABLE item_instance(
	id bigint primary key generated always as identity,
	resource_uuid text not null,
	tier smallint not null,
	quality smallint not null,
	required_proficiency smallint not null,
	stack_count smallint not null,
	consumable_action_effect_list jsonb null,
	equipment_max_durability smallint null,
	equipment_durability smallint null,
	equipment_skills jsonb null,
	equipment_attributes jsonb null
)