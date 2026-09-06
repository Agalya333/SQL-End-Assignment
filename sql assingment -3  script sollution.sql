CREATE DATABASE IF NOT EXISTS elearning_db;
USE elearning_db;
CREATE TABLE learners (
    learner_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL
);
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);
CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    learner_id INT,
    course_id INT,
    quantity INT NOT NULL,
    purchase_date DATE NOT NULL,
    FOREIGN KEY (learner_id) REFERENCES learners(learner_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
INSERT INTO learners (full_name, country) VALUES
('Rahul Sharma', 'India'),
('Anita Patel', 'India'),
('John Smith', 'USA'),
('Emma Watson', 'UK'),
('David Miller', 'USA');
INSERT INTO courses (course_name, category, unit_price) VALUES
('Python for Beginners', 'Beginner', 3000.00),
('SQL Masterclass', 'Database', 5000.00),
('Data Science Bootcamp', 'Advanced', 12000.00),
('Web Development 101', 'Beginner', 4000.00),
('Advanced Machine Learning', 'Advanced', 15000.00),
('Cloud DevOps Essentials', 'Cloud', 8000.00);
INSERT INTO purchases (learner_id, course_id, quantity, purchase_date) VALUES
(1, 1, 2, '2026-01-10'),
(1, 2, 1, '2026-01-15'),
(2, 2, 2, '2026-01-20'),
(2, 3, 1, '2026-02-01'),
(3, 3, 1, '2026-02-05'),
(3, 5, 1, '2026-02-10'),
(4, 1, 1, '2026-02-12'),
(4, 4, 1, '2026-02-15');
SELECT 
    l.full_name AS Learner_Name,
    c.course_name AS Course_Name,
    c.category AS Category,
    p.quantity AS Quantity,
    FORMAT(p.quantity * c.unit_price, 2) AS Total_Amount,
    p.purchase_date AS Purchase_Date
FROM purchases p
INNER JOIN learners l ON p.learner_id = l.learner_id
INNER JOIN courses c ON p.course_id = c.course_id
ORDER BY (p.quantity * c.unit_price) DESC;
SELECT 
    l.full_name AS Learner_Name,
    c.course_name AS Course_Name,
    IFNULL(p.quantity, 0) AS Quantity
FROM learners l
LEFT JOIN purchases p ON l.learner_id = p.learner_id
LEFT JOIN courses c ON p.course_id = c.course_id;
SELECT 
    c.course_name AS Course_Name,
    p.purchase_id AS Purchase_ID,
    IFNULL(p.quantity, 0) AS Quantity
FROM purchases p
RIGHT JOIN courses c ON p.course_id = c.course_id;
SELECT 
    l.full_name,
    l.country,
    FORMAT(SUM(p.quantity * c.unit_price), 2) AS Total_Spending
FROM learners l
JOIN purchases p ON l.learner_id = p.learner_id
JOIN courses c ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name, l.country;
SELECT 
    c.course_name,
    SUM(p.quantity) AS Total_Quantity
FROM courses c
JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name
ORDER BY Total_Quantity DESC
LIMIT 3;
SELECT 
    c.category,
    FORMAT(SUM(p.quantity * c.unit_price), 2) AS Total_Revenue,
    COUNT(DISTINCT p.learner_id) AS Unique_Learners
FROM courses c
JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.category;
SELECT 
    l.full_name
FROM learners l
JOIN purchases p ON l.learner_id = p.learner_id
JOIN courses c ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING COUNT(DISTINCT c.category) > 1;
SELECT 
    c.course_name,
    c.category
FROM courses c
LEFT JOIN purchases p ON c.course_id = p.course_id
WHERE p.purchase_id IS NULL;
SELECT 
    l.full_name,
    SUM(p.quantity * c.unit_price) AS Total_Spending
FROM learners l
JOIN purchases p ON l.learner_id = p.learner_id
JOIN courses c ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING Total_Spending > (
    SELECT AVG(learner_total)
    FROM (
        SELECT SUM(p2.quantity * c2.unit_price) AS learner_total
        FROM purchases p2
        JOIN courses c2 ON p2.course_id = c2.course_id
        GROUP BY p2.learner_id
    ) AS avg_table
);
SELECT 
    course_name,
    unit_price
FROM courses
WHERE unit_price > ANY (
    SELECT unit_price 
    FROM courses 
    WHERE category = 'Beginner'
);
SELECT 
    l1.full_name,
    l1.country,
    SUM(p1.quantity * c1.unit_price) AS Total_Spent
FROM learners l1
JOIN purchases p1 ON l1.learner_id = p1.learner_id
JOIN courses c1 ON p1.course_id = c1.course_id
GROUP BY l1.learner_id, l1.full_name, l1.country
HAVING Total_Spent > (
    SELECT AVG(country_spend)
    FROM (
        SELECT l2.learner_id, SUM(p2.quantity * c2.unit_price) AS country_spend
        FROM learners l2
        JOIN purchases p2 ON l2.learner_id = p2.learner_id
        JOIN courses c2 ON p2.course_id = c2.course_id
        WHERE l2.country = l1.country
        GROUP BY l2.learner_id
    ) AS inner_spend
);
WITH LearnerSpending AS (
    SELECT 
        l.learner_id,
        l.full_name,
        SUM(p.quantity * c.unit_price) AS total_spending
    FROM learners l
    JOIN purchases p ON l.learner_id = p.learner_id
    JOIN courses c ON p.course_id = c.course_id
    GROUP BY l.learner_id, l.full_name
)
SELECT full_name, total_spending
FROM LearnerSpending
WHERE total_spending > 10000;
SELECT 
    l.full_name,
    SUM(p.quantity * c.unit_price) AS Total_Spent,
    CASE 
        WHEN SUM(p.quantity * c.unit_price) > 15000 THEN 'High Value'
        WHEN SUM(p.quantity * c.unit_price) BETWEEN 8000 AND 15000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Value_Segment
FROM learners l
JOIN purchases p ON l.learner_id = p.learner_id
JOIN courses c ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name;
SELECT 
    c.course_name,
    COALESCE(SUM(p.quantity), 0) AS Total_Purchased
FROM courses c
LEFT JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name;
CREATE OR REPLACE VIEW category_performance_view AS
SELECT 
    c.category AS Category,
    SUM(p.quantity * c.unit_price) AS Total_Revenue,
    COUNT(p.purchase_id) AS Number_Of_Purchases,
    AVG(p.quantity * c.unit_price) AS Avg_Revenue_Per_Purchase
FROM courses c
JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.category;
SELECT * FROM category_performance_view;