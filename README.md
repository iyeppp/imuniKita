# ImuniKita

Aplikasi mobile pemantau **imunisasi** dan **tumbuh kembang anak** (Flutter).
Fase UTS menyimpan seluruh data **secara lokal di perangkat** (Hive CE) tanpa
backend; fase UAS direncanakan memakai Firebase/Firestore tanpa menulis ulang UI
(lihat `progress_context/ImuniKita_Dev_Plan_220926.md`).

## Fitur utama

| Fitur | Ringkasan |
|-------|-----------|
| Auth & Onboarding | Splash, onboarding, register/login lokal, sesi di `SharedPreferences` |
| Profil anak | Tambah/ubah/hapus profil bayi, foto profil, **bayi aktif** (anak ke-2 dst.) |
| Imunisasi | 13 jadwal nasional dibuat otomatis, Kalender (marker status), Timeline, Detail + catatan KIPI |
| Pengingat | Notifikasi lokal **H-7 & H-1** (`flutter_local_notifications`), dapat dimatikan/dinyalakan |
| Pertumbuhan | Grafik berat/tinggi/lingkar kepala (`fl_chart`) + referensi median WHO |
| Jurnal kesehatan | Catatan harian, suhu tubuh, gejala, tautan ke jadwal vaksin |
| Edukasi | Artikel, video, dan kuis dengan filter kategori |
| Direktori Faskes | 14 faskes mock + peta OpenStreetMap, tombol telepon/navigasi |
| ImuniBot | Chatbot rule-based (mock, tanpa backend) |

## Prasyarat

- Flutter SDK **stable** (Dart `^3.13.2` — lihat `environment` di `pubspec.yaml`)
- JDK **17** (wajib untuk desugaring `flutter_local_notifications`)
- Android SDK (compileSdk/targetSdk mengikuti versi Flutter)

## Menjalankan

```bash
flutter pub get
flutter run
```

Kode hasil generator Hive (`*.g.dart`, `hive_registrar.g.dart`) sudah di-commit.
Bila mengubah model Hive (`@HiveType`/`@HiveField`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

> Catatan: `build_runner` berbagi cache dengan `hive_ce_generator`; jalankan
> perintah di atas hanya saat model berubah, bukan setiap kali run.

## Kualitas kode

```bash
flutter analyze          # target: No issues found!
flutter test             # seluruh unit/widget test
flutter build apk --debug
```

CI di `.github/workflows/ci.yaml` menjalankan `flutter analyze` + `flutter test`
pada setiap push/PR ke `main` dan `yeppp`.

## Release (Android)

Build rilis **butuh keystore milik tim** (tidak di-commit):

1. Buat keystore:
   ```bash
   keytool -genkey -v -keystore imunikita-release.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias imunikita
   ```
2. Buat `android/key.properties` (sudah masuk `.gitignore`):
   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=imunikita
   storeFile=/path/absolut/ke/imunikita-release.jks
   ```
3. `flutter build apk --release` (atau `--appbundle`).

Tanpa `key.properties`, build rilis tetap berjalan memakai **debug key** — hanya
untuk keperluan uji, **bukan untuk distribusi**.

## Struktur singkat

```
lib/
├─ app/           # router (GoRouter), theme (warna/tipografi)
├─ core/          # konstanta, service (Hive/sesi/notifikasi), util
├─ features/
│  ├─ auth/       # onboarding, login/register, profil & pengaturan
│  ├─ baby_profile/
│  ├─ immunization/
│  ├─ growth/
│  ├─ health_journal/
│  ├─ education/
│  ├─ faskes/
│  └─ chatbot/
└─ widgets/       # 10 komponen UI global
```

Tiap fitur mengikuti pola **Clean Architecture** ringan:
`data/` (model Hive, datasource, repository impl) → `domain/` (entity, kontrak
repository, use case) → `presentation/` (provider Riverpod, screen, widget).
Detail arsitektur dan status per sprint ada di `progress_context/`.

## Catatan implementasi penting

- **Notifikasi**: pengingat dijadwalkan di level OS (`zonedSchedule`). Bila izin
  *exact alarm* ditolak (umum di Android 12+), aplikasi otomatis memakai mode
  *inexact* agar pengingat tetap terkirim. WorkManager **tidak** dipakai — status
  `TERLEWAT` dihitung saat data dibaca (`VaccineStatus.effective`).
- **`html` di-pin ke 0.15.6** lewat `dependency_overrides` karena `flutter_html`
  3.0.0 belum kompatibel dengan `html` ≥ 0.15.7. Jangan hapus pin ini sebelum
  upstream diperbaiki.
- **Data demo**: seluruh konten edukasi & faskes masih mock (hardcoded).

## Dokumen internal

Folder `progress_context/` (tidak di-track git) berisi dev plan, dokumen progress,
dan ketentuan UTS.
