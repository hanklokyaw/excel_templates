SELECT * FROM book.production;

-- 5. How many total distinct polices are there in this data set? (1 point)
-- Ans
SELECT DISTINCT POLICYNUMBER FROM book.production;

DESCRIBE book.production;

-- 6. Calculate actual Mode_Premium ( Percent% x Region % x Sum of Mode_Premium) (1 point)
SELECT `PERCENT_[0]`, `Region %_[0]`, `Sum of MODE_PREMIUM_[0]`, `PERCENT_[0]` * `Region %_[0]` * ROUND(REPLACE(REPLACE(`Sum of MODE_PREMIUM_[0]`, "$",""),",",""),2) AS Mode_Premium FROM book.production;

-- 7. Calculate actual Target_Preimum( Percent% x Region % x Sum of Target _Premium) (1point)
SELECT `PERCENT_[0]`, `Region %_[0]`, `Sum of TARGET_PREMIUM`, `PERCENT_[0]` * `Region %_[0]` * ROUND(REPLACE(REPLACE(`Sum of TARGET_PREMIUM`, "$",""),",",""),2) AS Target_Preimum FROM book.production;

-- 8. What is the total “In Forced” Actual_Mode_Premium between 2/1/2023 – 7/31/2024 (hint: clean data format) (3 points)
SELECT `Year`, `Month`, `Day`, 
`APPLICATION_STATUS_[0]`, 
`PERCENT_[0]` * `Region %_[0]` * ROUND(REPLACE(REPLACE(`Sum of MODE_PREMIUM_[0]`, "$",""),",",""),2) AS Mode_Premium 
FROM book.production
WHERE `Year` >= 2023 and `Year` <= 2024 
and MONTH(STR_TO_DATE(`Month`,'%M')) >= 2 and MONTH(STR_TO_DATE(`Month`, "%M")) <=7 
and `APPLICATION_STATUS_[0]` = "In Force";

-- 9.	How many agents doesn’t not have an active license status (approved license) (2points)
-- SELECT DISTINCT License FROM book.production;
SELECT COUNT(*) FROM book.production WHERE License != "Approved";

-- 10.	What is the difference in Target Premium between agent with active license and agent without active license (use 2024 Target Premium) (3points)
WITH tp_license AS (
SELECT `PERCENT_[0]` * `Region %_[0]` * ROUND(REPLACE(REPLACE(`Sum of TARGET_PREMIUM`, "$",""),",",""),2) AS Target_Preimum
FROM book.production
WHERE License = "Approved" AND `Year_[0]` = 2024
),
tp_no_license AS (
SELECT `PERCENT_[0]` * `Region %_[0]` * ROUND(REPLACE(REPLACE(`Sum of TARGET_PREMIUM`, "$",""),",",""),2) AS Target_Preimum
FROM book.production
WHERE License != "Approved"  AND `Year_[0]` = 2024
) 

SELECT 
    SUM(ls.Target_Preimum) - SUM(no_ls.Target_Preimum) AS "Target Premium Difference"
FROM tp_license AS ls
JOIN tp_no_license AS no_ls ON 1=1;

-- 11.	Who are the top 3 and bottom 3 Carrier by Actual_total_Premium in 2024 (2 point)
WITH actual_tp AS (
SELECT `CARRIER_NAME`, `Year_[0]`, SUM(`PERCENT_[0]` * `Region %_[0]` * ROUND(REPLACE(REPLACE(`Sum of TARGET_PREMIUM`, "$",""),",",""),2)) AS Target_Premium
FROM book.production
WHERE `Year_[0]` = 2024
GROUP BY `CARRIER_NAME`, `Year_[0]`
),

rank_tp AS (
SELECT `CARRIER_NAME`,
Target_Premium,
RANK() OVER(ORDER BY Target_Premium DESC) AS rank_top,
RANK() OVER(ORDER BY Target_Premium ASC) AS rank_bottom
FROM actual_tp
)

SELECT tp1.`CARRIER_NAME` as "Top 3 Carrier", tp1.Target_Premium, tp1.rank_top AS "Rank", "---", tp2.`CARRIER_NAME` as "Bottom 3 Carrier", tp2.Target_Premium, tp2.rank_bottom AS "Rank"
FROM rank_tp AS tp1
LEFT JOIN rank_tp AS tp2
ON tp1.rank_top = tp2.rank_bottom
WHERE tp1.rank_top <= 3 and tp2.rank_bottom <= 3
ORDER BY tp1.rank_top ASC;

-- 12. Display the total count of unique policies in pivot table by each region* (5 points)
SELECT `Region_[0]`, COUNT(DISTINCT `POLICYNUMBER`) AS "Unique Policy Number"
FROM book.production
GROUP BY `Region_[0]`;

SELECT `Region_[0]`, COUNT(DISTINCT `POLICYNUMBER`)
FROM book.production
WHERE `Region_[0]` = "Monrovia Region";