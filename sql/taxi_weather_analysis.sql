WITH weather_data AS (
  SELECT 
    DATE(CAST(year AS INT64), CAST(mo AS INT64), CAST(da AS INT64)) AS date,
    prcp AS precipitation,
    temp AS mean_temperature
  FROM `bigquery-public-data.noaa_gsod.gsod2022`
  WHERE stn = '725060' AND prcp != 99.99
),
taxi_data AS (
  SELECT 
    DATE(pickup_datetime) AS date,
    AVG((TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) / 60.0) / trip_distance) AS avg_min_per_mile,
    COUNT(*) AS trip_count
  FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
  WHERE trip_distance BETWEEN 1 AND 10 
    AND TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE) BETWEEN 2 AND 60
  GROUP BY 1
)
SELECT 
  w.date,
  w.precipitation,
  w.mean_temperature,
  t.avg_min_per_mile,
  t.trip_count,
  -- Logic mapping directly to the buckets in Screenshot 2026-06-02 at 4.43.42 PM.jpg
  CASE 
    WHEN w.precipitation > 0 AND w.mean_temperature < 32.0 THEN 'Snow/Sleet'
    WHEN w.precipitation = 0 THEN 'Clear'
    WHEN w.precipitation <= 0.30 THEN 'Light/Mod Rain' -- Combined Trace/Dry up to 0.30 inches
    WHEN w.precipitation > 0.30 THEN 'Heavy Rain'
    ELSE 'Unknown'
  END AS weather_type
FROM weather_data w
JOIN taxi_data t ON w.date = t.date
ORDER BY w.date ASC;
