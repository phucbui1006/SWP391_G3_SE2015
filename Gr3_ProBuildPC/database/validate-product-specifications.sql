-- 1. Sản phẩm thiếu thông số bắt buộc theo category.
SELECT p.product_id, p.product_name, c.category_name, t.spec_name AS missing_required_spec
FROM PRODUCTS p
JOIN CATEGORIES c ON c.category_id = p.category_id
JOIN CATEGORY_SPEC_TEMPLATES t
  ON t.category_id = p.category_id
 AND t.is_required = TRUE
LEFT JOIN PRODUCT_SPECIFICATIONS ps
  ON ps.product_id = p.product_id
 AND ps.specification_name = t.spec_name
WHERE ps.spec_id IS NULL
ORDER BY p.category_id, p.product_id, t.display_order;

-- 2. Thông số không thuộc template của category.
SELECT p.product_id, p.product_name, c.category_name,
       ps.specification_name, ps.specification_value
FROM PRODUCT_SPECIFICATIONS ps
JOIN PRODUCTS p ON p.product_id = ps.product_id
JOIN CATEGORIES c ON c.category_id = p.category_id
LEFT JOIN CATEGORY_SPEC_TEMPLATES t
  ON t.category_id = p.category_id
 AND t.spec_name = ps.specification_name
WHERE t.template_id IS NULL
ORDER BY p.category_id, p.product_id, ps.specification_name;

-- 3. Giá trị SELECT không nằm trong allowed_values của template.
SELECT p.product_id, p.product_name, c.category_name,
       ps.specification_name, ps.specification_value, t.allowed_values
FROM PRODUCT_SPECIFICATIONS ps
JOIN PRODUCTS p ON p.product_id = ps.product_id
JOIN CATEGORIES c ON c.category_id = p.category_id
JOIN CATEGORY_SPEC_TEMPLATES t
  ON t.category_id = p.category_id
 AND t.spec_name = ps.specification_name
WHERE t.spec_type = 'SELECT'
  AND FIND_IN_SET(ps.specification_value, t.allowed_values) = 0
ORDER BY p.category_id, p.product_id, ps.specification_name;

-- 4. Thông số bị trùng trên cùng một sản phẩm.
SELECT product_id, specification_name, COUNT(*) AS duplicate_count
FROM PRODUCT_SPECIFICATIONS
GROUP BY product_id, specification_name
HAVING COUNT(*) > 1
ORDER BY product_id, specification_name;

