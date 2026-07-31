SELECT 
      cg.cohort_name as cohort_name,
      outcomes.cohort_definition_id as cohort_definition_id,
      max(outcomes.time_to_event) as time_to_event,
      max(outcomes.dechallenge_rechallenge) as dechal_rechal,
      max(outcomes.risk_factor) as risk_factors,
      max(outcomes.case_series) as case_series
      
      
      FROM
      
      (
      
      SELECT 
      
      cohort_definition_id,
      time_to_event,
      dechallenge_rechallenge,
      risk_factor,
      case_series
      
      FROM 
      
      (SELECT
      cs.outcome_id	as cohort_definition_id,
      0 as time_to_event,
      0 as dechallenge_rechallenge,
      max(CAST(cs.risk_factor_settings AS INTEGER)) as risk_factor,
      max(CAST(cs.case_series_settings AS INTEGER)) as case_series
      
      from @schema.@c_table_prefixcase_settings cs
      
      {@restrict_characterization_target}?{
        WHERE cs.characterization_target_id IN (@characterization_target_ids)
      }
      
      {@restrict_target}?{
       INNER JOIN @schema.@c_table_prefixtarget_settings ts
       ON cs.characterization_target_id = ts.characterization_target_id
        WHERE ts.target_id IN (@target_ids)
      }
      
      
      GROUP BY cs.outcome_id
      ) outs_rf_cs
      
      UNION 
      
      SELECT
      ttes.outcome_id	as cohort_definition_id,
      1 as time_to_event,
      0 as dechallenge_rechallenge,
      0 as risk_factor,
      0 as case_series
      
      FROM @schema.@c_table_prefixtime_to_event_settings ttes

      {@restrict_characterization_target}?{
        WHERE ttes.characterization_target_id IN (@characterization_target_ids)
      }
            {@restrict_target}?{
       INNER JOIN @schema.@c_table_prefixtarget_settings ts
       ON ttes.characterization_target_id = ts.characterization_target_id
        WHERE ts.target_id IN (@target_ids)
      }
      
            UNION 
      
      SELECT
      outcome_id	as cohort_definition_id,
      0 as time_to_event,
      1 as dechallenge_rechallenge,
      0 as risk_factor,
      0 as case_series
      FROM @schema.@c_table_prefixdechallenge_rechallenge_settings drs
      
      {@restrict_characterization_target}?{
        WHERE drs.characterization_target_id IN (@characterization_target_ids)
      }
      {@restrict_target}?{
       INNER JOIN @schema.@c_table_prefixtarget_settings ts
       ON drs.characterization_target_id = ts.characterization_target_id
        WHERE ts.target_id IN (@target_ids)
      }
      
      ) outcomes 
    
      
      INNER JOIN
      
      @schema.@cg_table_prefixcohort_definition cg
      ON outcomes.cohort_definition_id = cg.cohort_definition_id
      
      GROUP BY 
      cg.cohort_name,
      outcomes.cohort_definition_id
      
      ;
      