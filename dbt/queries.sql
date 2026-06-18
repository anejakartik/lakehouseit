.mode markdown
.headers on

-- Daily active users — last 30 days
SELECT day, dau, events
FROM main_gold.gold__dau
WHERE day >= current_date - INTERVAL 30 DAY
ORDER BY day DESC;

-- Current MRR by plan
SELECT plan, active_subscriptions, mrr_usd, avg_mrr_usd
FROM main_gold.gold__mrr_by_plan;

-- Monthly churn
SELECT month, churned_subs, total_subs_at_start, churn_rate
FROM main_gold.gold__monthly_churn
ORDER BY month DESC
LIMIT 6;

-- Weekly active users by plan
SELECT week, user_plan, wau
FROM main_gold.gold__weekly_active_users
ORDER BY week DESC, user_plan
LIMIT 20;
