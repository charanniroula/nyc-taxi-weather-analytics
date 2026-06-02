# NYC Taxi Efficiency & Weather Impact Analytics

## What This Project Does
This project explores how weather conditions impact urban mobility and traffic efficiency across New York City, Central Park to be exact. By joining massive public datasets containing millions of row records for 2022 NYC Yellow Taxi trips and NOAA Central Park weather observations, I built an analytical model to measure traffic velocity changes across different levels of precipitation.

Instead of just looking at total ride counts, this analysis deep dives into true trip efficiency uncovering exactly how much city transit slows down when the weather turns by calculating a standardized velocity metric for every single day of the year.

## The Tech Stack & Data Sources
* **Google BigQuery:** Chosen to handle the heavy lifting. BigQuery allowed me to seamlessly query, filter, and join huge public datasets containing millions of rows of trip data without any performance lag.
* **2022 NYC Yellow Taxi Trip Data (`bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`):** Providing pickup/dropoff timestamps and trip distances.
* **NOAA Central Park Weather Data (`bigquery-public-data.noaa_gsod.gsod2022`):** Providing daily precipitation metrics for station `725060` (Central Park).
* **Tableau Public:** Used to transform the aggregated SQL layers into an interactive visual dashboard.

## Analytical Approach & SQL Logic
Messy real-world data requires careful engineering before it can reveal clean trends. Inside BigQuery, I applied several data-cleaning and optimization techniques using Common Table Expressions (CTEs):

1. **Engineering Travel Efficiency:** I created an `avg_min_per_mile` metric. First, I used `TIMESTAMP_DIFF` to find the exact duration of each trip in seconds, converted it to minutes, and then divided it by the `trip_distance`. This calculates true traffic velocity regardless of journey length.
2. **Data Cleaning & Outlier Removal:** To prevent skewed insights, I wrote conditional filtering clauses to eliminate incorrect data and extreme outliers. I strictly isolated trips that had a distance between 1 and 10 miles, and durations between 2 and 60 minutes because anything more than 10 miles would be outside Central Park. I didn't want durations under 1 minute and I also didn't want durations that are unusually long.
3. **Weather Categorization Modeling:** Because raw decimal numbers for precipitation doesn't look clean on a chart, I engineered a `CASE WHEN` block to categorize daily precipitation into four explicit operational states for Tableau: Clear, Trace/Dry (capturing low-moisture days), Moderate Rain, and Heavy Rain.

* *Code Location:* `sql/taxi_weather_analysis.sql`

## How It Works (The Analytical Workflow)
* **Step 1 (Weather Filtering):** Extracting 2022 daily data from the Central Park weather station, ensuring invalid precipitation placeholders (`99.99`) are completely omitted.
* **Step 2 (Taxi Aggregation):** Filtering down millions of trips to valid distances and times, calculating the daily average minutes per mile, and grouping by date.
* **Step 3 (The SQL Join):** Inner joining the weather metrics and taxi records together chronologically by date.

# Key Insights & Visual Design (Tableau)
I built the final dashboard to clearly contrast trip volume and travel efficiency by month and weather state. The analysis revealed three major business insights:

* **Weather Resilience:** The data shows surprising resilience to rainfall. Clear, Light/Mod Rain, and Heavy Rain all averaged roughly 6.12 minutes per mile, proving precipitation alone doesn't break city transit.
* **The Snow Contradiction:** Traffic velocity actually sped up during Snow/Sleet events (5.6 mins/mil). This counterintuitive trend suggests that most commuters stayed home, leaving the streets entirely clear for the few taxis out working.
* **Events > Weather (The Real Congestion Driver):** Major scheduled city events cause worse gridlock than any storm. A massive traffic slowdown in September (**6.8 mins/mile**) directly correlates with the UN General Assembly, proving a busy calendar is a bigger headache for drivers than a bad forecast.

[Click Here to View the Interactive Tableau Dashboard]
(https://public.tableau.com/app/profile/charan.niroula/viz/FinalProject_17781947359030/Dashboard1#1)
