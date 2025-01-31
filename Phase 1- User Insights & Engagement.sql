/*Phase 1: User Insights & Engagement (Product Team Request)
 
  📌 Business Question: How many users do we have? How engaged are they?
  📌 Stakeholder: Product Team (Understanding user behavior & platform engagement)*/


-- 1. Total Number of Users
SELECT 
    COUNT(*) AS total_users
FROM
    users;


-- 2. Subscription Type Breakdown (Free vs. Premium)
SELECT 
    subscription_type,
    COUNT(*) AS subscription_count,
    ROUND(100.0 * (COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    users)),
            2) AS percentage
FROM
    users
GROUP BY subscription_type;


-- 3. Count of Active Users (Last 30 Days) 
SELECT 
    COUNT(*) AS active_users,
    ROUND(100.0 * COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    users),
            2) AS pct
FROM
    users
WHERE
    DATEDIFF(CURRENT_DATE(), last_active_date) <= 30;     -- {Measures platform engagement in the last 30 days}


-- 4. List of Active Users & Their Last Active Date (users whose last_active_date is within the last 30 days)
SELECT 
    user_id,
    name,
    signup_date,
    subscription_type,
    last_active_date,
    DATEDIFF(last_active_date, signup_date) AS days_since_last_active
FROM
    users
WHERE
    DATEDIFF(CURRENT_DATE(), last_active_date) <= 30
ORDER BY days_since_last_active DESC;


-- 5. Percentage of Active Users by Subscription Type
SELECT 
    subscription_type,
    COUNT(*) AS users_count,
    ROUND((100.0 * COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    users)),
            2) AS pct
FROM
    users
WHERE
    DATEDIFF(CURRENT_DATE(), last_active_date) <= 30
GROUP BY subscription_type;

