select *
from @schema.@cg_table_prefixcohort_subset_definition
{@use_subsets}?{where subset_definition_id in (@subset_id)}
;
