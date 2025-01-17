WITH users AS(
	SELECT * FROM user_cumulated 
	WHERE date = DATE('2023-01-30') -- Last day 
),

	series AS(

		SELECT * 
		FROM generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 day') 
		    as series_date
	),


		place_holder_ints AS( 
			SELECT CAST(CASE 
					WHEN
						dates_active @> ARRAY[DATE(series_date)]
						THEN CAST(POW(2, 32 - (date - DATE(series_date))) AS BIGINT)
						ELSE 0
						END AS BIT(32)) as placeholder_int_value,
					*
			FROM users
					CROSS JOIN series
		
		)
SELECT * FROM place_holder_ints
		
SELECT 
	user_id,
	CAST(CAST(SUM( placeholder_int_value) AS BIGINT) AS BIT(32)),
	BIT_COUNT(CAST(CAST(SUM( placeholder_int_value) AS BIGINT) AS BIT(32)))
FROM place_holder_ints
GROUP BY user_id	

		AS dim_is_monthly_acitive,
	BIT_COUNT(CAST('11111110000000000000000000000000' AS BIT(32)) &
		CAST(CAST(SUM( placeholder_int_value) AS BIGINT) AS BIT(32)) > 0,
	BIT_COUNT(CAST('10000000000000000000000000000000' AS BIT(32)) &
		CAST(CAST(SUM( placeholder_int_value) AS BIGINT) AS BIT(32)) > 0		
FROM place_holder_ints
GROUP BY user_id

