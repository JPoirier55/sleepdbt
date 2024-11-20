{{ config(materialized='table') }}

with source_data AS (
    SELECT
        id,
        json_blob::jsonb AS json_data,
        load_date
    FROM sleep_raw
),

flattened_sleep AS (
    SELECT
        id,
        jsonb_array_elements(json_data->'sleep') AS sleep_data,
        load_date
    FROM source_data
),

sleep_details AS (
    SELECT
        id,
        sleep_data->>'awakeCount' AS awake_count,
        sleep_data->>'awakeDuration' AS awake_duration,
        sleep_data->>'awakeningsCount' AS awakenings_count,
        sleep_data->>'dateOfSleep' AS date_of_sleep,
        (sleep_data->>'duration')::bigint AS duration,
        (sleep_data->>'efficiency')::integer AS efficiency,
        sleep_data->>'endTime' AS end_time,
        (sleep_data->>'isMainSleep')::boolean AS is_main_sleep,
        (sleep_data->>'logId')::bigint AS log_id,
        (sleep_data->>'minutesAfterWakeup')::integer AS minutes_after_wakeup,
        (sleep_data->>'minutesAsleep')::integer AS minutes_asleep,
        (sleep_data->>'minutesAwake')::integer AS minutes_awake,
        (sleep_data->>'minutesToFallAsleep')::integer AS minutes_to_fall_asleep,
        (sleep_data->>'restlessCount')::integer AS restless_count,
        (sleep_data->>'restlessDuration')::integer AS restless_duration,
        sleep_data->>'startTime' AS start_time,
        (sleep_data->>'timeInBed')::integer AS time_in_bed,
        load_date
    FROM flattened_sleep
),

summary_data AS (
    SELECT
        id,
        (json_data->'summary'->'stages'->>'deep')::integer AS deep_sleep_minutes,
        (json_data->'summary'->'stages'->>'light')::integer AS light_sleep_minutes,
        (json_data->'summary'->'stages'->>'rem')::integer AS rem_sleep_minutes,
        (json_data->'summary'->'stages'->>'wake')::integer AS wake_minutes,
        (json_data->'summary'->>'totalMinutesAsleep')::integer AS total_minutes_asleep,
        (json_data->'summary'->>'totalSleepRecords')::integer AS total_sleep_records,
        (json_data->'summary'->>'totalTimeInBed')::integer AS total_time_in_bed,
        load_date
    FROM source_data
),


ranked_entries AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY DATE(load_date) 
            ORDER BY id DESC 
        ) AS row_num
    FROM sleep_details
)


select 
    sd.id,
    sd.awake_count,
    sd.awake_duration,
    sd.awakenings_count,
    sd.date_of_sleep,
    sd.duration,
    sd.efficiency,
    sd.end_time,
    sd.is_main_sleep,
    sd.log_id,
    sd.minutes_after_wakeup,
    sd.minutes_asleep,
    sd.minutes_awake,
    sd.minutes_to_fall_asleep,
    sd.restless_count,
    sd.restless_duration,
    sd.start_time,
    sd.time_in_bed,
    sm.deep_sleep_minutes,
    sm.light_sleep_minutes,
    sm.rem_sleep_minutes,
    sm.wake_minutes,
    sm.total_minutes_asleep,
    sm.total_sleep_records,
    sm.total_time_in_bed
from ranked_entries sd
left join summary_data sm
on sd.id = .id
where row_num = 1
