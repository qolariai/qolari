CREATE TABLE atlas_app.QOLARI_TAG ();

ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN category text NOT NULL;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN description text ;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN chakra text ;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN event text ;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN tag_type text NOT NULL;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN validity text ;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN name text NOT NULL;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN range_end double precision ;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN range_start double precision ;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN tags text[] ;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN rule text NOT NULL;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN created_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN updated_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_app.QOLARI_TAG ADD PRIMARY KEY ( name);


------- SQL updates -------

ALTER TABLE atlas_app.QOLARI_TAG ALTER COLUMN validity TYPE integer USING validity::integer;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN rule_engine json ;
ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN llm_context text ;

--- Now DSL don't allow dropping tables instead we will drop not null constraint if any .Please be careful while running ---
ALTER TABLE atlas_app.QOLARI_TAG ALTER COLUMN rule DROP NOT NULL;
--- Drop section ends. Please check before running ---


------- SQL updates -------

ALTER TABLE atlas_app.QOLARI_TAG ADD COLUMN action_engine json ;


------- SQL updates -------

ALTER TABLE atlas_app.QOLARI_TAG ALTER COLUMN validity TYPE integer;


------- SQL updates -------




------- SQL updates -------




------- SQL updates -------

