-- Тригер виникає у випадку оновлення даних або вставки нового запису у PenguinRecords
-- Якщо у ході вищевказаних змін значення полів довжини клюва, ширини клюва, довжини плавців чи маси тіла стають 
-- менше або дорівнюють нулю, тригер заміняє їх на null значення.

DROP TRIGGER IF EXISTS check_numerics ON PenguinRecords;

CREATE OR REPLACE FUNCTION check_numerics_func() RETURNS trigger
LANGUAGE 'plpgsql'
AS $$
    BEGIN
        IF NEW.culmen_depth <= 0   THEN 
		     UPDATE PenguinRecords 
		     SET culmen_depth = NULL 
			 WHERE species = NEW.species AND sample_number = NEW.sample_number;
			 END IF;
        IF NEW.culmen_length <= 0   THEN 
		     UPDATE PenguinRecords 
		     SET culmen_length = NULL 
			 WHERE species = NEW.species AND sample_number = NEW.sample_number;
			 END IF;
        IF NEW.flipper_length <= 0   THEN 
		     UPDATE PenguinRecords 
		     SET flipper_length = NULL 
			 WHERE species = NEW.species AND sample_number = NEW.sample_number;
			 END IF;
        IF NEW.body_mass <= 0   THEN 
		     UPDATE PenguinRecords 
		     SET body_mass = NULL 
			 WHERE species = NEW.species AND sample_number = NEW.sample_number;
			 END IF;
        RETURN NULL;
    END;
$$;

CREATE TRIGGER check_numerics
AFTER INSERT OR UPDATE ON PenguinRecords
FOR EACH ROW EXECUTE FUNCTION check_numerics_func()