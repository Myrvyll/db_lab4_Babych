DROP PROCEDURE IF EXISTS get_number_of_full_clutches(varchar(50));

CREATE OR REPLACE PROCEDURE get_number_of_full_clutches(island varchar(50))
LANGUAGE 'plpgsql' 
AS $$

DECLARE clutches_count int;

BEGIN
    SELECT COUNT(clutch_completion) INTO clutches_count FROM penguinrecords
    WHERE island_name = island;
    RAISE INFO 'On % island there were % completed clutches.', island, clutches_count; 
END;
$$;