-- ถ้าต้องการเปลี่ยนเป็นเดือนอื่นให้เปลี่ยน Date ที่ users เเละ series
WITH users AS(
	SELECT * FROM user_cumulated 
	WHERE date = DATE('2023-01-31') -- Last day 
),

	series AS(

		SELECT * 
		FROM generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 day') -- + ไปทีละ 1 วัน
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
		
-- Analytic part to gain active by week month
-- สามารถเปลี่่ยนการใส่เลข 1 เพื่อให้มันตรวจสอบช่วงที่เราต้องการได้
SELECT 
	user_id,
	CAST(SUM(CAST(placeholder_int_value AS INTEGER)) AS BIT(32)),
	BIT_COUNT(CAST(SUM(CAST(placeholder_int_value AS INTEGER)) AS BIT(32))) > 0 
		AS dim_is_monthly_active,
	BIT_COUNT(CAST('11111110000000000000000000000000' AS BIT(32)) & CAST(SUM(CAST( placeholder_int_value AS INTEGER)) AS BIT(32))) > 0 
		AS dim_is_weekly_active,
	BIT_COUNT(CAST('10000000000000000000000000000000' AS BIT(32)) & CAST(SUM(CAST( placeholder_int_value AS INTEGER)) AS BIT(32))) > 0 
		AS dim_is_daily_active
			
FROM place_holder_ints
GROUP BY user_id	