# Cryptogram

Godot 4.3+ ve GDScript ile hazırlanmış, Android odaklı dikey bulmaca oyunu. Referans tasarımdaki kırık beyaz, lacivert ve yumuşak mavi renkler; yuvarlak kartlar ve hafif gölgeler kullanılır. Arayüz Godot Control düğümlerinden oluşur; ek eklenti gerekmez.

## Çalıştırma

1. Godot 4.3 veya daha yeni bir Godot 4 sürümünü açın (standart sürüm yeterlidir).
2. **Import** ile bu klasördeki `project.godot` dosyasını seçin.
3. **F6 yerine F5** ile ana projeyi çalıştırın.

Tasarım alanı 480 × 854'tür. Pencere farklı boyutlarda ölçeklenir, küçük/yatay ekranlarda içerik kaydırılabilir. Android geri düğmesi ana ekrana döner.

## Kullanım

- Ana ekrandan dil seçin. Arayüz, klavye, bulmaca havuzu ve ilerleme birlikte değişir.
- **Oyuna Başla** ilk tamamlanmamış normal bulmacayı veya kaldığınız kaydı açar.
- Numaralı bir kutuya ve ardından klavyeden bir harfe dokunun. Aynı sayının tüm tekrarları birlikte açılır. Yanlış harfler kabul edilmez, hata sayacı artar; deneme sınırı yoktur.
- **Harf Aç** seçilen sayıyı çözer; bulmaca başına üç kullanım vardır. Açılan harf silinemez.
- **İpucu** bulmacanın konusunu gösterir; ücretsizdir. **Temizle** seçilen sayının oyuncu tarafından girilmiş harfini siler.
- Normal seviyeler sırayla açılır. Çözülen seviyeler yeniden oynanmak yerine tamamlanmış kayıt olarak görüntülenir.
- Günlük bulmaca cihazın yerel tarihinden seçilir ve normal seviyelerden ayrı kaydedilir. İlk sürümde üç günlük dönüşümlü yerel havuz kullanılır; çevrimiçi günlük içerik servisi yoktur.
- İstatistikler seçili dilin normal tamamlanan seviyelerini ve tüm modlardaki hatalarını gösterir.

Her giriş, silme ve harf açma işleminde ilerleme `user://progress.json` dosyasına kaydedilir. Masaüstünde Godot editöründeki **Project > Open User Data Folder** ile bulunabilir. Dil seçimi de saklanır.

## Dosya yapısı

| Dosya | Görev |
| --- | --- |
| `scenes/main.tscn` | Ana sahne |
| `scripts/main.gd` | Ekranlar, bileşenler ve gezinme |
| `scripts/puzzle.gd` | Arayüzden bağımsız şifre çözme motoru |
| `scripts/languages.gd` | Dil kataloğu, metinler ve alfabeler |
| `scripts/progress.gd` | Dil bazında yerel kayıt |
| `assets/mark.svg` | Vektör kilit ve harf amblemi |
| `data/{tr,en,de,fr,es}.json` | Dilin arayüzü, klavyesi ve özgün bulmacaları |
| `tests/test_puzzle.gd` | Motor ve içerik kontrolleri |

Her dilde 100 ayrı bulmaca bulunur. İlk altı cümle veri dosyalarında tutulur; kalan cümleler dilin özgün kelime havuzlarından çalışma zamanında benzersiz kimliklerle genişletilir. Havuzlar aynı cümlelerin birebir çevirilerinden oluşmaz. Fransızca ve İspanyolcada aksanlı harfler klavyede ayrı tuşlardır; Türkçede I/İ ayrımı korunur. Yeni bulmacayı ilgili JSON dosyasının `puzzles` listesine benzersiz `id`, büyük harfli `text` ve `topic` ile ekleyin. Mevcut kayıtların korunması için yayınlanmış bulmacaların kimliklerini ve metinlerini değiştirmeyin.

## Kontroller

Godot yürütülebilir dosyasını PATH'e ekledikten sonra:

```powershell
godot --headless --path . --editor --quit
godot --headless --path . --script tests/test_puzzle.gd
godot --headless --path . tests/test_ui.tscn
godot --path .
```

## Android

Godot sürümünüzle eşleşen export template'lerini kurun. Godot Android dışa aktarma ayarlarında Android SDK ve JDK yollarını tanımlayın. **Project > Export > Add > Android** üzerinden bir preset oluşturup paket kimliğini belirleyin ve debug APK alın. Proje portrait ve GL Compatibility kullanır. Yayın için kendi release imzanızı yapılandırın; anahtarları depoya eklemeyin.

Bu sürüm yerel oynanabilir prototiptir. APK veya mağaza yayını içermez. Ses, para birimi, reklam, satın alma ve başarımlar henüz uygulanmamıştır. Günlük içerik ve seviye havuzları üretim öncesi genişletilmelidir.
