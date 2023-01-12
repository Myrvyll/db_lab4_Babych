----------------------------------------------
-- Перевірка роботи функції
-- SELECT * FROM get_overview('Adelie Penguin (Pygoscelis adeliae)')

----------------------------------------------
-- Перевірка роботи процедури



----------------------------------------------
-- Перевірка роботи триггера
-- Варіант UPDATE з адекватними даними, які будуть оновлені без проблем
----------------------------
-- UPDATE PenguinRecords
-- SET culmen_length = 39.1,
--     culmen_depth = 18.7,
--     flipper_length = 181.0,
-- 	body_mass = 3750.0
-- WHERE sample_number = 1 AND species = 'Adelie Penguin (Pygoscelis adeliae)';


-- Варіант UPDATE з неадекватними даними, замість яких з'являться null
----------------------------
-- UPDATE PenguinRecords
-- SET culmen_length = -85,
--     culmen_depth = -652,
--     flipper_length = 0,
-- 	 body_mass = 0
-- WHERE sample_number = 1 AND species = 'Adelie Penguin (Pygoscelis adeliae)';


-- Варіант INSERT з адекватними даними, які будуть вставлені без проблем
----------------------------
-- INSERT INTO PenguinRecords(study_number, sample_number, species, island_name, stage, clutch_completion, date_egg, culmen_length, culmen_depth, flipper_length, body_mass, sex)
-- Values('PAL0910', 0, 'Adelie Penguin (Pygoscelis adeliae)', 'Torgersen', 'Adult, 1 Egg Stage', TRUE, '2010-11-11', 38.1, 18.9, 185.0, 3855.0, 'MALE');


-- Варіант INSERT з помилковими даними, які будуть замінені на null
----------------------------
-- INSERT INTO PenguinRecords(study_number, sample_number, species, island_name, stage, clutch_completion, date_egg, culmen_length, culmen_depth, flipper_length, body_mass, sex)
-- Values('PAL0910', 0, 'Adelie Penguin (Pygoscelis adeliae)', 'Torgersen', 'Adult, 1 Egg Stage', TRUE, '2010-11-11', -38.1, -18.9, -185.0, -3855.0, 'MALE');


-- Для відновлення таблиці
----------------------------
-- DELETE FROM penguinrecords
-- WHERE sample_number = 0 AND species = 'Adelie Penguin (Pygoscelis adeliae)';


-- Для перегляду результатів
select * from penguinrecords ORDER BY species, sample_number;