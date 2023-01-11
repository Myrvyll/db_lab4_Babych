-- Створена функція приймає 1 аргумент - назву виду пінгвіна
-- Повертає таблицю із: середньої ваги, середньої довжини плавців, середньої ширини та довжини клюва

DROP FUNCTION IF EXISTS get_overview(varchar);
CREATE OR REPLACE FUNCTION get_overview(penguin_species varchar(225))
RETURNS TABLE (average_mass float, average_flippers float, average_culmen_length float, average_culmen_depth float)
LANGUAGE 'plpgsql'
AS $$
BEGIN
    RETURN QUERY
        SELECT AVG(body_mass), AVG(flipper_length), AVG(culmen_length), AVG(average_culmen_depth)
        FROM PenguinRecords
        WHERE species = penguin_species;
END;
$$ 





