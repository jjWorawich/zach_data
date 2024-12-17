 -- CREATE TYPE season_stats AS (
 --                         season Integer,
 --                         pts REAL,
 --                         ast REAL,
 --                         reb REAL,
 --                         weight INTEGER
 --                       );


 -- CREATE TABLE players (
 --     player_name TEXT,
 --     height TEXT,
 --     college TEXT,
 --     country TEXT,
 --     draft_year TEXT,
 --     draft_round TEXT,
 --     draft_number TEXT,
 --     seasons season_stats[],
 --     current_season INTEGER,
 --     PRIMARY KEY (player_name, current_season)
 -- );


WITH yesterday AS(
	SELECT * FROM players WHERE current_seasons = 1995
),

today AS (
	SELECT * FROM player_seasons WHERE season = 1996
)


SELECT 
		COALESCE(y.player_name, t.player_name) AS player_name,
		COALESCE(y.height, t.height) AS height,
		COALESCE(y.college, t.college) AS college,
		COALESCE(y.draft_year, t.draft_year) AS draft_year,
		COALESCE(y.draft_round, t.draft_round) AS draft_round,
		COALESCE(y.draft_number, t.draft_number) AS draft_number,
		CASE WHEN y.season_stats IS NULL
			THEN ARRAY[ROW(
				t.season,
				t.gp,
				t.pts,
				t.reb,
				t.ast
			)::season_stats]
		ELSE y.season_stats || ARRAY[ROW(
				t.season,
				t.gp,
				t.pts,
				t.reb,
				t.ast
			)::season_stats]
	   END
FROM today t 
FULL OUTER JOIN yesterday y 
on t.player_name = y.player_name
 




 