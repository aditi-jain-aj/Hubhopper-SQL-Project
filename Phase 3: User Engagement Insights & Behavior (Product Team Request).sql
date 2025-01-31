Phase 3: User Engagement Insights & Behavior (Product Team Request)

📌 Business Question: How are users engaging with our platform? Which genres and podcasts drive the most engagement?
📌 Stakeholder: Product & Content Team (Improving content strategy)

-- 1. Top 5 Genres with Highest Engagement (Last 30 Days)
WITH genre_data AS (
  SELECT genre, 
        COUNT(DISTINCT l.user_id) AS users_count, 
        DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT l.user_id) DESC) AS ranking
  FROM 
    listening_activity l
  JOIN 
    podcasts p
  ON 
    l.podcast_id=p.podcast_id
    WHERE DATE_DIFF(CURRENT_DATE(),interaction_date)<=30
  GROUP BY 
    genre)
SELECT 
    genre, 
    users_count, 
    ROUND(100.0*users_count/ SUM(users_count) OVER(),2) AS pct
FROM 
  genre_data
WHERE 
  ranking<=5;

-- 2. Free vs. Premium Breakdown on Top 5 Genres (Last 30 Days)
WITH genre_data AS (
  SELECT genre, 
        subscription_type,
        COUNT(DISTINCT l.user_id) AS users_count, 
        DENSE_RANK() OVER(PARTITION BY subscription_type ORDER BY COUNT(DISTINCT l.user_id) DESC) AS ranking
  FROM 
    listening_activity l
  INNER JOIN 
    podcasts p
  ON 
    l.podcast_id=p.podcast_id
  INNER JOIN 
    users u
  ON
    u.user_id=l.user_id
  WHERE DATE_DIFF(CURRENT_DATE(),interaction_date)<=30
  GROUP BY 
    1,2)
SELECT 
    genre, 
    subscription_type,
    users_count, 
    CONCAT(ROUND(100.0*users_count/ SUM(users_count) OVER(),2),"%") AS pct_contribution
FROM 
  genre_data
WHERE 
  ranking<=5;

-- 3. Top 5 Most-Listened Podcasts (Last 30 Days)
WITH podcasts_data AS (
    SELECT 
        p.title, p.genre,
        u.subscription_type, 
        COUNT(DISTINCT l.user_id) as unique_users,
        SUM(l.duration_listened) AS listening_time_in_mins, ---- Engagement metric
        DENSE_RANK() OVER(PARTITION BY u.subscription_type ORDER BY SUM(l.duration_listened) DESC) AS ranking
    FROM
       podcasts p
    INNER JOIN 
        listening_activity l
    ON 
        p.podcast_id=l.podcast_id
    INNER JOIN 
        users u
    ON 
        u.user_id=l.user_id
    WHERE 
        DATE_DIFF(CURRENT_DATE(),interaction_date)<=30
    GROUP BY 1,2,3)
SELECT 
    title, genre,
      subscription_type, 
        unique_users,   
          listening_time_in_mins,
           ROUND(listening_time_in_mins/ unique_users,2) AS avg_listening_time_per_user,
            ROUND(100.0*unique_users/ SUM(unique_users) OVER(PARTITION BY subscription_type),2) AS users_pct_contribution
FROM 
  podcasts_data
WHERE ranking<=5;

-- 4. Listening wise User Engagement Trends – Active Users Over Time {tracking of whether engagement is growing or declining over the past 4 months}

SELECT DATE_FORMAT(interaction_date,"MMMM-yyyy") AS month, ROUND(AVG(duration_listened),2) AS avg_listening_time_in_mins,
COUNT(CASE WHEN duration_listened>=40 THEN user_id END) AS `Highly_Engaged_Users [>=40 mins]`,
COUNT(CASE WHEN duration_listened BETWEEN 11 AND 39 THEN user_id END) AS `Casual_Users  [11-39 mins]`,
COUNT(CASE WHEN duration_listened<=10 THEN user_id END) AS `Dormant_Users [<=10 mins]`
FROM listening_activity l
JOIN podcasts p
ON p.podcast_id=l.podcast_id
WHERE DATE_DIFF(CURRENT_DATE(),interaction_date)<=120
GROUP BY 1
ORDER BY MAX(interaction_date);

-- 5. Genre wise User Engagement Trends
SELECT 
    p.genre,
    u.subscription_type,
    COUNT(CASE WHEN MONTH(interaction_date) = 10 THEN l.user_id END) AS October,
    COUNT(CASE WHEN MONTH(interaction_date) = 11 THEN l.user_id END) AS November,
    COUNT(CASE WHEN MONTH(interaction_date) = 12 THEN l.user_id END) AS December,
    COUNT(CASE WHEN MONTH(interaction_date) = 1 THEN l.user_id END) AS January
FROM podcasts p
JOIN listening_activity l ON p.podcast_id = l.podcast_id
JOIN users u ON l.user_id = u.user_id
GROUP BY 1, 2
ORDER BY 1;

-- 6. Avg listening time by genre & subscription_type
SELECT p.genre, u.subscription_type, COUNT(DISTINCT l.user_id) AS users_count, ROUND(AVG(duration_listened),2) AS `avg_listening_time [in mins]`,
ROUND((100.0*SUM(duration_listened)/(SELECT SUM(duration_listened) FROM ranked_listening_activity)),2) AS pct_contribution
FROM ranked_listening_activity l
JOIN podcasts p
ON p.podcast_id=l.podcast_id
JOIN users u
ON u.user_id=l.user_id
GROUP BY 1,2
ORDER BY 1,5 DESC;


-- 7. Average time gap between user interactions (in days)
WITH interaction_gap AS(SELECT user_id, interaction_date,
  LEAD(interaction_date) OVER(PARTITION BY user_id ORDER BY interaction_date) as next_interaction_date
  FROM ranked_listening_activity)
  SELECT ROUND(AVG(DATE_DIFF(next_interaction_date, interaction_date)),0) AS avg_gap
  FROM interaction_gap
  WHERE interaction_Date IS NOT NULL;

-- 8. User Cohort: Categorizing Users into New, Retained, One-time, and Inactive/Churned
WITH user_cohort AS (SELECT l.user_id, u.signup_date, 
  MIN(l.interaction_date) AS first_interaction_date, 
  MAX(l.interaction_date) AS latest_interaction_date,
  DATE_DIFF(MAX(interaction_date),signup_date) AS days_since_signup,
  CASE 
      WHEN MIN(l.interaction_date)=MAX(l.interaction_date) THEN "One Time User"
      WHEN DATE_DIFF(CURRENT_DATE(),u.signup_date)<=30 THEN "New User"
      WHEN DATE_DIFF(CURRENT_DATE(),MAX(interaction_date))<=30 THEN "Retained User"
      ELSE "Inactive/Churned User"
    END AS user_type
FROM listening_activity l
JOIN users u
ON l.user_id=u.user_id
GROUP BY 1,2)
SELECT user_type, COUNT(user_id), ROUND(100.0* COUNT(user_id)/SUM(COUNT(user_id)) OVER(),2) AS pct_contribution
FROM user_cohort
GROUP BY 1;
