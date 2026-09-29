# 👶 ImuniKita

**ImuniKita** adalah aplikasi mobile untuk memantau **imunisasi** dan **tumbuh kembang anak**.
Aplikasi ini membantu orang tua mengingat jadwal vaksin nasional, mencatat reaksi pasca
imunisasi (KIPI), memantau kurva pertumbuhan, hingga mencari fasilitas kesehatan terdekat.

> **Status proyek:** prototipe (fase UTS Praktikum Pemrograman Mobile).
> Seluruh data disimpan **offline di perangkat** (Hive CE) — **belum** memakai backend.
> Rencana fase berikutnya: sinkronisasi Firebase/Firestore tanpa menulis ulang UI.

[![CI](https://github.com/iyeppp/imuniKita/actions/workflows/ci.yaml/badge.svg)](https://github.com/iyeppp/imuniKita/actions/workflows/ci.yaml)
![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%5E3.13.2-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)

---

## 📑 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Teknologi](#-teknologi)
- [Prasyarat](#-prasyarat)
- [Setup & Menjalankan](#-setup--menjalankan)
- [Data Dummy & Data Bawaan](#-data-dummy--data-bawaan)
- [Skenario Simulasi Demo](#-skenario-simulasi-demo)
- [Struktur Proyek](#-struktur-proyek)
- [Catatan Implementasi](#-catatan-implementasi)
- [Troubleshooting](#-troubleshooting)

---

## ✨ Fitur Utama

| Fitur | Ringkasan |
|-------|-----------|
| **Autentikasi & Onboarding** | Splash, 3 slide onboarding, register/login lokal, sesi disimpan di `SharedPreferences` |
| **Profil Anak** | Tambah/ubah/hapus profil bayi (CRUD), foto profil, dukungan **bayi aktif** untuk anak ke-2 dst. |
| **Imunisasi** | 13 jadwal nasional dibuat otomatis saat anak didaftarkan; kalender ber-marker status, timeline, dan halaman detail + catatan KIPI |
| **Pengingat Otomatis** | Notifikasi lokal **H-7 & H-1** sebelum jadwal, dapat dinyalakan/dimatikan per akun |
| **Pertumbuhan** | Grafik berat/tinggi/lingkar kepala (`fl_chart`) dengan garis referensi median WHO |
| **Jurnal Kesehatan** | Catatan harian, suhu tubuh, gejala, dan tautan ke jadwal vaksin tertentu |
| **Edukasi** | Artikel, video, dan kuis interaktif dengan filter kategori |
| **Direktori Faskes** | Daftar faskes + peta OpenStreetMap, tombol telepon & navigasi |
| **ImuniBot** | Chatbot rule-based berbahasa Indonesia (mock, tanpa backend) |

---

## 🧰 Teknologi

| Kategori | Paket / Tools |
|----------|---------------|
| Bahasa & Framework | Dart, Flutter (stable) |
| State Management | `flutter_riverpod` |
| Navigasi | `go_router` |
| Database Lokal | `hive_ce` + `hive_ce_flutter` (code generation) |
| Notifikasi | `flutter_local_notifications` + `timezone` |
| Penyimpanan Sesi | `shared_preferences` |
| Charting | `fl_chart` |
| Kalender | `table_calendar` |
| Peta | `flutter_map` + `latlong2` (OpenStreetMap) |
| Konten HTML | `flutter_html` |
| Lain-lain | `uuid`, `intl`, `image_picker`, `url_launcher`, `share_plus`, `cached_network_image`, `google_fonts`, `package_info_plus` |
| Kualitas Kode | `flutter_lints`, `flutter_test`, GitHub Actions |

---

## 📋 Prasyarat

Pastikan hal-hal berikut sudah terpasang sebelum menjalankan proyek:

- **Flutter SDK** (channel **stable**) — Dart sesuai `environment` di `pubspec.yaml` (`^3.13.2`).
- **JDK 17** — wajib untuk *desugaring* `flutter_local_notifications`.
- **Android SDK** + Emulator Android 8.0+ (atau perangkat fisik). Compile/target SDK mengikuti versi Flutter.
- Untuk iOS: **Xcode** + CocoaPods (macOS saja).

Cek instalasi:

```bash
flutter --version
flutter doctor
```

---

## 🚀 Setup & Menjalankan

1. **Clone repositori**

   ```bash
   git clone https://github.com/iyeppp/imuniKita.git
   cd imuniKita
   ```

2. **Pasang dependensi**

   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**

   ```bash
   flutter run
   ```

   Pilih perangkat saat diminta, atau tentukan langsung:

   ```bash
   flutter devices
   flutter run -d <device_id>
   ```

Kode hasil generator Hive (`*.g.dart`, `hive_registrar.g.dart`) **sudah ikut di-commit**,
jadi langkah code generation **tidak diperlukan** hanya untuk menjalankan aplikasi.

---

## 🧸 Data Dummy & Data Bawaan

Aplikasi ini **tidak menyediakan akun bawaan** (tidak ada seeding otomatis). Saat pertama
kali dijalankan, Anda memulai dari keadaan bersih lalu membuat akun & data sendiri lewat
alur registrasi. Hal ini disengaja agar data demo benar-benar tersimpan di perangkat Anda.

### 1. Data master & konten bawaan (hardcoded)

Data berikut sudah tersedia di aplikasi tanpa perlu diinput:

| Data | Jumlah | Sumber |
|------|--------|--------|
| Jadwal imunisasi nasional (di-generate per anak) | **13 vaksin** (usia 0–18 bulan) | `lib/core/constants/vaccine_schedule.dart` |
| Fasilitas kesehatan (3 kota, 4 tipe) | **14 faskes** | `lib/features/faskes/data/datasources/faskes_mock_datasource.dart` |
| Artikel edukasi | **8 artikel** | `lib/features/education/data/datasources/education_mock_datasource.dart` |
| Video edukasi | **6 video** | idem |
| Kuis interaktif | **3 kuis (15 soal)** | idem |
| Knowledge base ImuniBot | **31 grup keyword** | `lib/features/chatbot/data/datasources/chatbot_mock_datasource.dart` |
| Referensi pertumbuhan WHO | median, −2SD, +2SD (BB/TB/LK) | `lib/core/constants/who_growth_reference.dart` |

### 2. Data yang dibuat pengguna (tersimpan permanen di perangkat)

- Akun pengguna (`userBox` di Hive CE)
- Profil anak (`babyBox`)
- Jadwal imunisasi hasil generate otomatis (`vaccineScheduleBox`)
- Catatan pertumbuhan (`growthRecordsBox`)
- Jurnal kesehatan & KIPI (`healthJournalsBox`)
- Skor kuis (`educationQuizScoresBox`)

### 3. Akun simulasi (rekomendasi untuk demo)

Karena tidak ada akun bawaan, buat akun berikut saat registrasi agar konsisten dengan
panduan skenario di bawah:

| Field | Nilai |
|-------|-------|
| Nama | `Siti Rahma` |
| Email | `ibu.siti@mail.com` |
| No. HP | `081234567890` |
| Kota | `Jakarta Selatan` |
| Password | `password123` |
| Nama anak | `Ahmad Rayyan` (jenis kelamin **Laki-laki**) |

> **Tips:** isi **Tanggal Lahir** anak sekitar **3 bulan yang lalu** agar status imunisasi
> menunjukkan campuran **Selesai / Terjadwal / Terlewat** — lebih menarik saat didemokan.

### 4. Reset data

Ingin kembali ke kondisi bersih? Cukup **uninstall aplikasi** dari perangkat/emulator
(semua data Hive CE & `SharedPreferences` ikut terhapus), lalu `flutter run` kembali.

---

## 🎬 Skenario Simulasi Demo

Ikuti lima skenario berikut untuk mencoba seluruh fitur utama secara berurutan.

### Skenario 1 — Onboarding, Registrasi & Pendaftaran Anak

1. Buka aplikasi → animasi **Splash** → masuk ke **Onboarding**.
2. Geser 3 slide onboarding → ketuk **Mulai Sekarang**.
3. Ketuk **Daftar Akun Baru** → isi form registrasi (lihat [akun simulasi](#3-akun-simulasi-rekomendasi-untuk-demo)).
4. Setelah daftar, isi form **Tambah Profil Anak**: nama `Ahmad Rayyan`, tanggal lahir ±3 bulan lalu, jenis kelamin Laki-laki.
5. Ketuk **Simpan** → sistem otomatis men-generate **13 jadwal imunisasi** untuk anak tersebut.
6. Anda mendarat di **Dashboard**: header menyapa nama anak, menampilkan usia, dan kartu vaksin berikutnya.

### Skenario 2 — Pelaksanaan Imunisasi & Pencatatan KIPI

1. Dari Dashboard, ketuk kartu **Next Vaccine** atau buka tab **Kalender**.
2. Perhatikan marker status: 🟢 selesai, 🔵 terjadwal, 🔴 terlewat.
3. Ketuk salah satu jadwal (mis. `DPT-HB-Hib 1`) → halaman **Detail Vaksin**.
4. Ketuk **Simpan & Selesaikan Imunisasi**.
5. Isi form KIPI: suhu `38.2` °C, pilih chip gejala `Demam` & `Rewel`, tulis catatan.
6. Simpan → status vaksin berubah menjadi **Selesai** dan entri **Jurnal Kesehatan** baru otomatis terbuat & terhubung.
7. Buka tab **Profil → Jurnal Sehat** (atau menu jurnal) untuk memverifikasi catatan tersebut.

### Skenario 3 — Pemantauan Tumbuh Kembang & Grafik WHO

1. Dari Dashboard, buka menu **Tumbuh Kembang**.
2. Lihat grafik interaktif `fl_chart` beserta garis referensi median WHO.
3. Ketuk ikon **+** di AppBar → form pengukuran.
4. Masukkan data, mis. Berat `6.5` kg, Tinggi `62` cm, Lingkar Kepala `41` cm.
5. Simpan → titik data baru langsung muncul di grafik, dan ringkasan di Dashboard ikut ter-update.

### Skenario 4 — Konsultasi ImuniBot & Direktori Faskes

1. Buka tab **ImuniBot**.
2. Ketuk salah satu *suggested question*, mis. `Demam setelah imunisasi apakah normal?`.
3. Perhatikan animasi *typing indicator* sebelum bot membalas.
4. Coba ketik pertanyaan bebas, mis. `apa itu vaksin campak?`.
5. Pindah ke tab **Faskes**: uji toggle **Daftar ↔ Peta (OpenStreetMap)**.
6. Ketuk salah satu faskes → *bottom sheet* detail dengan opsi **Telepon** / **Navigasi** (Maps).

### Skenario 5 — Manajemen Profil, Multi-Anak & Cascade Delete

1. Buka tab **Profil**.
2. Lihat daftar anak → ketuk **+ Tambah Bayi** untuk mendaftarkan anak kedua, mis. `Aisyah`.
3. Ketuk **Aktifkan** pada profil Aisyah.
4. Buka Dashboard: seluruh jadwal & grafik otomatis beralih ke data Aisyah (bayi aktif).
5. Buka detail anak → ketuk **Hapus Profil Anak** → muncul dialog konfirmasi.
6. Konfirmasi: profil terhapus dan seluruh data turunannya (jadwal, pertumbuhan, jurnal) ikut terhapus **secara berantai (cascade delete)**, tanpa meninggalkan data yatim.
7. Ketuk **Keluar (Logout)** → sesi dibersihkan, kembali ke Login. Data anak tetap tersimpan dan tersedia saat login kembali.

---

## 🗂️ Struktur Proyek

```text
lib/
├─ app/                 # root widget, router (GoRouter), tema (warna/tipografi)
├─ core/                # konstanta, service (Hive/sesi/notifikasi), util, error
├─ features/            # fitur-fitur aplikasi (lihat daftar di bawah)
├─ injection/           # registri dependency injection (Riverpod providers)
├─ widgets/             # 10 komponen UI global yang dipakai lintas fitur
├─ main.dart            # bootstrap: Hive → timezone → notifikasi → ProviderScope
└─ hive_registrar.g.dart

test/                   # unit & widget test
.github/workflows/      # pipeline CI (analyze + test)
docs/                   # dokumen ringkas proyek (persona, peta layar, model data, dst.)
```

Daftar fitur di `lib/features/`:

```text
auth/           # onboarding, login/register, pengaturan & profil
baby_profile/   # CRUD profil anak, bayi aktif
dashboard/      # layar beranda
immunization/   # jadwal, kalender, timeline, detail vaksin + KIPI
growth/         # grafik pertumbuhan & input pengukuran
health_journal/ # jurnal kesehatan & KIPI
education/      # artikel, video, kuis (mock)
faskes/         # direktori faskes + peta (mock)
chatbot/        # ImuniBot (mock)
```

Setiap fitur domain mengikuti **Clean Architecture** ringan:

```text
data/         → model Hive, datasource, implementasi repository
domain/       → entity, kontrak repository, use case
presentation/ → provider Riverpod, screen, widget
```

### Model data (Hive CE)

| Model | typeId | Relasi |
|-------|--------|--------|
| `UserModel` | 0 | — |
| `BabyModel` | 1 | `userId` → `UserModel` |
| `VaccineScheduleModel` | 2 | `babyId` → `BabyModel` |
| `GrowthRecordModel` | 3 | `babyId` → `BabyModel` |
| `HealthJournalModel` | 4 | `babyId` → `BabyModel`, `vaccineScheduleId` → `VaccineScheduleModel` (opsional) |
| `QuizScoreModel` | 5 | `quizId` (konten mock) |

---

## 📝 Catatan Implementasi

- **Notifikasi**: pengingat dijadwalkan di level OS (`zonedSchedule`). Bila izin *exact alarm*
  ditolak (umum di Android 12+), aplikasi otomatis memakai mode *inexact* agar pengingat
  tetap terkirim. Status `TERLEWAT` dihitung saat data dibaca (`VaccineStatus.effective`),
  sehingga tidak memerlukan background task harian.
- **`html` di-pin ke `0.15.6`** lewat `dependency_overrides` karena `flutter_html` `3.0.0`
  belum kompatibel dengan `html` ≥ `0.15.7`. Jangan hapus pin ini sebelum upstream diperbaiki.
- **Data edukasi, faskes, dan chatbot masih mock (hardcoded)** — belum terhubung ke API.
- **Peta** membutuhkan koneksi internet untuk memuat ubin OpenStreetMap.
- **Versi aplikasi** disamakan manual antara `pubspec.yaml` dan `AppConstants.appVersion`.

---

## 🩺 Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Build gagal karena desugaring | Pastikan memakai **JDK 17** (`flutter doctor -v`), lalu `flutter clean` dan coba lagi |
| Notifikasi tidak muncul | Izinkan notifikasi & *exact alarm* di pengaturan perangkat; di emulator beberapa alarm mungkin tertunda |
| Peta kosong / tile tidak muncul | Periksa koneksi internet perangkat/emulator |
| Error "Method not found: 'matches'" | Jangan menghapus `dependency_overrides: html: 0.15.6` di `pubspec.yaml` |
| Perubahan model Hive tidak terbaca | Jalankan `dart run build_runner build --delete-conflicting-outputs` |
| Ingin reset semua data | Uninstall aplikasi lalu `flutter run` kembali |

---
