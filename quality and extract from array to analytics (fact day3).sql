-- Check data quality
SELECT cardinality(metric_array), COUNT(1)
FROM array_metrics
GROUP BY 1

-- Extract data from aaray to analytics
WITH agg AS (
SELECT 
	metric_name, 
	month_start, 
	ARRAY[ SUM(metric_array[1]),
			SUM(metric_array[2]),
			SUM(metric_array[3])
	] as summed_array
FROM array_metrics
GROUP BY metric_name, month_start
)

-- Metric data each day
SELECT metric_name, 
		month_start + CAST(CAST(index AS TEXT) || 'day' AS INTERVAL),
		elem AS value
FROM agg
CROSS JOIN UNNEST(agg.summed_array) WITH ORDINALITY AS a(elem, index)