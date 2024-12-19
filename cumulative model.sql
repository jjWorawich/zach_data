 CREATE TYPE season_stats AS (
                         season Integer,
                         gp INTEGER,
                         pts REAL,
                         ast REAL,
                         reb REAL,
                       );
SELECT * FROM player_seasons;
CREATE TYPE scoring_class AS ENUM('star', 'good', 'average', 'bad');

CREATE TABLE players (
	 player_name TEXT,
	 height TEXT,
	 college TEXT,
	 country TEXT,
	 draft_year TEXT,
	 draft_round TEXT,
	 draft_number TEXT,
	 season_stats season_stats[],
	 scoring_class scoring_class,
	 year_since_last_season INTEGER,
	 current_seasons INTEGER,
	 is_active boolean,
	 PRIMARY KEY (player_name, current_seasons)
);



INSERT INTO players
WITH yesterday AS (
    SELECT * 
    FROM players 
    WHERE current_seasons = 2000
),
today AS (
    SELECT * 
    FROM player_seasons 
    WHERE season = 2001
)
SELECT 
    COALESCE(y.player_name, t.player_name) AS player_name,
    COALESCE(y.height, t.height) AS height,
    COALESCE(y.college, t.college) AS college,
    COALESCE(y.country, t.country) AS country,
    COALESCE(y.draft_year, t.draft_year) AS draft_year,
    COALESCE(y.draft_round, t.draft_round) AS draft_round,
    COALESCE(y.draft_number, t.draft_number) AS draft_number,
    CASE 
        WHEN y.season_stats IS NULL THEN 
            ARRAY[ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats]
        WHEN t.season IS NOT NULL THEN 
            y.season_stats || ARRAY[ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats]
        ELSE 
            y.season_stats
    END AS season_stats,
    CASE 
        WHEN t.season IS NOT NULL THEN 
            CASE 
                WHEN t.pts > 20 THEN 'star'
                WHEN t.pts > 15 THEN 'good'
                WHEN t.pts > 10 THEN 'average'
                ELSE 'bad'
            END::scoring_class
        ELSE 
            y.scoring_class
    END AS scoring_class,
	t.season IS NOT NULL as is_active,
    CASE 
        WHEN t.season IS NOT NULL THEN 0
        ELSE y.year_since_last_season + 1
    END AS year_since_last_season,
    COALESCE(t.season, y.current_seasons + 1) AS current_seasons,
	CASE
FROM 
    today t 
FULL OUTER JOIN 
    yesterday y 
ON 
    t.player_name = y.player_name;

SELECT * FROM players;

-- เเตกจาก array อีกที
WITH unnested AS(
SELECT player_name, 
		UNNEST(season_stats)::season_stats as season_stats
FROM players
WHERE current_seasons = 2001 AND player_name ='Michael Jordan'
)
-- เเตกออกมาเป็นเเต่ละ column เลย
SELECT player_name,
		(season_stats::season_stats).*
FROM unnested

-- Compare player performance between first year and last year
SELECT player_name,
        (season_stats[cardinality(season_stats)]::season_stats).pts/
         CASE WHEN (season_stats[1]::season_stats).pts = 0 THEN 1 -- [1] rookie year
             ELSE  (season_stats[1]::season_stats).pts END
            AS ratio_most_recent_to_first
 FROM players
 WHERE current_seasons = 1998;
