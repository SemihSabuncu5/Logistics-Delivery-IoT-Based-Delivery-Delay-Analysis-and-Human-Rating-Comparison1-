# Teslimat Süresi ve Kurye Değerlendirmesi – PostgreSQL Projesi

**Öğrenci no:** 202607131011 · **Kura:** #12 · **Program:** YZO

## İçerik
- `SCENARIO.md`: Atanan senaryo, problem, kullanıcı, tablo adayları ve kapsam.
- `data/raw/`: Orijinal CSV (değiştirilmeden saklanır).
- `data/processed/`: Temizlenmiş CSV.
- `data/README.md`: Veri kartı, kaynak/lisans ve temizleme notları.
- `sql/01_create_table.sql`: PostgreSQL tablo oluşturma.
- `sql/02_hafta-04.sql`: İlk SELECT/WHERE kontrolleri.
- `sql/03_hafta-05.sql`: Beş temel analiz sorgusu ve ek analizler.
- `AI_BEYAN.md`: Yapay zekâ kullanım beyanı.
- `docs/`: Tek sayfalık rapor.

## pgAdmin ile kurulum
1. `teslimat_projesi` veritabanını aç.
2. Query Tool'da `sql/01_create_table.sql` dosyasını açıp çalıştır.
3. Sol menüde `Schemas > public > Tables > deliveries_cleaned` tablosuna sağ tıkla.
4. **Import/Export Data** seç. Import seçili olsun.
5. Filename olarak `data/processed/deliveries_cleaned.csv` dosyasını seç.
6. Format CSV, Header açık, Delimiter `,`, Quote `"` ve Encoding `UTF8` olsun.
7. Import tamamlanınca `sql/02_hafta-04.sql` ve `sql/03_hafta-05.sql` dosyalarını Query Tool'da çalıştır.
8. Sorgu sonuçlarını kontrol et ve rapora gerçek PostgreSQL ekran görüntülerini eklemen gerekiyorsa kendi bilgisayarından al.

## Önemli kapsam notu
Atanan kura #12 senaryosu GPS/ivmeölçer, planlanan süre, sistem gecikme kararı ve insan değerlendirmesi uyumunu hedefler. Sağlanan CSV bunların yalnızca bir kısmını (konum koordinatları, gerçekleşen teslimat süresi, kurye puanı ve araç/çevre bilgileri) içerir. Dolayısıyla bu veriyle gecikme modeli ile insan puanlamasının uyumu ölçülemez. Bu teslim, mevcut dosya üzerinden dürüstçe hazırlanmış vize ön analizidir; tam senaryo uyumu için ek veri gerekir.

## Gereksinim
PostgreSQL 14+ önerilir. Ham CSV'yi asla elle düzenleme; temizleme işlemi ayrı dosyada tutulur.
