INSERT INTO hosts_cumulated
WITH yesterday AS (
    SELECT * FROM hosts_cumulated
    WHERE date = DATE('2023-01-08')
),
    today AS (
          SELECT host,
                 DATE(event_time) AS today_date,
                 COUNT(1) AS num_events FROM events
            WHERE DATE(event_time) = DATE('2023-01-09')
            AND host IS NOT NULL
         GROUP BY host, DATE(event_time)
    )

SELECT
       COALESCE(t.host, y.host),
       COALESCE(y.host_activity_datelist,
           ARRAY[]::DATE[])
            || CASE WHEN
                t.host IS NOT NULL
                THEN ARRAY[t.today_date]
                ELSE ARRAY[]::DATE[]
                END AS date_list,
       COALESCE(t.today_date, y.date + Interval '1 day') as date
FROm yesterday y
    FULL OUTER JOIN
    today t ON t.host = y.host;

	