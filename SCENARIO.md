# SCENARIO.md
## Öğrenci / proje bilgileri
- Öğrenci numarası: 202607131011
- Kura: #12
- Program: YZO
- Atanan alan: Lojistik ve teslimat
- Atanan sistem: IoT sensör ağı
- Atanan YZ dokunuşu: İnsan geri bildirimi ve puanlama

## Senaryo (öğretim elemanının ataması)
Bir kurye şirketi araçlara takılan GPS ve ivmeölçer sensörlerinden gelen veriyle teslimat sürelerini izler. Operasyon ekibi, sistemin "gecikmiş teslimat" olarak işaretlediği olayları sürücülerin ve yöneticilerin puanlamasıyla karşılaştırmak ister.

**Ana soru:** Sistemin gecikme işareti insan puanlamasıyla ne ölçüde örtüşüyor?

## Kullanılan veri seti ve uyumluluk değerlendirmesi
Bu çalışma için kullanıcı tarafından sağlanan `Zomato Dataset.csv` kullanılmıştır. Dosya 45.584 satır ve 20 orijinal sütun içerir. Veri setinde kurye kimliği, sipariş ve teslimat konum koordinatları, sipariş/paket alma saatleri, trafik, hava, araç türü/durumu, teslimat süresi ve kurye puanı bulunur.

Veri, atanan senaryoya **kısmen** uygundur:
- GPS benzeri konum alanları vardır (restoran ve teslimat koordinatları).
- Teslimat süresi, araç durumu, trafik ve hava koşulları vardır.
- Kurye puanı vardır; ancak bu puanın gecikme tespit sistemine verilmiş bir insan doğrulama etiketi olduğu gösterilmemiştir.
- Gerçek ivmeölçer/telemetri örnekleri, planlanan teslimat süresi, sistemin gecikme bayrağı ve gecikme kararına ait sürücü/yönetici değerlendirmesi yoktur.

Bu nedenle mevcut veriyle sistem-karar/insan-puan uyumu ölçülemez. Bu proje, vize aşamasında mevcut verinin sınırları içinde teslimat süresi ve mevcut kurye puanını inceleyen **ön analiz** olarak hazırlanmıştır. Eksik alanlar yapay/sentetik veriyle doldurulmamıştır. Tam senaryo uyumu için ayrıca gerçek telemetri, planlanan süre, model gecikme bayrağı ve insan değerlendirme verisi gereklidir.

## Tablo adayları (senaryo için)
1. `deliveries(delivery_id, delivery_person_id, order_datetime, pickup_datetime, planned_duration_min, actual_duration_min, vehicle_id)`
2. `sensor_summaries(delivery_id, avg_speed, max_acceleration, gps_distance_km, measured_at)`
3. `ratings(delivery_id, rater_role, score_1_5, rated_at)`
4. `delay_predictions(delivery_id, model_version, is_delayed, predicted_at)`

Yukarıdaki şema senaryonun hedef veri modelidir; mevcut CSV bu tabloların tamamını sağlamaz. Mevcut CSV'nin yüklenen hali `public.deliveries_cleaned` tablosunda tutulur.

## Hedef kullanıcı
Kurye operasyon yöneticisi ve veri analisti.

## Veri kaynağı ve asgari gereksinim
- Kaynak: Kullanıcının sağladığı ZIP arşivindeki `Zomato Dataset.csv`.
- Satır sayısı: 45.584 (500 satır asgari şartını karşılar).
- Orijinal sütun: 20.
- Veri dönemi: 2022-02-11 – 2022-04-06.
- Dış kaynak URL'si, özgün yayıncı ve lisans bilgisi ZIP içinde yer almadığından doğrulanamamıştır. Kaynak/lisans bilgisi öğretim elemanına sunulmadan önce veri setinin asıl yayın sayfasından teyit edilmelidir.

## Araştırma soruları (mevcut alanlarla)
1. Trafik yoğunluğuna göre ortalama teslimat süresi nasıl değişir?
2. Hava koşulları ve araç türü teslimat süresiyle nasıl ilişkilidir?
3. Kurye puanı hangi oranda eksiktir ve puanlı kayıtların dağılımı nasıldır?
4. Konum koordinatlarından hesaplanan kuş uçuşu mesafe ile teslimat süresi arasında nasıl bir ilişki vardır?
5. Sipariş saatine göre ortalama teslimat süresi değişir mi?

## Yöntem ve sınırlar
- Ham CSV değiştirilmeden `data/raw/` altında saklanır.
- Temizlenmiş kopya `data/processed/` altındadır.
- Tarih `DD-MM-YYYY` formatından parse edilir.
- Zaman alanlarında görülen gün kesri biçimindeki değerler saat/dakikaya dönüştürülür; çözümlenemeyen saatler NULL bırakılır.
- 1–5 aralığı dışındaki kurye puanları NULL yapılır.
- Koordinatlardan Haversine formülüyle kuş uçuşu mesafe hesaplanır. Bu, gerçek yol mesafesi değildir.
- Eksik değerler otomatik ortalama ile doldurulmaz.
- `Time_taken (min)` gerçekleşen süre olarak ele alınır; planlanan süre olmadığından gecikme miktarı hesaplanmaz.
