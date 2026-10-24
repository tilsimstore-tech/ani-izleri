# Bebeğimin Anı İzleri — Yayın Kılavuzu

Bu dosya uygulamanın Android ve iOS yayın sürecini ve güncel durumunu tutar.
**Her sürümden sonra "Güncel Durum" ve "Sürüm Geçmişi" bölümleri güncellenir.**

> Bu dosyaya şifre, anahtar veya `.p8` içeriği YAZILMAZ.
> Gizli dosyalar yalnızca bilgisayarda: `C:\Users\semih\ani_izleri_ios_gizli\` (ayrıntılar `BILGILER.txt` içinde)
> Android imza dosyaları: `android/key.properties` + `android/tilsim-keystore.jks` (git'e girmez)

---

## Güncel Durum

| | Android | iOS |
|---|---|---|
| Mağazada yayında olan | 1.0.0 (6) — ₺249,99 | — (henüz yayında değil) |
| Son yüklenen derleme | 1.0.0 (6) | 1.0.0 (7) |
| Durum | Yayında | **24.10.2026'da App Review'a gönderildi** (Waiting for Review), onaylanınca otomatik yayın |

**iOS hesap/iş durumu (24.10.2026):**
- Fiyat ₺499,99, 175 ülke; kategori Yaşam Tarzı / Fotoğraf ve Video; yaş 4+; "Veri toplanmıyor"
- Paid Apps sözleşmesi kabul edildi; banka (Ziraat, TRY) işleniyor → sonra sözleşme Active olur
- W-8BEN aktif (Article 7 §1, %0, income from the sale of applications)
- AB tüccar (DSA) beyanı incelemede — adres: Akgedik Mah. Akgedik Cad. No:544 İç Kapı No:8, Yunusemre/Manisa
- Small Business Program başvurusu yapıldı (%15 komisyon)
- Not: hesaptaki yasal kimlik adresi "no4" olarak kayıtlı; gerekirse Apple Developer Support'tan düzeltilmeli
- Ekran görüntüleri: 1206×2622 (6.3" iPhone), kaynak `Masaüstü\Yeni klasör\Dağıtım\appstore_ekran`
- Promo kodu: uygulama yayına girince App Store Connect → Promo Codes (tek kullanımlık, 4 hafta geçerli, satılamaz)

---

## Sabit Bilgiler

| | |
|---|---|
| GitHub | github.com/tilsimstore-tech/ani-izleri — **dal: `master`** (`main` dalı kullanılmıyor) |
| Proje klasörü | `C:\ani_izleriv1` |
| Uygulama adı | Bebeğimin Anı İzleri |
| Bundle ID / Package | `store.tilsim.aniIzleri` |
| Apple Team ID | ASM3K355UM |
| App Store Connect App ID | 6826564681 |
| iOS | Yalnızca iPhone, minimum iOS 15.0 |
| iOS derleme | Codemagic (Mac gerekmez), iş akışı: **iOS Release (App Store)** |

---

## Android Güncelleme Adımları

1. Kodu değiştir, test et.
2. `pubspec.yaml` içindeki `version:` değerini artır (ör. `1.0.1+7`).
   - `+` sonrası sayı her yüklemede artmalı.
3. Derle: `flutter build appbundle --release`
4. `build/app/outputs/bundle/release/app-release.aab` dosyasını Play Console'a yükle.
5. Değişiklikleri GitHub'a gönder (`master`).
6. Bu dosyada "Güncel Durum" ve "Sürüm Geçmişi"ni güncelle.

> GitHub'a göndermek iOS derlemesi BAŞLATMAZ. iOS yalnızca Codemagic'te elle başlatılır.

## iOS Güncelleme Adımları

1. Değişiklikler `master` dalında ve GitHub'a gönderilmiş olmalı.
2. `pubspec.yaml` içindeki sürüm adını (`1.0.1` kısmı) istersen artır.
   - iOS derleme numarası Codemagic'te otomatik artar (Codemagic derleme no + 6).
3. codemagic.io → ani-izleri → **Start new build** → dal `master` → **iOS Release (App Store)**.
4. ~10 dk sonra derleme TestFlight'a düşer; Apple işlemesi 10–30 dk sürer.
   - Codemagic sonunda kırmızı X verip logda **"UPLOAD SUCCEEDED"** yazıyorsa yükleme başarılıdır; Apple'ın geçici 500 hatasıdır.
5. TestFlight'ta (Aile grubu) telefondan dene.
6. App Store Connect → Distribution → yeni sürüm → derlemeyi seç → **İncelemeye Gönder**.
7. Bu dosyayı güncelle.

## Sadece Bir Platforma Özel Değişiklik

- Kod içinde: `import 'dart:io';` ve `if (Platform.isAndroid) { ... }` / `if (Platform.isIOS) { ... }`
- Diğer platformu yeni sürüme hiç geçirmemek gerekirse: o platform için ayrı dal açılır (ör. `ios-release`) ve Codemagic o daldan derlenir.

## Sorun Giderme

| Sorun | Çözüm |
|---|---|
| Codemagic imzalama hatası | `appstore_credentials` grubundaki 4 değişken duruyor mu kontrol et (Codemagic → Environment variables) |
| API anahtarı iptal edildi | App Store Connect → Users and Access → Integrations'tan yeni anahtar oluştur, Codemagic'teki 3 APP_STORE_CONNECT_* değişkenini güncelle |
| "Deployment target" uyarısı | Minimum iOS 15.0'a ayarlandı (Nisan 2027 kuralı) |
| Apple yeni sözleşme istiyor | developer.apple.com/account'ta hesap sahibi kabul etmeli; yoksa yükleme yapılamaz |

---

## Sürüm Geçmişi

En yeni en üstte. Her sürümde: tarih, platform, sürüm, ne değişti.

### 2026-10-24 — iOS 1.0.0 (7) — App Review'a gönderildi
- Mağaza sayfası dolduruldu (metinler `MAGAZA_METINLERI.md`), 6 ekran görüntüsü, ₺499,99, 175 ülke.

### 2026-10-24 — iOS 1.0.0 (7) — TestFlight
- İlk iOS derlemesi Codemagic ile oluşturuldu, TestFlight'a yüklendi ve iPhone'da çalıştı.
- iOS yalnızca iPhone olarak ayarlandı, şifreleme beyanı (`ITSAppUsesNonExemptEncryption=false`) eklendi.
- Minimum iOS 13.0 → 15.0 (bir sonraki iOS derlemesinde geçerli).

### Android 1.0.0 (6) — Play Store
- Uygulama adı "Bebeğimin Anı İzleri" oldu.
- PDF servisi, soy ağacı, ana ekran ve sayfa editörü güncellemeleri.
