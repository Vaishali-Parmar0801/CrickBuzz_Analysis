--  CREATE SCHEMA 
			CREATE SCHEMA crick_buzz_analysis;

-- 1: CREATE TABLE matches	
			CREATE TABLE crick_buzz_analysis.matches (
			    match_id          INTEGER PRIMARY KEY,   -- unique per match, so it's the key
			    series_id         INTEGER,
			    series_name       TEXT,
			    match_desc        TEXT,
			    match_format      TEXT,
			    gender            TEXT,
			    start_date        DATE,
			    end_date          DATE,
			    year              INTEGER,
			    month             TEXT,
			    team1_id          INTEGER,
			    team1_name        TEXT,
			    team1_code        TEXT,
			    team2_id          INTEGER,
			    team2_name        TEXT,
			    team2_code        TEXT,
			    winner_name       TEXT,
			    winner_code       TEXT,
			    win_type          TEXT,
			    win_margin        INTEGER,
			    venue             TEXT,
			    city              TEXT,
			    lat               NUMERIC,
			    lon               NUMERIC,
			    inn1_runs         INTEGER,
			    inn1_wkts         INTEGER,
			    inn1_overs_dec    NUMERIC,
			    inn1_run_rate     NUMERIC,
			    inn2_runs         INTEGER,
			    inn2_wkts         INTEGER,
			    inn2_overs_dec    NUMERIC,
			    inn2_run_rate     NUMERIC,
			    inn3_runs         INTEGER,
			    inn3_wkts         INTEGER,
			    inn3_overs_dec    NUMERIC,
			    inn4_runs         INTEGER,
			    inn4_wkts         INTEGER,
			    inn4_overs_dec    NUMERIC,
			    first_inns_score  INTEGER,
			    second_inns_score INTEGER,
			    total_match_runs  INTEGER,
			    status            TEXT
			);

			SELECT * FROM crick_buzz_analysis.matches;

-- READ DATE 02-02-2024 AS 2 FEB, NOT 2 FEB AS DAY-MONTH
			SET datestyle TO 'ISO, DMY';  

-- VERIFY NULL VALUES AND COUNT ROWS
			SELECT COUNT(*) FROM crick_buzz_analysis.matches;
		
			SELECT COUNT(*) FROM crick_buzz_analysis.matches
				WHERE winner_name IS NULL;

-- QUERY ANALYSIS (MATCHES BY MATCH_FORMAT)
			SELECT match_format, COUNT(*) AS matches
			FROM crick_buzz_analysis.matches
			GROUP BY match_format
			ORDER BY matches DESC;

-- MOST SUCCESSFULL TEAMS
			SELECT winner_name, COUNT(*) AS wins
			FROM  crick_buzz_analysis.matches
			WHERE winner_name IS NOT NULL
			GROUP BY winner_name
			ORDER BY wins DESC
			LIMIT 10;

-- FIRST BAT VS CHASE 
			SELECT win_type, COUNT(*) AS games
			FROM crick_buzz_analysis.matches
			WHERE match_format IN ('T20','ODI')
				AND win_type IN ('Runs','Wickets')
			GROUP BY win_type;

-- AVERAGE RUN RATE BY MATCH_FORMAT
			SELECT match_format,
				 ROUND(AVG(inn1_run_rate), 2) AS avg_first_inns_runrate
			FROM crick_buzz_analysis.matches
			GROUP BY match_format
			ORDER BY avg_first_inns_runrate DESC;

-- HIGHEST-SCORING VENUES
			SELECT venue,
				COUNT(*) AS matches,
				ROUND(AVG(total_match_runs)) AS avg_total
			FROM crick_buzz_analysis.matches
			GROUP BY venue
			HAVING COUNT (*) >= 3
			ORDER BY avg_total DESC
			LIMIT 10;

-- CLOSE FINISH GAMES VS BLOWOUTS
			SELECT 
				match_desc, team1_name, team2_name, winner_name, win_margin,
			ROUND(PERCENT_RANK()
					OVER (PARTITION BY match_format ORDER BY win_margin)::numeric,2)
				AS margin_percentile,
			CASE
				WHEN PERCENT_RANK()
					OVER (PARTITION BY match_format ORDER BY win_margin) <= 0.10
				THEN 'close_finish' ELSE NULL 
			END AS flag
			FROM crick_buzz_analysis.matches
			WHERE win_type = 'Runs' AND win_margin IS NOT NULL
			ORDER BY match_format,win_margin
			LIMIT 25;
			
-- MEN VS WOMEN
			SELECT gender,
					COUNT(*) AS matches
			FROM crick_buzz_analysis.matches
			GROUP BY gender;
			
-- FIRST BAT VS CHASE IN ONE ROW PER FORMAT
			SELECT match_format,
       				COUNT(*) FILTER (WHERE win_type = 'Runs')    AS bat_first_wins,
      				COUNT(*) FILTER (WHERE win_type = 'Wickets') AS chasing_wins,
			ROUND(100.0 * COUNT(*) FILTER (WHERE win_type = 'Runs')
          			/ NULLIF(COUNT(*) FILTER (WHERE win_type IN ('Runs','Wickets')), 0), 1) AS bat_first_win_pct
			FROM crick_buzz_analysis.matches
			WHERE match_format IN ('T20','ODI')
			GROUP BY match_format;

-- TEAM-CENTRIC VIEW. THE BASE TABLE IS MATCH-CENTRIC (TEAM1 AND TEAM2 PER ROW). 
   			CREATE VIEW crick_buzz_analysis.team_match AS
				SELECT match_id, match_format, gender, start_date, venue, city,
			       team1_name AS team,
			       team2_name AS opponent,
			       winner_name,
			       (winner_name = team1_name) AS won,
			       (winner_name IS NOT NULL)  AS decided,  
			       total_match_runs
			FROM crick_buzz_analysis.matches
				UNION ALL
				SELECT match_id, match_format, gender, start_date, venue, city,
			       team2_name AS team,
			       team1_name AS opponent,
			       winner_name,
			       (winner_name = team2_name) AS won,
			       (winner_name IS NOT NULL)  AS decided,
			       total_match_runs
			FROM crick_buzz_analysis.matches;

-- TEAM WIN-RATE LEADERBOARD, RANKED WITHIN EACH FORMAT
			WITH team_stats AS (
    			SELECT
			        team,
			        match_format,
			        COUNT(*) AS played,
			        COUNT(*) FILTER (WHERE won) AS wins,
			        COUNT(*) FILTER (WHERE decided) AS decided_games,
			        ROUND(100.0 * COUNT(*) FILTER (WHERE won)
              			/ NULLIF(COUNT(*) FILTER (WHERE decided), 0), 1) AS win_pct
  		   	FROM crick_buzz_analysis.team_match
   		  	GROUP BY team, match_format)
				SELECT
				   	 match_format,team,played,wins,win_pct,
					RANK()  
					OVER (PARTITION BY match_format ORDER BY win_pct DESC, wins DESC) AS rank_in_format,
    			ROUND(AVG(win_pct) OVER (PARTITION BY match_format), 1) AS format_avg_win_pct
				FROM team_stats
				WHERE played >= 4                       
				ORDER BY match_format, rank_in_format;

-- VENUE SCORING PROFILE
			WITH venue_runs AS(
				SELECT 	
					venue,city,
					COUNT(*) AS matches,
					ROUND(AVG(total_match_runs)) AS avg_total,
					ROUND(STDDEV_SAMP(total_match_runs)) AS sd_total
				FROM crick_buzz_analysis.matches
				WHERE total_match_runs IS NOT NULL
				GROUP BY venue,city
				HAVING COUNT(*) >= 3)
				SELECT
					venue,city,matches,avg_total,sd_total,
					NTILE(4) OVER 
						(ORDER BY avg_total) AS scoring_quartile,
					RANK() OVER
						(ORDER BY avg_total DESC) AS high_score_rank
				FROM venue_runs
				ORDER BY avg_total DESC;

-- DOES A BIGGER FIRST-INNINGS SCORE HELP YOU DEFEND?
				WITH limited_over AS (
    				SELECT
			        first_inns_score,win_type,
			        	NTILE(4) OVER (ORDER BY first_inns_score) AS score_quartile
			    FROM crick_buzz_analysis.matches
			    	WHERE match_format IN ('T20','ODI')
			     	AND first_inns_score IS NOT NULL
			     	AND win_type IN ('Runs','Wickets'))
				SELECT
				    score_quartile,
				    MIN(first_inns_score) AS min_score,
				    MAX(first_inns_score) AS max_score,
				    COUNT(*) AS games,
				    ROUND(100.0 * COUNT(*) FILTER (WHERE win_type = 'Runs')
				          / COUNT(*), 1)  AS bat_first_win_pct
				FROM limited_over
				GROUP BY score_quartile;

-- RUN-RATE MOMENTUM
				SELECT
					COUNT(*) AS games,
					ROUND(AVG(inn1_run_rate),2) AS avg_first_inns_runrate,
					ROUND(AVG(inn2_run_rate),2) AS avg_second_inns_runrate,
					ROUND(AVG(inn2_run_rate-inn1_run_rate),2) AS avg_runrate_delta
				FROM crick_buzz_analysis.matches
					WHERE inn1_run_rate IS NOT NULL
					AND
					inn2_run_rate IS NOT NULL
				GROUP BY match_format
				ORDER BY avg_runrate_delta DESC;

-- RUNNING WIN TALLY PER TEAM OVER THE FEB WINDOW
				SELECT
   					team,match_format,start_date,opponent,
					   won::int AS won,
   					SUM(won::int) 
					   OVER (PARTITION BY team ORDER BY start_date, match_id
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)AS cumulative_wins,
   					ROW_NUMBER()
					   OVER (PARTITION BY team ORDER BY start_date, match_id)AS match_no
				FROM crick_buzz_analysis.team_match
					WHERE team IN (
       				SELECT team 
					   FROM crick_buzz_analysis.team_match
				GROUP BY team HAVING COUNT(*) >= 5)
				ORDER BY team, start_date, match_id;

-- FORMAT SCORING PROFILE 
				SELECT	
					match_format,
					COUNT(*) AS matches,
					ROUND(AVG(total_match_runs)) AS avg_total,
					PERCENTILE_CONT(0.5) WITHIN GROUP 
					(ORDER BY total_match_runs) AS median_total,
   				ROUND(STDDEV_SAMP(total_match_runs))AS sd_total,
	    			MAX(total_match_runs)AS max_total,
	    			MIN(total_match_runs)AS min_total
				FROM crick_buzz_analysis.matches
				WHERE total_match_runs IS NOT NULL
				GROUP BY match_format
				ORDER BY avg_total DESC;


