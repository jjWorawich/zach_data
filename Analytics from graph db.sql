SELECT v.properties ->> 'player_name',
		e.object_identifier,
		CAST(v.properties->> 'number_of_games' as REAL) / 
		CASE WHEN CAST(v.properties ->> 'total_points' as REAL) = 0 THEN 1 
		ELSE CAST(v.properties ->> 'total_points' as REAL) END,
		e.properties ->> 'subject_points',
		e.properties ->> 'num_games'
FROM vertices v JOIN edges e
	ON v.identifier = e.subject_identifier
	AND v.type = e.subject_type
WHERE e.object_type = 'player'::vertex_type