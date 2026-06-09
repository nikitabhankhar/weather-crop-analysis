use weather_crop;


SELECT 
    w.City, 
    w.Timestamp, 
    w.Temp_Actual, 
    w.Humidity, 
    m.Primary_Crop
FROM dbo.enriched_weather_crop_data w
INNER JOIN dbo.city_crop_mapping m ON w.City = m.City;



SELECT 
    Crop_Name, 
    Ideal_Temp_Min, 
    Ideal_Temp_Max, 
    Round(Crop_Factor_Kc,1) as Crop_factor_Kc
FROM dbo.crop_thresholds;



SELECT  w.City, w.Timestamp,m.Primary_Crop,w.Temp_Actual,t.Ideal_Temp_Min,t.Ideal_Temp_Max,
 CASE WHEN w.Temp_Actual < t.Ideal_Temp_Min THEN 'Cold Stress'
      WHEN w.Temp_Actual > t.Ideal_Temp_Max THEN 'Heat Stress'
      ELSE 'Optimal'
END AS Stress_Status
FROM dbo.enriched_weather_crop_data w
INNER JOIN dbo.city_crop_mapping m ON w.City = m.City
INNER JOIN dbo.crop_thresholds t ON m.Primary_Crop = t.Crop_Name;



SELECT m.Primary_Crop, 
    ROUND(AVG(w.Temp_Actual), 2) AS Avg_Temperature, 
    ROUND(AVG(t.Crop_Factor_Kc * w.Temp_Actual * (100 - w.Humidity) / 100), 2) AS Avg_Water_Demand
FROM dbo.enriched_weather_crop_data w
INNER JOIN dbo.city_crop_mapping m ON w.City = m.City
INNER JOIN dbo.crop_thresholds t ON m.Primary_Crop = t.Crop_Name
GROUP BY m.Primary_Crop
ORDER BY Avg_Water_Demand DESC;



SELECT w.City, m.Primary_Crop, 
COUNT(*) AS Total_Urgent_Alerts
FROM dbo.enriched_weather_crop_data w
INNER JOIN dbo.city_crop_mapping m ON w.City = m.City
INNER JOIN dbo.crop_thresholds t ON m.Primary_Crop = t.Crop_Name
WHERE (t.Crop_Factor_Kc * w.Temp_Actual * (100 - w.Humidity) / 100) > 5.0
  AND w.Precipitation = 0
GROUP BY w.City, m.Primary_Crop
ORDER BY Total_Urgent_Alerts DESC;
