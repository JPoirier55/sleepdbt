{{ config(materialized='table') }}

with source_data as (
    select
        id,
        json_blob::jsonb as json_blob, 
        load_date
    from activity_raw
),

flattened_activities as (
    select
        id,
        jsonb_array_elements(json_blob->'activities') as activity, 
        load_date
    from source_data
),

activities as (
    select
        id,
        (activity->>'calories')::integer as calories,
        (activity->>'steps')::integer as steps,
        (activity->>'duration')::integer as duration,
        load_date
    from flattened_activities
),

summary_data as (
    select
        id,
        (json_blob->'summary'->>'caloriesOut')::integer as calories_out,
        (json_blob->'summary'->>'activityCalories')::integer as activity_calories,
        (json_blob->'summary'->>'caloriesBMR')::integer as calories_bmr,
        (json_blob->'summary'->>'activeScore')::integer as active_score,
        (json_blob->'summary'->>'steps')::integer as steps,
        (json_blob->'summary'->>'sedentaryMinutes')::integer as sedentary_minutes,
        (json_blob->'summary'->>'lightlyActiveMinutes')::integer as lightly_active_minutes,
        (json_blob->'summary'->>'fairlyActiveMinutes')::integer as fairly_active_minutes,
        (json_blob->'summary'->>'veryActiveMinutes')::integer as very_active_minutes,
        (json_blob->'summary'->>'marginalCalories')::integer as marginal_calories,
        (json_blob->'summary'->>'restingHeartRate')::integer as resting_heart_rate, 
        load_date
    from source_data
),

ranked_entries AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY DATE(load_date) 
            ORDER BY id DESC 
        ) AS row_num
    FROM summary_data
)


    select 
    s.*,
    coalesce(sum(a.duration)/60000,0) as activity_duration,
    coalesce(sum(a.steps),0) as activity_steps
    from ranked_entries s
    left join activities a
    on s.id = a.id
    where row_num = 1
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
