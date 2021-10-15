ALTER TABLE item_instance ADD COLUMN inventory_id bigint NOT NULL;
ALTER TABLE item_instance ADD COLUMN inventory_slot smallint NOT NULL;

CREATE TABLE inventory(
  id bigint primary key generated always as identity,
  owner_id bigint not null,
  owner_type smallint not null,
  slot_count smallint not null default 0
)