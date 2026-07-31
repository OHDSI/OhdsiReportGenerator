SELECT * 
FROM @schema.@c_table_prefixRECHALLENGE_FAIL_CASE_SERIES 
WHERE @column_name = @characterization_target_id
AND OUTCOME_COHORT_DEFINITION_ID = @outcome_id
AND DATABASE_ID = '@database_id'
{@use_dechallenge_stop_interval}?{AND DECHALLENGE_STOP_INTERVAL = @dechallenge_stop_interval}
{@use_dechallenge_evaluation_window}?{AND DECHALLENGE_EVALUATION_WINDOW = @dechallenge_evaluation_window};