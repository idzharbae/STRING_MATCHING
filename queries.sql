SELECT matches.city_name, matches.city_id, matches.suburb_name, matches.suburb_id, matches.trgm_match AS matches, ((matches.trgm_match / (15 + matches.trgm_total - matches.trgm_match)) + (matches.trgm_match / least(15, matches.trgm_total) )) /2 AS score 
	FROM 
	(
		SELECT c.city_name, c.city_id, s.suburb_name, s.suburb_id, ti.trgm_match, ( select count(distinct cst.trigram) from city_suburb_trgm cst where cst.suburb_id = s.suburb_id) AS trgm_total
		FROM suburb s
		INNER JOIN
		( SELECT count(distinct tr.trigram) AS trgm_match, tr.suburb_id
		FROM city_suburb_trgm AS tr
		WHERE tr.trigram IN ('ban','and','ndu','dun','ung','ng ','g k',' ka','kab','abu','bup','upa','pat','ate','ten')
		GROUP BY tr.suburb_id) AS ti ON ti.suburb_id=s.suburb_id
		INNER JOIN city c 
		ON c.city_id = s.city_id
	) AS matches 
	order by score desc limit 1;




SELECT matches.city_name, matches.city_id, matches.suburb_name, matches.suburb_id, matches.trgm_match AS matches, ((matches.trgm_match / (21 + matches.trgm_total - matches.trgm_match)) + (matches.trgm_match / least(21, matches.trgm_total) )) /2 AS score  FROM  (  SELECT c.city_name, c.city_id, s.suburb_name, s.suburb_id, ti.trgm_match, ( select count(distinct cst.trigram) from city_suburb_trgm cst where cst.suburb_id = s.suburb_id) AS trgm_total  FROM suburb s  INNER JOIN  ( SELECT count(distinct tr.trigram) AS trgm_match, tr.suburb_id  FROM city_suburb_trgm AS tr  WHERE tr.trigram IN ('bog','ogo','gor','or ','r k',' ka','kab','abu','bup','upa','pat','ate','ten','en ','n d',' dr','dra','ram','ama','mag','aga') GROUP BY tr.suburb_id) AS ti ON ti.suburb_id=s.suburb_id INNER JOIN city c ON c.city_id = s.city_id ) AS matches order by score desc limit 1;

SELECT matches.city_name, matches.city_id, matches.suburb_name, matches.suburb_id, matches.trgm_match AS matches, ((matches.trgm_match / (21 + matches.trgm_total - matches.trgm_match)) + (matches.trgm_match / least(21, matches.trgm_total) )) /2 AS score  FROM  (  SELECT c.city_name, c.city_id, s.suburb_name, s.suburb_id, ti.trgm_match, ( select count(distinct cst.trigram) from city_suburb_trgm cst where cst.suburb_id = s.suburb_id) AS trgm_total  FROM suburb s  INNER JOIN  ( SELECT count(distinct tr.trigram) AS trgm_match, tr.suburb_id  FROM city_suburb_trgm AS tr  WHERE tr.trigram IN ('bog','ogo','gor','or ','r k',' ka','kab','abu','bup','upa','pat','ate','ten','en ','n d',' dr','dra','ram','ama','mag','aga') GROUP BY tr.suburb_id HAVING count(distinct tr.trigram) > 1) AS ti ON ti.suburb_id=s.suburb_id INNER JOIN city c ON c.city_id = s.city_id ) AS matches order by score desc limit 1;

-- trigger auto insert to city_suburb trgm
DELIMITER $$
CREATE TRIGGER suburb_generate_trigram
   AFTER INSERT
   ON suburb FOR EACH ROW
BEGIN
   DECLARE suburb_count INT;
  DECLARE suburb_name_length int;
  DECLARE current_suburb_row int;
  declare x int ;
  declare i int ;
  declare v_suburb_name text;
  declare v_city_name text;
  declare v_suburb_id int;
  declare v_city_id int;
  declare city_suburb_name text;
  
    SELECT NEW.suburb_id INTO v_suburb_id;
    SELECT NEW.suburb_name INTO v_suburb_name;
    SELECT NEW.city_id INTO v_city_id;
    SELECT c.city_name FROM city c WHERE c.city_id = v_city_id INTO v_city_name;
    set i=1;
    set x=3;
    SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( 
    CONCAT(v_city_name, CONCAT(' ', v_suburb_name))
    , ',', ''), '.', '' ), "'", ''), '-', ''), '"', ''), '(', ''), ')', '' ) into city_suburb_name;
    SELECT CHAR_LENGTH(city_suburb_name) into suburb_name_length;
    
    while suburb_name_length >= 3 do
        INSERT INTO city_suburb_trgm (suburb_id,trigram) values (v_suburb_id,substring(LOWER(city_suburb_name) from i for x));
        set suburb_name_length=suburb_name_length-1;
        set i=i+1;
    end while ;
END$$    

-- populate procedure
CREATE PROCEDURE populate_city_suburb_trgm()
BEGIN
  DECLARE suburb_count INT;
  DECLARE suburb_name_length int;
  DECLARE current_suburb_row int;
  declare x int ;
  declare i int ;
  declare v_suburb_name text;
  declare v_city_name text;
  declare v_suburb_id int;
  declare v_city_id int;
  declare city_suburb_name text;
  SELECT COUNT(*) FROM suburb INTO suburb_count;
  SET current_suburb_row = 0;
 
 select count(*) from city_suburb_trgm;

  WHILE current_suburb_row < suburb_count DO
    SELECT s.suburb_id, s.suburb_name, s.city_id FROM suburb s limit current_suburb_row, 1 INTO v_suburb_id, v_suburb_name, v_city_id;
    SELECT c.city_name FROM city c WHERE c.city_id = v_city_id INTO v_city_name;
    set i=1;
    set x=3;
    SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( 
        CONCAT(v_city_name, CONCAT(' ', v_suburb_name))
         , ',', ''), '.', '' ), "'", ''), '-', ''), '"', ''), '(', ''), ')', '' ) into city_suburb_name;
    SELECT CHAR_LENGTH(city_suburb_name) into suburb_name_length;
	while suburb_name_length >= 3 do
	    INSERT INTO city_suburb_trgm (suburb_id,trigram) values (v_suburb_id,substring(LOWER(city_suburb_name) from i for x));
	    set suburb_name_length=suburb_name_length-1;
	    set i=i+1;
	end while ;

    SET current_suburb_row = current_suburb_row + 1;
  END WHILE;
END;

-- levenshtein
select c.city_name, s.suburb_name, levenshtein('jembrana tst suburp', CONCAT(c.city_name, CONCAT(' ', s.suburb_name))) FROM suburb s LEFT JOIN city c on s.city_id = c.city_id order by levenshtein('jembrana tst suburp', CONCAT(c.city_name, CONCAT(' ', s.suburb_name))) limit 10;

DELIMITER $$
CREATE FUNCTION levenshtein( s1 VARCHAR(255), s2 VARCHAR(255) )
    RETURNS INT
    DETERMINISTIC
    BEGIN
        DECLARE s1_len, s2_len, i, j, c, c_temp, cost INT;
        DECLARE s1_char CHAR;
        -- max strlen=255
        DECLARE cv0, cv1 VARBINARY(256);

        SET s1_len = CHAR_LENGTH(s1), s2_len = CHAR_LENGTH(s2), cv1 = 0x00, j = 1, i = 1, c = 0;

        IF s1 = s2 THEN
            RETURN 0;
        ELSEIF s1_len = 0 THEN
            RETURN s2_len;
        ELSEIF s2_len = 0 THEN
            RETURN s1_len;
        ELSE
            WHILE j <= s2_len DO
                SET cv1 = CONCAT(cv1, UNHEX(HEX(j))), j = j + 1;
            END WHILE;
            WHILE i <= s1_len DO
                SET s1_char = SUBSTRING(s1, i, 1), c = i, cv0 = UNHEX(HEX(i)), j = 1;
                WHILE j <= s2_len DO
                    SET c = c + 1;
                    IF s1_char = SUBSTRING(s2, j, 1) THEN
                        SET cost = 0; ELSE SET cost = 1;
                    END IF;
                    SET c_temp = CONV(HEX(SUBSTRING(cv1, j, 1)), 16, 10) + cost;
                    IF c > c_temp THEN SET c = c_temp; END IF;
                    SET c_temp = CONV(HEX(SUBSTRING(cv1, j+1, 1)), 16, 10) + 1;
                    IF c > c_temp THEN
                        SET c = c_temp;
                    END IF;
                    SET cv0 = CONCAT(cv0, UNHEX(HEX(c))), j = j + 1;
                END WHILE;
                SET cv1 = cv0, i = i + 1;
            END WHILE;
        END IF;
        RETURN c;
    END$$
DELIMITER ;