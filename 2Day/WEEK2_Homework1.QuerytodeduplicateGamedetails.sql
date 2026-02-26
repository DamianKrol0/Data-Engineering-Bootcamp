WITH
	DEDUPED AS (
		SELECT
			G.GAME_DATE_EST,
			G.SEASON,
			G.HOME_TEAM_ID,
			GD.*,
			ROW_NUMBER() OVER (
				PARTITION BY
					GD.GAME_ID,
					GD.PLAYER_ID,
					GD.TEAM_ID
				ORDER BY
					G.GAME_DATE_EST
			) AS ROW_NUM
		FROM
			GAME_DETAILS GD
			JOIN GAMES G ON G.GAME_ID = GD.GAME_ID
		
	)
SELECT
	GAME_DATE_EST AS dim_game_date,
	SEASON AS dim_season,
	TEAM_ID AS Dim_team_id,
	
	PLAYER_ID as dim_palyer_id,
	
	PLAYER_NAME as dim_player_name,

	START_POSITION as dim_start_position,
		TEAM_ID = HOME_TEAM_ID AS DIM_IS_PLAYING_AT_HOME,
	COALESCE(POSITION('DNP' IN COMMENT), 0) > 0 AS DIM_DID_NOT_play,
	COALESCE(POSITION('DND' IN COMMENT), 0) > 0 AS DIM_DID_NOT_DRESSED,
	COALESCE(POSITION('NWT' IN COMMENT), 0) > 0 AS DIM_DID_NOT_WITH_TEAM,
		CAST(SPLIT_PART(MIN, ':', 1) AS REAL)
		+CAST(SPLIT_PART(MIN, ':', 2) AS REAL)/60AS MINUTES,
	FGM as m_fgm,
	FGA as m_fga,
	FG3M AS m_fg3m,
	FG3A as m_fg3a,
	FTM as m_ftm,
	FTA as m_fta,
	OREB as m_oreb,
	DREB as m_oreb,
	REB as M_reb,
	AST as m_ast,
	STL as m_stl,
	BLK as m_blk,
	"TO" AS m_TURNOVERS,
	PF as m_pf,
	PTS as m_pts,
	PLUS_MINUS as m_plus_minus
FROM
	DEDUPED
WHERE
	ROW_NUM = 1