
INSERT INTO host_activity_reduced
WITH yesterday AS (
    SELECT *
    FROM host_activity_reduced
    WHERE month = '2023-01-01'
),
     today AS (
         SELECT host,
                DATE(event_time) AS today_date,
                COUNT(1) as num_hits,
				COUNT(Distinct user_id) as user_ids
         FROM events
         WHERE DATE( event_time) = DATE('2023-01-02')
         AND host IS NOT NULL
         GROUP BY host,user_id, DATE(event_time)
     )

SELECT

DATE('2023-01-01') AS month,

    COALESCE(y.host, t.host) AS host,
       COALESCE(y.hit_array,
           array_fill(NULL::BIGINT, ARRAY[DATE('2023-01-02') - DATE('2023-01-01')]))
        || ARRAY[t.num_hits] AS hit_array,

    COALESCE(y.UNIQUE_VISITOR_ARRAY,
            ARRAY[CAST(t.user_ids AS TEXT)]) AS unique_visitor_array
		FROM yesterday y
    FULL OUTER JOIN today t
        ON y.host = t.HOST
		ON CONFLICT (month, host)
DO 
    UPDATE SET unique_visitor_array = EXCLUDED.unique_visitor_array;