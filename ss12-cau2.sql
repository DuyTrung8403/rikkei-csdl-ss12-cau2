CREATE TABLE products (
    product_id SERIAL PRIMARY KEY ,
    name VARCHAR(100),
    stock INT
);

CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY ,
    product_id INT REFERENCES products(product_id),
    quantity INT
);

INSERT INTO products (name, stock)
VALUES
    ('iPhone 15', 5),
    ('iPad Air', 2);

CREATE OR REPLACE FUNCTION check_product_stock()
    RETURNS TRIGGER AS $$
DECLARE
    v_stock INT;
BEGIN
    SELECT stock INTO v_stock
    FROM products
    WHERE product_id = NEW.product_id;

    IF v_stock IS NULL THEN
        RAISE EXCEPTION 'Khong ton tai sp id %';
    ELSIF v_stock < NEW.quantity THEN
        RAISE EXCEPTION 'Khong du san pham trong kho';
    END IF;

    UPDATE products
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_sales_insert
    BEFORE INSERT ON sales
    FOR EACH ROW
EXECUTE FUNCTION check_product_stock();

INSERT INTO sales (product_id, quantity) VALUES (1, 3);
INSERT INTO sales (product_id, quantity) VALUES (1, 4);
INSERT INTO sales (product_id, quantity) VALUES (2, 5);