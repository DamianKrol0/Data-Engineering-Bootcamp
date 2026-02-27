CREATE TABLE host_activity_reduced
(
month date,
host text,
hit_array bigint[],
unique_visitor_array TEXT[],
Primary key(month,host)
)