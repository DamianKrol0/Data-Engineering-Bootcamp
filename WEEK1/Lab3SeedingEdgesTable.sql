-- INSERT INTO edges
-- WITH DEDUPLIED AS 
-- (
-- SELECT *, ROW_NUMBER() over (Partition by player_id,game_id ) as row_number
-- FROM Game_details
-- )
-- SELECT
-- player_id as subject_identifier,
-- 'player'::vertex_type as subject_type,
-- game_id as object_identifier,
-- 'game'::vertex_type as object_type,
-- 'plays_in'::edge_type as edge_type,
-- json_build_object
-- (
-- 'start_position', start_position,
-- 'pts', pts,
-- 'team_id', team_id,
-- 'team_abbreviation', team_abbreviation
-- ) as properties
-- FROM DEDUPLIED
-- WHERE Row_number = 1
-- SELECT
-- 	V.PROPERTIES ->> 'player_name',
-- 	MAX(CAST(E.PROPERTIES ->> 'pts' AS INTEGER))
-- FROM
-- 	VERTICES V
-- 	JOIN EDGES E ON E.SUBJECT_IDENTIFIER = V.IDENTIFIER
-- 	AND E.SUBJECT_TYPE = V.TYPE
-- GROUP BY
-- 	1
-- ORDER BY
-- -- 	2 DESC
-- INSERT INTO EDGES
-- WITH
-- 	DEDUPLIED AS (
-- 		SELECT
-- 			*,
-- 			ROW_NUMBER() OVER (
-- 				PARTITION BY
-- 					PLAYER_ID,
-- 					GAME_ID
-- 			) AS ROW_NUMBER
-- 		FROM
-- 			GAME_DETAILS
-- 	),
-- 	FILTERED AS (
-- 		SELECT
-- 			*
-- 		FROM
-- 			DEDUPLIED
-- 		WHERE
-- 			ROW_NUMBER = 1
-- 	),
-- 	AGGREGATED AS (
-- 		SELECT
-- 			F1.PLAYER_ID AS subject_player_id,
-- 			MAX(F1.PLAYER_NAME) AS subject_player_name,
-- 			F2.PLAYER_ID AS object_player_id,
-- 			MAX(F2.PLAYER_NAME) as object_player_name,
-- 			CASE
-- 				WHEN F1.TEAM_ABBREVIATION = F2.TEAM_ABBREVIATION THEN 'shares_team'::EDGE_TYPE
-- 				ELSE 'plays_against'::EDGE_TYPE
-- 			END as edge_type,
-- 			COUNT(1) AS NUM_GAMES,
-- 			SUM(F1.PTS) AS subject_POINTS,
-- 			SUM(F2.PTS) AS object_POINTS
-- 		FROM
-- 			FILTERED F1
-- 			JOIN FILTERED F2 ON F1.GAME_ID = F2.GAME_ID
-- 			AND F1.PLAYER_NAME <> F2.PLAYER_NAME
-- 		WHERE
-- 			F1.PLAYER_ID > F2.PLAYER_ID
-- 		GROUP BY
-- 			F1.PLAYER_ID,
-- 			F2.PLAYER_ID,
-- 			CASE
-- 				WHEN F1.TEAM_ABBREVIATION = F2.TEAM_ABBREVIATION THEN 'shares_team'::EDGE_TYPE
-- 				ELSE 'plays_against'::EDGE_TYPE
-- 			END
-- 	)
-- SELECT
-- 	subject_player_id as subject_identifier,
-- 	'player'::vertex_type as subject_type,
-- 	object_player_id as object_identifier,
-- 	'player'::vertex_type as vertex_type,
-- 	edge_type as edge_type,
-- 	json_build_object(
-- 'num_games', num_games,
-- 'subject_points', subject_points,
-- 'object_points', object_points
-- 	)
-- FROM
-- 	AGGREGATED
SELECT
	V.PROPERTIES ->> 'player_name',
	e.object_identifier,
	CAST(V.PROPERTIES ->> 'number_of_games' AS REAL)/
	CASE
		WHEN CAST(V.PROPERTIES ->> 'total_points' AS REAL) = 0 THEN 1
		ELSE CAST(V.PROPERTIES ->> 'total_points' AS REAL)
	END,
	e.properties->>'subject_points',
	e.properties->>'num_games'
FROM
	VERTICES V
	JOIN EDGES E ON V.IDENTIFIER = E.SUBJECT_IDENTIFIER
	AND V.TYPE = E.SUBJECT_TYPE
WHERE
	E.OBJECT_TYPE = 'player'::VERTEX_TYPE