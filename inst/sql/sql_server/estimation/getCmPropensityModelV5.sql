--@use_indication
--@indication_id

SELECT cmc.covariate_id
	,cmc.covariate_name
	,cmpm.coefficient
FROM (
	SELECT covariate_id
		,covariate_name
	FROM @schema.@cm_table_prefixcovariate
	WHERE analysis_id = @analysis_id
		AND database_id = '@database_id'
	
	UNION
	
	SELECT 0 AS covariate_id
		,'intercept' AS covariate_name
	) cmc
JOIN @schema.@cm_table_prefixpropensity_model cmpm ON cmc.covariate_id = cmpm.covariate_id
WHERE cmpm.target_id = @target_id
	AND cmpm.comparator_id = @comparator_id
	AND cmpm.analysis_id = @analysis_id
	AND cmpm.database_id = '@database_id';
