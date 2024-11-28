select 
    s.date_of_sleep as date,
    s.awakenings_count, 
    TO_CHAR(s.start_time::TIMESTAMP, 'HH24:MI:SS') as bed_time,
    TO_CHAR(s.end_time::TIMESTAMP, 'HH24:MI:SS') as awake_time,
    s.total_minutes_asleep,
    s.total_time_in_bed,
    s.efficiency,
    s.deep_sleep_minutes,
    s.light_sleep_minutes,
    s.rem_sleep_minutes,
    a.steps,
    CASE 
        WHEN a.steps > 10000 THEN TRUE
        ELSE FALSE
    END AS step_goal_met,
    a.sedentary_minutes,
    CASE 
        WHEN a.sedentary_minutes < 1100 THEN TRUE
        ELSE FALSE
    END AS sedentary_goal_met,
    a.activity_duration,
    CASE 
        WHEN a.activity_duration > 20 THEN TRUE
        ELSE FALSE
    END AS activity_goal_met,
    m.nap,
    m.alcohol,
    m.food,
    m.activity,
    m.stretching,
    m.caffeine,
    m.sleep_quality 
from fitbit.sleep_bronze s
join fitbit.activity_bronze a
on s.date_of_sleep = a.load_date
join fitbit.manual_sleep_data m
on s.date_of_sleep = m.date
