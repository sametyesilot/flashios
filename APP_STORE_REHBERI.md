# Lumora — App Store'a Yükleme Rehberi

Bu klasörde App Store'a çıkmak için gereken her şey var. Aşağıdaki adımları sırayla izle.

## 0. Klasörde ne var?

| Dosya / Klasör | Ne işe yarar |
|---|---|
| `Lumora.xcodeproj` | Xcode projesi (çift tıkla, açılır) |
| `Lumora/` | Swift kaynak kodu, ikon, 34 dilde çeviri (`Localizable.xcstrings`) |
| `Lumora/AppConfig.swift` | **Tek ayar dosyası**: Product ID, gizlilik linki, ücretsiz hak sayısı |
| `Lumora.storekit` | Xcode içinde gerçek para harcamadan satın almayı test etmek için |
| `screenshots/appstore/` | Mağaza ekran görüntüleri, 6.9" (1320×2868), İngilizce ve Türkçe |
| `fastlane/metadata/` | 39 dil için ad, alt başlık, anahtar kelime, açıklama ve tanıtım metni |
| `fastlane/metadata/review_information/notes.txt` | Apple inceleme ekibine yazılacak not |
| `docs/privacy.html`, `docs/support.html` | Gizlilik ve destek sayfaları (GitHub Pages'te yayınlanacak) |
| `tools/` | İkon, çeviri, ekran görüntüsü ve metin üreten scriptler |
| `project.yml` | XcodeGen proje tanımı (`xcodegen generate` ile projeyi yeniden üretir) |

**Harici UI kütüphanesi yok.** En premium ve en akıcı sonucu native SwiftUI, StoreKit 2 ve AVFoundation veriyor. Bağımlılık olmaması inceleme ve bakım açısından da avantaj.

---

## 1. Uygulamanın mantığı

- **Tek ekran, tek işlev:** ortada büyük güç butonu, altta 5 tema noktası, sağ üstte PRO rozeti.
- **İlk açış ücretsiz.** Kapatmak **her zaman** serbest.
- **İkinci açışta** abonelik ekranı (aylık 1,99 $) çıkar. X ile her zaman kapatılabilir; bu, Apple'ın zorunlu tuttuğu bir kural.
- Satın alınca ışık otomatik açılır ve 4 premium tema (Aurora, Ember, Glacier, Aurum) kilidi kalkar.
- Ücretsiz hak Keychain'de tutulur, uygulama silinip yeniden yüklense de sıfırlanmaz.
- Hakkı değiştirmek istersen `AppConfig.freeTurnOns = 1` değerini düzenle.

---

## 2. Tüm cihazlarda görünüm

| Cihaz | Görünüm |
|---|---|
| **iPhone 17 Pro Max / 16 Plus / Air (6.7–6.9")** | Buton yaklaşık 270 pt, geniş ışık patlaması; ekran görüntüleri bu boyutta alındı. |
| **iPhone 17 / 17 Pro / 16 (6.1–6.3")** | Buton ekran genişliğinin %62'si (≈245 pt), düzen aynı oranlarda. |
| **iPhone 16e / SE (4.7–6.1")** | Buton en az 200 pt'ye küçülür; başlık, buton ve tema seçici esnek boşluklarla sığar. |
| **Dynamic Island / çentik** | İçerik güvenli alan (safe area) içinde, arka plan tüm ekranı kaplar. |
| **iPad** | Uygulama yalnızca iPhone için. Flaşı olan iPad Pro'larda iPhone uyumluluk modunda çalışır. |
| **Yatay mod** | Kapalı, uygulama yalnızca dikey çalışır (el feneri için doğal olan bu). |
| **Açık/koyu mod** | Uygulama her zaman koyu temada, karanlıkta göz yormaz. |
| **Arapça / İbranice** | Sağdan sola düzen otomatik çalışır (test edildi). |
| **Flaşı olmayan cihaz** | `camera-flash` gereksinimi nedeniyle App Store bu cihazlara yüklenmesine izin vermez. Yine de yüklenirse "Bu cihazda el feneri kullanılamıyor." yazar. |
| **VoiceOver** | Butonun etiketi "El feneri, Açık/Kapalı" şeklinde okunur. |

Haptic: her açma ve kapamada orta şiddette titreşim. Animasyonlar: yay (spring) efektli basma, nefes alan ışık halkası ve yumuşak tema geçişleri.

---

## 3. Yayına hazırlık (sırayla)

### 3.1 Apple Developer hesabı
1. https://developer.apple.com/programs/ adresinden kaydol (99 $/yıl). Onay genelde 1–2 gün sürer.
2. App Store Connect'te **Anlaşmalar, Vergi ve Bankacılık** bölümünden **Ücretli Uygulamalar** sözleşmesini imzala, banka ve vergi bilgilerini gir. **Bu adım tamamlanmadan abonelik çalışmaz.**

### 3.2 Bundle ID ve imzalama ✅ (yapıldı)
- Team `KVT7JK9UBR` projeye bağlandı, imzalı Archive başarıyla alındı.
- Bundle ID `com.lumora.flashlight`. **developer.apple.com → Certificates, IDs & Profiles → Identifiers → +** bölümünden bu ID'yi kaydet (App IDs → App → Explicit). "Already taken" hatası alırsan bana söyle, ID'yi birlikte değiştirelim.
- In-App Purchase özelliği App ID'lerde varsayılan olarak açık gelir.

### 3.3 Gizlilik linki ✅ (yayında)
- Gizlilik: https://sametyesilot.github.io/flashios/privacy.html
- Destek: https://sametyesilot.github.io/flashios/support.html
- Kod: https://github.com/sametyesilot/flashios (Pages, `docs/` klasöründen yayınlanıyor)

### 3.4 App Store Connect'te uygulama
1. **Uygulamalar → + → Yeni Uygulama**: Platform iOS, Ad "Lumora: Flashlight" (alınmışsa "Lumora – Flashlight Pro" gibi bir varyasyon dene), birincil dil English (U.S.), Bundle ID, SKU `lumora001`.
2. **Kategori:** Utilities (ikincil: Productivity).
3. **Yaş sınırı:** anketin hepsine "Hayır" de, sonuç 4+ olur.
4. **App Privacy:** "Data Not Collected" (Veri Toplanmıyor) seç.
5. **Fiyat:** Ücretsiz (gelir abonelikten geliyor).

### 3.5 Abonelik
1. **Monetization → Subscriptions → Subscription Group** oluştur: `Lumora Pro`.
2. Abonelik ekle:
   - Reference Name: `Lumora Pro Monthly`
   - Product ID: `com.lumora.flashlight.pro.monthly` (AppConfig ile birebir aynı olmalı)
   - Süre: 1 Ay
   - Fiyat: **1,99 USD** (Apple diğer ülkeler için yerel fiyatları otomatik ayarlar; Türkiye'yi istersen elle değiştirebilirsin)
   - Localization: Display Name "Lumora Pro", Description "Unlimited light and all 5 premium themes." (Türkçe: "Sınırsız ışık ve 5 premium temanın tamamı.")
   - **Review Screenshot:** `screenshots/raw/en_6_paywall.png` dosyasını yükle.
3. Aboneliğin durumu "Ready to Submit" olmalı. **İlk sürümde abonelik, uygulamanın sayfasındaki "In-App Purchases and Subscriptions" bölümünden seçilip birlikte gönderilmelidir.** En sık yapılan hata budur.

### 3.6 Metinler ve ekran görüntüleri
- **Elle:** `fastlane/metadata/<dil>/` klasörlerindeki metinleri App Store Connect'te ilgili dile kopyala. Ekran görüntüleri `screenshots/appstore/` klasöründe (6.9" ekran görüntüsü artık tek zorunlu iPhone boyutu).
- **Otomatik (önerilen, 39 dili tek seferde yükler):**
  ```bash
  brew install fastlane
  ```
  ```bash
  fastlane deliver --app_identifier com.lumora.flashlight --skip_binary_upload --force
  ```
  (İlk çalıştırmada Apple ID ile giriş ister.)
- İngilizce ve Türkçe dışındaki diller İngilizce ekran görüntülerini kullanır; bu Apple'da serbesttir.

### 3.7 Build gönderme (Xcode)
Archive hazır, Xcode'da **Window → Organizer → Archives** altında "Lumora 1.0.0 (1)" olarak duruyor.
1. Organizer'da Lumora'yı seç, **Distribute App** butonuna bas.
2. **App Store Connect** seçeneğini seç, ardından **Distribute** (Xcode imzalamayı ve profili otomatik halleder).
   - Yeniden archive almak istersen: üstten cihaz olarak **Any iOS Device (arm64)** seç, sonra **Product → Archive**.
   - Her yeni yüklemede **Build** numarasını artır (target → General → Build: 2, 3…).
3. 10–30 dakika içinde build App Store Connect'te görünür. Sürüm sayfasında onu seç.
4. **App Review Information** alanına `fastlane/metadata/review_information/notes.txt` içeriğini yapıştır. Demo hesap gerekmez.
5. **Submit for Review**.

---

## 4. Süreler (gerçekçi plan)

| Aşama | Süre |
|---|---|
| Developer hesabı onayı | 1–2 gün (ilk kez açıyorsan) |
| Sözleşme, banka ve vergi | Aynı gün, onay birkaç saat ile 1 gün |
| Archive ve yükleme | 1 saat |
| **App Review** | **Genelde 24–48 saat** |
| Olası ret ve tekrar gönderim | Her tur +1–2 gün |
| **Para hesaba geçişi** | Apple, satış yapılan mali ay bitiminden yaklaşık 33 gün sonra öder |

> Video serisi için not: 1 hafta içinde App Store Connect'te kazanılan geliri görebilirsin, ama banka hesabına geçmesi en erken bir sonraki ay olur. Apple küçük geliştiricilerde %15 komisyon alır (Small Business Program'a başvurmalısın). Yani 1,99 $'lık bir abonelikten eline yaklaşık 1,69 $ kalır. 10.000 TL için kabaca **150+ aktif abone** gerekir.

---

## 5. Olası ret sebepleri ve hazır cevaplar

| Ret | Ne yapmalı |
|---|---|
| **4.3 Spam** ("çok fazla flaş uygulaması var") | Notta tasarım, 5 tema ve abonelik değerini vurgula. Resolution Center'da: "Lumora offers a distinct premium design system with 5 handcrafted themes, haptics and accessibility support." Gerekirse ekran görüntülerini yenile. |
| **3.1.2 Abonelik bilgisi eksik** | Açıklamada EULA ve gizlilik linkleri var; App Store Connect'teki **Privacy Policy URL** alanının dolu olduğundan emin ol. |
| **2.1 Abonelik yüklenemedi** | Ücretli Uygulamalar sözleşmesi aktif mi, abonelik build ile birlikte gönderildi mi? |
| **5.1.1 İzin** | Kamera izni istenmiyor; sorun çıkmaz. |

---

## 6. Test etme

- **Simülatörde:** Xcode'da ▶︎ ile çalıştır. `Lumora.storekit` sayesinde satın alma ekranı sahte para ile çalışır.
- **Gerçek iPhone'da:** kabloyla bağla, Team'i seç ve ▶︎. Flaş gerçekten yanar.
- **Sandbox test:** App Store Connect → Users and Access → Sandbox Testers bölümünden test hesabı aç ve TestFlight build'i ile dene.
- **Ücretsiz hakkı sıfırlamak (yalnızca Debug):** Scheme → Arguments'a `-resetFree` ekle.
- **Ekran görüntüsü demo argümanları (yalnızca Debug):** `-demoOn`, `-demoPro`, `-showPaywall`, `-demoPrice '$1.99'`, `-themeID aurora`

Yeniden üretme komutları:
```bash
python3 tools/make_icon.py Lumora/Assets.xcassets/AppIcon.appiconset
```
```bash
python3 tools/make_strings.py Lumora/Localizable.xcstrings
```
```bash
python3 tools/make_metadata.py
```
```bash
python3 tools/make_marketing.py
```
