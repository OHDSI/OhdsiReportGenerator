select distinct
        outcome_cohort_id as cohort_definition_id,
        risk_window_start,
        risk_window_end,
        start_anchor,
        end_anchor,
        outcome_washout_days
  
        from @schema.@c_table_prefixcohort_counts
      where outcome_cohort_id is not NULL 
      and outcome_cohort_id != 0
      {@use_target}?{and target_cohort_id in (@target_ids)}
      
      ;