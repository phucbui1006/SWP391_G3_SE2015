-- Fix the category with ID 19 (test) to be ID 11
UPDATE categories SET category_id = 11 WHERE category_id = 19;

-- Reset the AUTO_INCREMENT of categories table to 12 so that the next category will have ID 12
ALTER TABLE categories AUTO_INCREMENT = 12;
