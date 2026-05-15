DROP TABLE IF EXISTS @schema.@c_table_prefixtime_to_event_targets;
SELECT distinct target_cohort_definition_id 
INTO @schema.@c_table_prefixtime_to_event_targets
FROM @schema.@c_table_prefixtime_to_event;

CREATE INDEX IF NOT EXISTS c_ttet_tid 
ON @schema.@c_table_prefixtime_to_event_targets(target_cohort_definition_id);
ANALYZE @schema.@c_table_prefixtime_to_event_targets;
