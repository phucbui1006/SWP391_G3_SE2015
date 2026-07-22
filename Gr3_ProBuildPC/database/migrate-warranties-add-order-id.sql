-- Run once on an existing database. New databases already include order_id in schema.sql.
ALTER TABLE warranties ADD COLUMN order_id INT NULL AFTER customer_id;

-- Legacy rows did not record an order. Associate each one with the most recent
-- delivered order containing that product whose order date predates the request.
UPDATE warranties w
SET w.order_id = (
    SELECT od.order_id
    FROM order_details od
    INNER JOIN orders o ON o.order_id = od.order_id
    WHERE o.customer_id = w.customer_id
      AND od.product_id = w.product_id
      AND o.status_id = 5
      AND o.order_date <= w.request_date
    ORDER BY o.order_date DESC, o.order_id DESC
    LIMIT 1
);

-- Inspect this before the final ALTER. Any returned row needs manual assignment
-- because no matching delivered order could be inferred safely.
SELECT warranty_id, customer_id, product_id, request_date
FROM warranties
WHERE order_id IS NULL;

ALTER TABLE warranties MODIFY order_id INT NOT NULL;
ALTER TABLE warranties
    ADD CONSTRAINT FK_WARRANTIES_ORDERS
    FOREIGN KEY (order_id) REFERENCES orders(order_id);
