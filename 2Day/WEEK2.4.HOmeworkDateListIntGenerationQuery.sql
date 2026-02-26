WITH starter AS (
    SELECT udc.device_activity_datelist @> ARRAY [DATE(d.valid_date)]   AS is_active,
           EXTRACT(
               DAY FROM DATE('2023-01-02') - d.valid_date) AS days_since,
           udc.user_id
    FROM user_devices_cumulated udc
             CROSS JOIN
         (SELECT generate_series('2023-01-02', '2023-01-10', INTERVAL '1 day') AS valid_date) as d
    WHERE date = DATE('2023-01-02')
),
     bits AS (
         SELECT user_id,
                SUM(CASE
                        WHEN is_active THEN POW(2, 32 - days_since)
                        ELSE 0 END)::bigint::bit(32) AS datelist_int,
                DATE('2023-01-02') as date
         FROM starter
         GROUP BY user_id
     )

     SELECT * FROM bits