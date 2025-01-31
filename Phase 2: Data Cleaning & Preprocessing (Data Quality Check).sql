/*Phase 2: Data Cleaning & Preprocessing (Data Quality Check)

📌 Business Question: How do we ensure our data is clean and usable for analysis?
📌 Stakeholder: Data Team (Ensuring accurate reporting & analysis)*/

-- 1. Capturing Duplicate Records in Listening Activity Table
SELECT 
    *
FROM
    listening_activity
WHERE
    (user_id , podcast_id, interaction_date, action) IN (SELECT 
            user_id, podcast_id, interaction_date, action
        FROM
            listening_activity
        GROUP BY 1 , 2 , 3 , 4
        HAVING COUNT(*) > 1)
ORDER BY user_id;


-- 2. Counting Duplicate Records in Listening Activity Table
SELECT 
    user_id,
    podcast_id,
    interaction_date,
    action,
    COUNT(*) AS dupliacte_records
FROM
    listening_activity
GROUP BY 1 , 2 , 3 , 4
HAVING COUNT(*) > 1;   -- No duplicates found
