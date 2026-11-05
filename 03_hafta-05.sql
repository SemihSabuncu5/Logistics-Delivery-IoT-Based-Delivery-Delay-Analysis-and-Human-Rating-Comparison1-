-- HAFTA 5: GROUP BY, NULL, tarih fonksiyonları ve CASE WHEN
-- Her sorgunun üstündeki açıklama; soruyu, beklenen sonucu ve yorum sınırını belirtir.
-- Önemli: Bu veri setinde planlanan süre ve sistemin gecikme kararı yoktur.
-- Bu nedenle aşağıdaki sorgular "gecikme" değil, gözlenen teslimat süresini analiz eder.

-- SORGU 1 | Trafik yoğunluğuna göre teslimat sayısı ve ortalama süre.
-- Soru: Trafik kategorileri arasında ortalama teslimat süresi farklı mı?
-- Beklenti: Jam/High gruplarında ortalamanın yükselmesi mümkündür; sonuç nedensellik kanıtı değildir.
SELECT
    road_traffic_density,
    COUNT(*) AS delivery_count,
    ROUND(AVG(time_taken_min)::numeric, 2) AS avg_delivery_min
FROM public.deliveries_cleaned
GROUP BY road_traffic_density
ORDER BY avg_delivery_min DESC;

-- SORGU 2 | NULL puanların sayısı ve oranı.
-- Soru: Kaç teslimatta kurye puanı eksik?
-- Beklenti: COUNT(*) tüm satırları, COUNT(rating) yalnızca puanlı satırları sayar.
-- Not: Puan müşteri/kurye değerlendirmesidir; gecikme kararına verilmiş ayrı bir insan etiketi değildir.
SELECT
    COUNT(*) AS total_deliveries,
    COUNT(delivery_person_rating) AS rated_deliveries,
    COUNT(*) - COUNT(delivery_person_rating) AS missing_ratings,
    ROUND(100.0 * (COUNT(*) - COUNT(delivery_person_rating)) / NULLIF(COUNT(*), 0), 2) AS missing_rating_pct
FROM public.deliveries_cleaned;

-- SORGU 3 | Araç türüne göre ortalama teslimat süresi; en az 100 kayıtlı türler.
-- Soru: Yeterli örnek sayısına sahip araç türlerinde ortalama süre nasıl değişiyor?
-- Beklenti: GROUP BY ve HAVING ile küçük örnekli gruplar dışarıda bırakılır.
SELECT
    type_of_vehicle,
    COUNT(*) AS delivery_count,
    ROUND(AVG(time_taken_min)::numeric, 2) AS avg_delivery_min
FROM public.deliveries_cleaned
GROUP BY type_of_vehicle
HAVING COUNT(*) >= 100
ORDER BY avg_delivery_min DESC;

-- SORGU 4 | Teslimat sürelerini CASE WHEN ile sınıflandır.
-- Soru: Kayıtlar 20 dakikanın altı, 20-35 dakika ve 35 dakikanın üstü gruplara nasıl dağılır?
-- Not: Bunlar analiz için süre bantlarıdır; planlanan süre bulunmadığından "gecikmiş" anlamına gelmez.
SELECT
    CASE
        WHEN time_taken_min < 20 THEN 'short (<20 min)'
        WHEN time_taken_min <= 35 THEN 'medium (20-35 min)'
        ELSE 'long (>35 min)'
    END AS duration_band,
    COUNT(*) AS delivery_count,
    ROUND(AVG(time_taken_min)::numeric, 2) AS avg_delivery_min
FROM public.deliveries_cleaned
GROUP BY duration_band
ORDER BY MIN(time_taken_min);

-- SORGU 5 | Sipariş saatine göre teslimat süresi.
-- Soru: Günün hangi saatlerinde ortalama teslimat süresi daha yüksek?
-- Beklenti: EXTRACT(HOUR) ile saat bazında gruplama yapılır.
-- Sınır: Hatalı/eksik sipariş saatleri NULL olduğu için bu sorguda dışarıda kalır.
SELECT
    EXTRACT(HOUR FROM order_datetime)::integer AS order_hour,
    COUNT(*) AS delivery_count,
    ROUND(AVG(time_taken_min)::numeric, 2) AS avg_delivery_min
FROM public.deliveries_cleaned
WHERE order_datetime IS NOT NULL
GROUP BY EXTRACT(HOUR FROM order_datetime)
ORDER BY order_hour;

-- EK ANALİZ | Trafik ve hava koşullarını birlikte incele.
SELECT
    weather_conditions,
    road_traffic_density,
    COUNT(*) AS delivery_count,
    ROUND(AVG(time_taken_min)::numeric, 2) AS avg_delivery_min
FROM public.deliveries_cleaned
GROUP BY weather_conditions, road_traffic_density
HAVING COUNT(*) >= 50
ORDER BY avg_delivery_min DESC;

-- EK ANALİZ | Koordinatlardan hesaplanan kuş uçuşu mesafeye göre süre.
-- Bu mesafe gerçek yol rotası değildir; GPS sensör örneklemi veya ivmeölçer verisi değildir.
SELECT
    CASE
        WHEN straight_line_distance_km < 5 THEN 'under 5 km'
        WHEN straight_line_distance_km < 10 THEN '5-10 km'
        WHEN straight_line_distance_km < 20 THEN '10-20 km'
        ELSE '20+ km'
    END AS distance_band,
    COUNT(*) AS delivery_count,
    ROUND(AVG(time_taken_min)::numeric, 2) AS avg_delivery_min
FROM public.deliveries_cleaned
WHERE straight_line_distance_km IS NOT NULL
GROUP BY distance_band
ORDER BY MIN(straight_line_distance_km);
