CREATE TABLE atlas_app.QOLARI_TAG_trigger ();

ALTER TABLE atlas_app.QOLARI_TAG_trigger ADD COLUMN event text NOT NULL;
ALTER TABLE atlas_app.QOLARI_TAG_trigger ADD COLUMN tag_name text NOT NULL;
ALTER TABLE atlas_app.QOLARI_TAG_trigger ADD COLUMN created_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_app.QOLARI_TAG_trigger ADD COLUMN updated_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_app.QOLARI_TAG_trigger ADD PRIMARY KEY ( event, tag_name);
