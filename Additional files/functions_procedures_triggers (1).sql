-- Лабораторне заняття №8

-- 1. Створити процедуру, яка обчислює в 3 рази збільшене значення свого аргументу. 

DROP PROCEDURE IF EXISTS triple(integer);
CREATE OR REPLACE PROCEDURE triple(INOUT x integer)
LANGUAGE plpgsql
AS $$
  BEGIN
    x := x * 3;
  END;
$$;

-- Виклик процедури - CALL
CALL triple(25)

-- другий спосіб використання процедури triple(x)
DO $$
DECLARE myvar int := 5;
    BEGIN
        CALL triple(myvar);
        RAISE INFO 'myvar = %', myvar; -- expected value is 15
    END;
$$;


-- 2. Написати функцію, яка видаляє з таблиці Customers всіх покупців, що не мають замовлень. 
DROP FUNCTION IF EXISTS clean_emp();
CREATE OR REPLACE FUNCTION clean_emp() RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN 
   DELETE FROM customers 
   WHERE customers.cust_id IN 
      (SELECT customers.cust_id from customers left join orders using(cust_id) where orders.cust_id is NULL);
END;
$$; 

-- Виклик функції - SELECT
SELECT clean_emp();
-- Перевірка, що з Customers видалився покупець, в якого немає замовлень
SELECT * FROM customers

-- Повернемо таблицю Customers до початкового вигляду:
INSERT INTO Customers(cust_id, cust_name, cust_address, cust_city, cust_state, cust_zip, cust_country, cust_contact)
VALUES('1000000002', 'Kids Place', '333 South Lake Drive', 'Columbus', 'OH', '43333', 'USA', 'Michelle Green');


-- 3. Створити процедуру get_vendors(country_arg), яка надає інформацію про постачальників з країни, вказаної в аргументі. 
DROP PROCEDURE IF EXISTS get_vendors(varchar(50));
CREATE OR REPLACE PROCEDURE get_vendors(country_arg varchar(50))
LANGUAGE 'plpgsql'
AS $$
DECLARE record_name vendors.vend_name%TYPE;
DECLARE record_country vendors.vend_country%TYPE;

BEGIN
    SELECT vend_name, vend_country into record_name, record_country FROM vendors WHERE vend_country = country_arg;
    RAISE INFO 'Vendor_name: %,  Vendor_country: %', TRIM(record_name), TRIM(record_country);
END;
$$;
-- Виклик процедури
CALL get_vendors('USA');


--4. Написати функцію get_vendors(country_arg), яка виводить всіх постачальників 
--із заданої країни. Попередньо видалити однойменну процедуру. 

DROP PROCEDURE IF EXISTS get_vendors(varchar);

DROP FUNCTION IF EXISTS get_vendors(varchar); 
CREATE OR REPLACE FUNCTION get_vendors(country_arg varchar) 
    RETURNS TABLE (vendors_name varchar, country varchar)
    LANGUAGE 'plpgsql'
AS $$
BEGIN
    RETURN QUERY
        SELECT vend_name::varchar, vend_country::varchar
		FROM vendors 
		WHERE vend_country = country_arg;
END;
$$
-- Виклик функції
SELECT * FROM get_vendors('USA');
-- Другий варіант виклику
SELECT get_vendors('USA');


-- 5. Створити процедуру insert_order(num_arg, cust_id_arg), яка додає в таблицю orders
-- новий рядок із вказаними аргументами та поточною датою. Продемонструвати роботу процедури.
DROP PROCEDURE IF EXISTS insert_order(integer, varchar);
CREATE OR REPLACE PROCEDURE insert_order(num_arg integer, cust_id_arg varchar)
LANGUAGE 'plpgsql'
AS $$
BEGIN
    INSERT INTO orders(order_num, order_date, cust_id) VALUES (num_arg, CURRENT_DATE, cust_id_arg);
END;
$$;

SELECT * FROM Orders
-- Виклик процедури
CALL insert_order(20033, '1000000004');
SELECT * FROM Orders
CALL insert_order(20035, '10000003'); -- не спрацює, оскільки порушується цілісність даних, такого cust_id не існує

-- Завдання 6-9 дано як додаткові приклади функцій і процедур, які можна створити в Лабораторній роботі 4, 
-- виконувати їх не обов'язково 



-- 10. Створити тригер, який при додаванні нового рядка в таблицю Customers записує
-- значення поля cust_state у верхньому регістрі.

SELECT * FROM customers

DROP TRIGGER IF EXISTS customer_state_insert ON customers;

-- Перший етап: створення тригерної функції
CREATE OR REPLACE FUNCTION upper_cust_state() RETURNS trigger 
LANGUAGE 'plpgsql'
AS
$$
     BEGIN
          UPDATE Customers 
          SET cust_state = upper(cust_state) WHERE Customers.cust_id = NEW.cust_id; 
		  RETURN NULL; -- result is ignored since this is an AFTER trigger
     END;
$$;

-- Другий етап: створення тригеру
CREATE TRIGGER customer_state_insert 
AFTER INSERT ON customers
FOR EACH ROW EXECUTE FUNCTION upper_cust_state()

-- Перевірка роботи. Задамо штат у вигляді 'fl' (Florida, очікуємо в таблиці значення FL)
INSERT INTO Customers(cust_id, cust_name, cust_state) VALUES ('1000000025', 'Toys Emporium', 'fl');
-- видалимо доданий рядок з таблиці customers
DELETE FROM customers where cust_id = '1000000025';

select * from customers;

-- 12. Створити тригер, який виконує аудит будь-яких змін в таблиці Orders: 
-- INSERT, UPDATE або DELETE рядка в таблиці orders має фіксуватися в окремій 
-- таблиці orders_audit, в якій також фіксується поточний час, ім'я користувача та тип виконуваної операції.

-- Виконаємо даний приклад в спрощенному варіанті - будемо фіксувати тільки оновлення в таблиці orders 
SELECT user from orders

DROP TABLE IF EXISTS orders_audit;
CREATE TABLE orders_audit(
	id SERIAL PRIMARY KEY,
	updated TIMESTAMP,
	user_name varchar(50) NOT NULL
);

CREATE OR REPLACE FUNCTION table_orders_audit() RETURNS trigger 
LANGUAGE 'plpgsql'
AS $$
BEGIN
 	INSERT INTO orders_audit(updated, user_name)
		VALUES(NOW(), user);
	RETURN NULL;
END;
$$ ;

CREATE TRIGGER orders_update_details 
AFTER UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION table_orders_audit();

-- Перевіримо, як працює тригер. Переглянемо спочатку вміст таблиці orders
SELECT * FROM orders
-- Тригер спрацює при оновленні таблиці orders. 
-- Виконаємо будь-яке оновлення даних в таблиці orders.
UPDATE orders SET order_num = 20027 WHERE order_num = 20025;
-- Переглянемо вміст таблиці orders_audit. 
-- Бачимо час (в 2-му стовпчику) та хто вніс зміни (в 3-му стовпчику)
SELECT * FROM orders_audit;

