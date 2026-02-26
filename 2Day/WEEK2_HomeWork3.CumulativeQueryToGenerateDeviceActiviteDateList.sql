INSERT INTO user_devices_cumulated
WITH
	YESTERDAY AS (
		SELECT
			*
		FROM
			USER_DEVICES_CUMULATED
		WHERE
			DATE = DATE ('2023-01-09')
	),
	TODAY AS (
		SELECT
			e.USER_ID AS user_id,
			d.browser_type as browser_type,
			 DATE(event_time) AS today_date, 
			 COUNT(1) AS num_events FROM events e join devices d on d.device_id = e.device_id
            WHERE DATE(event_time)  = DATE('2023-01-10') AND USER_ID IS NOT NULL
         GROUP BY user_id, browser_type , DATE(event_time) 
		
	)
	SELECT
	COALESCE(t.user_id,y.user_id),
	COALESCE(t.browser_type,y.browser_type),
	COALESCE(y.device_activity_datelist,ARRAY[]::DATE[]) || CASE WHEN t.user_id is not null then Array[t.today_date] ELSE array[]::Date[] end as date_list,
	 COALESCE(t.today_date, y.date + Interval '1 day') as date
FROm yesterday y
    FULL OUTER JOIN
    today t ON t.user_id = y.user_id;


