Phase 4: Marketing Optimization & Revenue Growth (Marketing Team Request)

📌Business Question: How can we maximize revenue and drive Free-to-Premium conversions by evaluating and optimizing marketing campaign performance and subscription plans?
📌Stakeholder: Marketing & Growth Team (Focusing on user conversion, campaign effectiveness, and revenue optimization)

-- 1. Revenue Breakdown – Subscription Plans & Transaction Amounts
SELECT 
    s.plan_type,  
    CASE 
        WHEN SUM(amount) >= 10000000 THEN CONCAT(ROUND(SUM(amount)/10000000.0, 2), ' Cr')  -- Crore
        WHEN SUM(amount) >= 100000 THEN CONCAT(ROUND(SUM(amount)/100000.0, 2), ' L')      -- Lakh
        ELSE SUM(amount)
    END AS total_revenue,
    ROUND(100.0*SUM(amount)/(SELECT SUM(amount) FROM revenue),2) AS pct_contribution
FROM subscriptions s
JOIN revenue r
ON s.subscription_id=r.subscription_id
GROUP BY 1;

-- 2. Most Effective Marketing Channel (Conversions per Campaign)
SELECT m.medium AS marketing_channel,
SUM(m.conversions) AS total_conversions,
ROUND(100.0*SUM(m.conversions)/(SELECT SUM(conversions) FROM marketing_campaigns),2) AS pct_contribution
FROM marketing_campaigns m
GROUP BY 1
ORDER BY 3 DESC;

-- 3. Top 10 Best-Performing Podcast Creators
SELECT 
    c.name AS creator_name, 
    SUM(l.duration_listened) AS total_engagement,
    COUNT(DISTINCT l.user_id) AS unique_users
FROM creators c
JOIN podcasts p ON c.creator_id = p.creator_id
JOIN listening_activity l ON l.podcast_id = p.podcast_id
GROUP BY c.name
ORDER BY total_engagement DESC
LIMIT 10;
