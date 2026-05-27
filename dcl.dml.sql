DROP USER IF EXISTS db_reader_user;
DROP USER IF EXISTS db_admin_user;

DROP ROLE IF EXISTS yourdb_readonly;
DROP ROLE IF EXISTS yourdb_admin;

CREATE ROLE yourdb_admin;
CREATE ROLE yourdb_readonly;

GRANT USAGE ON SCHEMA public TO yourdb_admin;
GRANT USAGE ON SCHEMA public TO yourdb_readonly;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO yourdb_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO yourdb_readonly;

CREATE USER db_admin_user WITH PASSWORD 'admin123';
CREATE USER db_reader_user WITH PASSWORD 'reader123';

GRANT yourdb_admin TO db_admin_user;
GRANT yourdb_readonly TO db_reader_user;

REVOKE UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM yourdb_readonly;

SET ROLE db_admin_user;

SELECT current_user;
SELECT COUNT(*) FROM customers;

INSERT INTO customers (name, email, phone)
VALUES ('Admin Test', 'admin_test@example.kz', '+77000000000')
RETURNING *;

UPDATE customers
SET phone = '+77001110000'
WHERE email = 'admin_test@example.kz';

DELETE FROM customers
WHERE email = 'admin_test@example.kz';

RESET ROLE;

SET ROLE db_reader_user;

SELECT current_user;
SELECT COUNT(*) FROM customers;

BEGIN;

INSERT INTO customers (name, email, phone)
VALUES ('Reader Test', 'reader_test@example.kz', '+77000000000');

ROLLBACK;

BEGIN;

UPDATE customers
SET phone = '+000'
WHERE email = 'alice@example.kz';

ROLLBACK;

BEGIN;

DELETE FROM customers
WHERE customer_id = 1;

ROLLBACK;

RESET ROLE;

REVOKE yourdb_readonly FROM db_admin_user;

TRUNCATE TABLE order_items RESTART IDENTITY CASCADE;
TRUNCATE TABLE orders RESTART IDENTITY CASCADE;
TRUNCATE TABLE products RESTART IDENTITY CASCADE;
TRUNCATE TABLE customers RESTART IDENTITY CASCADE;

INSERT INTO customers (name, email, phone)
VALUES
('Alice Karimova', 'alice@example.kz', '+77001112233'),
('Dias Nurgali', 'dias@example.kz', '+77005556677'),
('Aruzhan Sarsen', 'aruzhan@example.kz', '+77009998877'),
('Timur Bek', 'timur@example.kz', '+77001234567'),
('Aigerim Nur', 'aigerim@example.kz', '+77007654321');

INSERT INTO products (sku, name, price)
VALUES
('ITEM-001', 'Fiber 100 Mbps', 8000),
('ITEM-002', 'Fiber 300 Mbps', 12000),
('ITEM-003', 'WiFi Router', 15000),
('ITEM-004', 'Static IP', 5000),
('ITEM-005', 'Installation', 3000);

INSERT INTO orders (customer_id, order_date, status)
VALUES
((SELECT customer_id FROM customers WHERE email='alice@example.kz'), NOW(), 'new'),
((SELECT customer_id FROM customers WHERE email='dias@example.kz'), NOW(), 'processing'),
((SELECT customer_id FROM customers WHERE email='aruzhan@example.kz'), NOW(), 'completed'),
((SELECT customer_id FROM customers WHERE email='timur@example.kz'), NOW(), 'cancelled'),
((SELECT customer_id FROM customers WHERE email='aigerim@example.kz'), NOW(), 'new');

INSERT INTO order_items (order_id, product_id, quantity)
VALUES
((SELECT order_id FROM orders WHERE status='new' LIMIT 1),
 (SELECT product_id FROM products WHERE sku='ITEM-001'), 1),
((SELECT order_id FROM orders WHERE status='processing' LIMIT 1),
 (SELECT product_id FROM products WHERE sku='ITEM-002'), 2),
((SELECT order_id FROM orders WHERE status='completed' LIMIT 1),
 (SELECT product_id FROM products WHERE sku='ITEM-003'), 1),
((SELECT order_id FROM orders WHERE status='cancelled' LIMIT 1),
 (SELECT product_id FROM products WHERE sku='ITEM-004'), 1);

SELECT * FROM customers WHERE email='dias@example.kz';

UPDATE customers
SET phone = '+77000000000'
WHERE email='dias@example.kz';

SELECT * FROM orders WHERE status='new';

UPDATE orders
SET status='processing'
WHERE status='new';

SELECT o.order_id, o.status, c.email
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id;

UPDATE orders o
SET status='completed'
FROM customers c
WHERE o.customer_id = c.customer_id
AND c.email='aruzhan@example.kz';

BEGIN;

DELETE FROM order_items
WHERE order_id IN (
    SELECT order_id FROM orders WHERE status='cancelled'
);

DELETE FROM orders
WHERE status='cancelled';

SELECT COUNT(*) FROM orders WHERE status='cancelled';

ROLLBACK;