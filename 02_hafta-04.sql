-- HAFTA 4: İlk SELECT / WHERE kontrolleri
-- Tablo pgAdmin üzerinden deliveries_cleaned.csv içeri aktarıldıktan sonra çalıştırılır.

-- 1) Veri setinin satır sayısı ve genel kapsamı
SELECT COUNT(*) AS total_deliveries
FROM public.deliveries_cleaned;

-- 2) İlk 20 teslimatı incele
SELECT *
FROM public.deliveries_cleaned
ORDER BY delivery_id
LIMIT 20;

-- 3) Eksik puanları kontrol et
SELECT
    COUNT(*) AS total_rows,
    COUNT(delivery_person_rating) AS rows_with_rating,
    COUNT(*) - COUNT(delivery_person_rating) AS missing_rating_rows
FROM public.deliveries_cleaned;

-- 4) Teslimat süresi 40 dakikadan uzun olan kayıtları incele
SELECT delivery_id, city, road_traffic_density, weather_conditions,
       type_of_vehicle, time_taken_min
FROM public.deliveries_cleaned
WHERE time_taken_min > 40
ORDER BY time_taken_min DESC
LIMIT 50;

-- 5) Geçerli sipariş zamanı ve mesafe hesaplanmış kayıtları kontrol et
SELECT delivery_id, order_datetime, pickup_datetime,
       order_to_pickup_min, straight_line_distance_km
FROM public.deliveries_cleaned
WHERE order_datetime IS NOT NULL
  AND straight_line_distance_km IS NOT NULL
LIMIT 30;
