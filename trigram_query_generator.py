s = input()

res = []

for i in range(0, len(s)-2, 1):
   res.append(s[i:i+3])

q = '''
SELECT matches.city_name, matches.city_id, matches.suburb_name, matches.suburb_id, matches.trgm_match AS matches, ((matches.trgm_match / (%d + matches.trgm_total - matches.trgm_match)) + (matches.trgm_match / least(%d, matches.trgm_total) )) /2 AS score 
	FROM 
	(
		SELECT c.city_name, c.city_id, s.suburb_name, s.suburb_id, ti.trgm_match, ( select count(distinct cst.trigram) from city_suburb_trgm cst where cst.suburb_id = s.suburb_id) AS trgm_total
		FROM suburb s
		INNER JOIN
		( SELECT count(distinct tr.trigram) AS trgm_match, tr.suburb_id
		FROM city_suburb_trgm AS tr
		WHERE tr.trigram IN (%s)
		GROUP BY tr.suburb_id) AS ti ON ti.suburb_id=s.suburb_id
		INNER JOIN city c 
		ON c.city_id = s.city_id
	) AS matches 
	order by score desc limit 1;
''' % (len(res), len(res), "'" + "','".join(res) + "'")

q2 = "SELECT matches.city_name, matches.city_id, matches.suburb_name, matches.suburb_id, matches.trgm_match AS matches, ((matches.trgm_match / (%d + matches.trgm_total - matches.trgm_match)) + (matches.trgm_match / least(%d, matches.trgm_total) )) /2 AS score  FROM  (  SELECT c.city_name, c.city_id, s.suburb_name, s.suburb_id, ti.trgm_match, ( select count(distinct cst.trigram) from city_suburb_trgm cst where cst.suburb_id = s.suburb_id) AS trgm_total  FROM suburb s  INNER JOIN  ( SELECT count(distinct tr.trigram) AS trgm_match, tr.suburb_id  FROM city_suburb_trgm AS tr  WHERE tr.trigram IN (%s) GROUP BY tr.suburb_id HAVING count(distinct tr.trigram) > 1) AS ti ON ti.suburb_id=s.suburb_id INNER JOIN city c ON c.city_id = s.city_id ) AS matches order by score desc limit 1;"% (len(res), len(res), "'" + "','".join(res) + "'")

print(q.replace('\n','').replace('\t', ' '))
print(q2.replace('\n','').replace('\t', ' '))

