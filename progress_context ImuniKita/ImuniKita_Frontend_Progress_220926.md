
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
# 📊 ImuniKita — Progress Pengembangan Frontend
> **Fase**: UTS — Prototipe Frontend (Flutter + Local Storage)
> **Terakhir Diperbarui**: 29 September 2026
> **Basis audit**: penelusuran ulang seluruh `lib/` (**126 file Dart di 101 direktori**), `pubspec.yaml`, `app_router.dart`, plus `flutter analyze` (**No issues found!**) dan `flutter test` (**168/168 test lulus di 15 file test**). Seluruh **10 dari 10 Shared Global Widgets** selesai (100%), Clean Architecture penuh di 5 domain feature (Auth, Baby, Imunisasi, Growth, Health Journal) dengan **30 Riverpod DI providers**, otomasi CI GitHub Actions aktif, dan bug fixes tumbuh kembang, jurnal slider, serta kalender filter terselesaikan.

---

## 🎯 Ringkasan Progress Keseluruhan

| Fase | Total Screen | ✅ Selesai | 🧪 Perlu Testing | 🔄 In Progress | ⬜ Belum Mulai | Progress |
|------|-------------|-----------|------------------|----------------|---------------|----------|
| Auth & Onboarding | 5 | 5 | 0 | 0 | 0 | 100% |
| Dashboard | 1 | 1 | 0 | 0 | 0 | 100% |
| Imunisasi & Kalender | 3 | 3 | 0 | 0 | 0 | 100% |
| Pertumbuhan & Jurnal | 4 | 4 | 0 | 0 | 0 | 100% |
| Edukasi | 3 | 3 | 0 | 0 | 0 | 100% |
| Direktori Faskes | 1 | 0 | 1 | 0 | 0 | 100% |
| AI Chatbot | 1 | 0 | 1 | 0 | 0 | 100% |
| Settings & Profile | 1 | 1 | 0 | 0 | 0 | 100% |
| **TOTAL** | **19** | **17** | **2** | **0** | **0** | **100%** |

> **Status Legend**: ✅ Selesai · 🔄 In Progress · ⬜ Belum Mulai · 🧪 Perlu Testing
> **Progress** = (✅ + 🧪) / Total Screen = **19 / 19 (100%)**.
> **Shared Widgets**: **10 dari 10 selesai (100%)** di `lib/widgets/`.
> **Clean Architecture & DI**: **100% fitur inti** memiliki layer Domain, Data, dan Presentation terdaftar di `dependency_injection.dart`.
>
> ⚠️ **Catatan verifikasi device**: screen **1.5 Add Baby** sudah diverifikasi di device fisik. Screen 2.1, 3.1–3.3, 4.1–4.4, 5.1–5.3, 6.1, 7.1, dan 8.1 berstatus ✅/🧪 karena **kode selesai, 100% terintegrasi dengan shared widgets & DI, lolos `flutter analyze` bersih, dan lolos seluruh 168 unit & widget test**. Direktori Faskes (6.1) dan AI Chatbot (7.1) berstatus 🧪 menunggu uji perangkat fisik/emulator.

---

## 🆕 Perubahan Terbaru (22, 24, 25 & 29 September 2026)

### 22 September 2026 — Sprint 2 & 3

Sprint 2 & 3 masuk bersamaan lewat branch `fadhil` (commit `9ed4389` / `4960396`, di-merge 22–23 Sep). Ringkasannya:

| Area | Yang bertambah | File baru |
|------|----------------|-----------|
| Dashboard (2.1) | 1 screen penuh: header card, kartu vaksin terdekat, quick action 2x2, ringkasan pertumbuhan, bottom nav, pull-to-refresh | `dashboard/presentation/screens/dashboard_screen.dart` |
| Imunisasi UI (3.1–3.3) | Kalender `table_calendar` + filter chip, timeline vertical, detail vaksin + form KIPI | 3 screen + `immunization_provider.dart` |
| Pertumbuhan (4.1–4.2) | Grafik `fl_chart` 3 tab, form tambah pengukuran | 2 screen + `growth_record_model.dart` (+`.g.dart`) + `growth_provider.dart` |
| Jurnal Kesehatan (4.3–4.4) | List jurnal (swipe to delete), form tambah jurnal | 2 screen + `health_journal_model.dart` (+`.g.dart`) + `journal_provider.dart` |
| Hive CE | 2 adapter baru ter-generate → total **5 adapter** | `hive_registrar.g.dart` diperbarui |
| Routing | 8 route beralih dari `_PlaceholderScreen` ke screen asli → kini **13 route asli & 6 placeholder** | `app_router.dart` |

Yang **belum** bergerak saat itu: `features/{education,faskes,chatbot}/` (masih hanya `.gitkeep`) dan `lib/widgets/` (komponen UI global belum dibuat).

### 24 September 2026 — Fitur Edukasi (poin 5 / FR-05)

| Area | Yang bertambah | File |
|------|----------------|------|
| Hub Edukasi (5.1) | 3 tab (Artikel · Video · Kuis) + chip filter kategori yang dipakai bersama | `education_hub_screen.dart` |
| Article Detail (5.2) | Hero image, meta (penulis/tanggal/estimasi baca), body HTML via `flutter_html`, tombol share, artikel terkait | `article_detail_screen.dart` |
| Quiz (5.3) | Progress bar soal, 4 pilihan, feedback langsung + penjelasan, layar hasil + badge, simpan skor | `quiz_screen.dart` |
| Konten mock | 8 artikel, 6 video, 3 kuis (15 soal) hardcoded sesuai dev plan §1.1 | `education_mock_datasource.dart` |
| Model | `ArticleModel`, `VideoModel`, `QuizModel`(+`QuizQuestion`), **`QuizScoreModel` Hive `typeId: 5`** | `education/data/models/*` |
| Provider | Datasource, kategori filter (`StateProvider`), daftar artikel/video/kuis, detail artikel, dan `quizScoresProvider` (`AsyncNotifier`) | `education_provider.dart` |
| Widget fitur | Thumbnail dengan fallback gradien offline + badge kategori | `education/presentation/widgets/` |
| Hive CE | 1 adapter baru → total **6 adapter** | `hive_registrar.g.dart` diperbarui |
| Routing | 3 route edukasi memakai screen asli → kini **16 route asli, 3 placeholder** (faskes, chatbot, settings) | `app_router.dart` |
| Dashboard | Quick action **Edukasi** ditambahkan (dev plan §1.1/FR-05) agar fitur bisa dijangkau | `dashboard_screen.dart` (+1 baris) |
| Test | `test/education_test.dart` — 11 test datasource & model | `test/education_test.dart` |

Yang **belum** bergerak: `features/{faskes,chatbot}/` dan `lib/widgets/`.

### 24 September 2026 — Profil & Pengaturan (poin 8)

| Area | Yang bertambah | File |
|------|----------------|------|
| Layar Profil (8.1) | Profil pengguna (avatar inisial, nama, email, HP, kota) + sunting profil, daftar bayi + "Tambah Bayi", toggle notifikasi, info versi, dan tombol Keluar dengan konfirmasi | `auth/presentation/screens/settings_screen.dart` |
| Provider auth | `currentUserProvider` (`AsyncNotifier<UserModel?>`) + `notificationEnabledProvider` — sesuai dev plan §1.1 yang memang merencanakan `auth_provider.dart` | `auth/presentation/providers/auth_provider.dart` |
| Komponen global | **`ConfirmDialog`** — komponen pertama dari 10 Shared Widgets yang direncanakan | `lib/widgets/confirm_dialog.dart` |
| Core | `LocalStorageService` +`setCurrentUserName`, `clearSession`, `isNotificationEnabled`, `setNotificationEnabled`; `AppConstants` +`prefNotificationsEnabled`, `appVersion` | `core/services/`, `core/constants/` |
| Perilaku notifikasi | `ScheduleReminderUseCase` kini **berhenti menjadwalkan** bila toggle notifikasi dimatikan; saat diaktifkan lagi, pengingat seluruh jadwal `BELUM` didaftarkan ulang | `schedule_reminder_usecase.dart` |
| Routing | Route `/settings` memakai screen asli → kini **17 route asli, 2 placeholder** (faskes, chatbot) | `app_router.dart` |
| Test | `test/settings_test.dart` — 11 test (sesi/prefs, `CurrentUserProvider`, `ConfirmDialog`) → total **25 test** | `test/settings_test.dart` |

> Mulai poin 8, alur demo bisa di-*reset* dari dalam aplikasi (Keluar → Login), tidak lagi butuh `adb shell pm clear`.

Yang **belum** bergerak: `features/{faskes,chatbot}/` (2 screen terakhir).

### 24 September 2026 — Perbaikan Gap Prioritas 1 (#3 + quick wins)

Sesuai urutan prioritas temuan (bukan fitur baru):

| Temuan | Perbaikan | File yang disentuh |
|--------|-----------|--------------------|
| **#3** Status `TERLEWAT` | Kebijakan status dipindah ke domain (`VaccineStatus.effective`) dan diterapkan **saat data dibaca** di `ImmunizationRepositoryImpl` (`getSchedulesByBaby` + `getScheduleById` baru). `immunizationProvider` kini membaca/menulis lewat repository (registry DI) dan mengembalikan **entity**, bukan model Hive. Kalender, Timeline, Dashboard, dan Detail Vaksin memakai status efektif & konstanta `VaccineStatus.*` — bukan string literal. Detail Vaksin juga tidak lagi membuka Hive box sendiri (menghapus jalur baca ketiga) | `vaccine_schedule_entity.dart`, `vaccine_local_datasource.dart`, `i_immunization_repository.dart`, `immunization_repository_impl.dart`, `immunization_provider.dart`, `calendar_screen.dart`, `vaccine_timeline_screen.dart`, `vaccine_detail_screen.dart`, `dashboard_screen.dart` |
| **#4** Nama box Hive hardcode | `growthRecordsBox` & `healthJournalsBox` menjadi konstanta `AppConstants` dan dipakai provider growth & jurnal | `app_constants.dart`, `growth_provider.dart`, `journal_provider.dart` |
| **#5** String literal sesi | `'userBox'`, `'is_logged_in'`, `'user_id'`, `'user_name'` → `AppConstants`; ditambah konstanta baru `prefSeenOnboarding` (sebelumnya literal di Splash & Onboarding) | `app_constants.dart`, `login_screen.dart`, `register_screen.dart`, `splash_screen.dart`, `onboarding_screen.dart` |
| **#19** (sebagian) | `logout()` kini membatalkan seluruh pengingat terjadwal (non-fatal bila plugin gagal) | `auth_provider.dart` |
| **#20** (mitigasi) | Komentar silang di `pubspec.yaml` agar `version:` dan `AppConstants.appVersion` tidak *drift* | `pubspec.yaml` |
| **#9** (sebagian) | Test baru `test/vaccine_status_test.dart` (13 test): kebijakan status + pembuktian normalisasi lewat Hive nyata, termasuk bahwa **isi Hive tidak ikut berubah** | `test/vaccine_status_test.dart` |

**Dampak yang terlihat user:** badge "Hari Ini" untuk vaksin yang sudah lewat hilang, filter "Terlewat" di Kalender kini terisi, marker 🔴 muncul, dan status di Kalender/Timeline/Detail selalu konsisten.

**Catatan gaya kode:** perbaikan di 9 file ditulis mengikuti gaya yang ada (diff minimal, mis. `dashboard_screen.dart` hanya 3 baris). Dua file yang perubahannya struktural — `immunization_provider.dart` & `vaccine_detail_screen.dart` — ikut ter-format `dart format` (tall style) karena disunting lewat editor; beri tahu bila ingin dinormalkan ke gaya lama.

### 24 September 2026 — Kelola Profil Anak (#21) + Bayi Aktif (#2)

| Area | Perubahan | File |
|------|-----------|------|
| Layar kelola anak (#21) | Screen baru: ubah nama/tanggal lahir/jenis kelamin, tombol **Jadikan Anak Aktif**, dan **Hapus Profil Anak** berkonfirmasi. Route baru `/baby/detail/:id` | `baby_detail_screen.dart` (baru), `app_router.dart` |
| Hitung ulang jadwal | Bila tanggal lahir diperbaiki, jadwal lama dihapus dan **13 jadwal dibangun ulang** dari tanggal lahir baru (+ pengingat H-7/H-1 didaftarkan ulang, non-fatal) | `baby_detail_screen.dart` |
| Hapus + cascade | `DeleteBabyUseCase` baru; penghapusan dibersihkan berantai: jadwal imunisasi, rekam pertumbuhan, lalu jurnal — supaya tidak ada data yatim di Hive | `delete_baby_usecase.dart` (baru), `baby_local_datasource.dart`, `i_baby_repository.dart`, `baby_repository_impl.dart`, `dependency_injection.dart`, `vaccine_local_datasource.dart`, `i_immunization_repository.dart`, `immunization_repository_impl.dart`, `immunization_provider.dart`, `growth_provider.dart`, `journal_provider.dart` |
| Bayi aktif (#2) | `activeBabyProvider` (`AsyncNotifier<BabyEntity?>`) + `prefActiveBabyId`; pilihan bertahan lintas sesi dan otomatis jatuh ke bayi pertama bila bayi aktif dihapus. **Ketujuh screen** tidak lagi memakai `babies.first` | `active_baby_provider.dart` (baru), `app_constants.dart`, `local_storage_service.dart`, `dashboard_screen.dart`, `calendar_screen.dart`, `vaccine_timeline_screen.dart`, `growth_chart_screen.dart`, `add_growth_record_screen.dart`, `journal_list_screen.dart`, `add_journal_screen.dart` |
| Pemilih bayi di 8.1 | Kartu anak bisa diketuk (→ layar kelola), ada badge **Aktif** + tombol **Aktifkan**, plus penjelasan singkat arti "anak aktif" | `settings_screen.dart` |
| Test | `test/baby_profile_test.dart` — 10 test: hapus/ubah profil, penggantian bayi aktif (termasuk setelah dihapus), cascade delete, dan hitung ulang 13 jadwal dari tanggal lahir baru | `test/baby_profile_test.dart` (baru) |

**Dampak yang terlihat user:** salah input tanggal lahir kini bisa diperbaiki (dan jadwal ikut benar), profil anak bisa dihapus beserta datanya, dan anak kedua/berikutnya bisa dipilih lewat daftar di layar Profil — seluruh layar langsung mengikuti anak yang dipilih.

**Sisa yang belum:** `BabyListScreen` tersendiri tetap belum dibuat — kebutuhan memilih/mengelola anak sementara ditutup oleh daftar anak di 8.1 dan layar `baby_detail_screen.dart`.

### 24 September 2026 — Unit Test Use Case Inti (#9)

| Area | Yang dikerjakan | File |
|------|-----------------|------|
| Test `GenerateScheduleUseCase` | 7 test: 13 jadwal sesuai `VaccineMaster`, rumus `tanggalTarget = tanggal lahir + usia` (termasuk kasus akhir bulan 31 Jan → 28 Feb), status awal `BELUM`, id unik, **guard double-tap** (tidak generate ulang), dan isolasi antar bayi. Memakai repository **fake in-memory** agar benar-benar unit test (tanpa Hive) | `test/schedule_usecase_test.dart` (baru) |
| Test `NotificationHelper` | 3 test: `reminderDate` (H-7/H-1 pada jam pengingat), `notificationId` stabil & unik per jadwal/offset, teks judul & isi ("minggu"/"besok") | idem |
| Test `ScheduleReminderUseCase` | 6 test dengan **mock kanal `dexterous.com/flutter/local_notifications`**: 2 panggilan `zonedSchedule` untuk jadwal depan, melewati jadwal `SELESAI`/`TERLEWAT`, melewati pengingat yang sudah lewat, **tidak menjadwalkan apa pun saat toggle notifikasi mati**, dan beberapa jadwal sekaligus. Ikut diverifikasi: payload `scheduleId`, judul/isi, zona waktu, waktu kirim, serta konfigurasi kanal Android (`channelId`, `importance`, `scheduleMode`) | idem |
| Perbaikan kecil | `NotificationHelper.reminderDate` kini memakai `AppConstants.reminderHour` sebagai jam bawaan — sebelumnya konstanta itu **tidak pernah dipakai** (jam 8 di-hardcode di helper), sehingga mengubahnya tidak berefek | `notification_helper.dart` |

**Catatan teknis untuk test selanjutnya:** dua hal yang perlu disiapkan bila menguji alur notifikasi — `tz.initializeTimeZones()` + `setLocalLocation('Asia/Jakarta')` (dilakukan `main.dart` saat runtime) dan `AndroidFlutterLocalNotificationsPlugin.registerWith()` supaya `FlutterLocalNotificationsPlatform.instance` tersedia. Keduanya sudah dipakai di `schedule_usecase_test.dart`.

### 24 September 2026 — Perbaikan Navigasi Halaman Edukasi

**Gejala:** dari Dashboard, kartu **Edukasi** membuka hub **tanpa tombol kembali** sehingga layar terasa buntu (hub tidak punya bottom navigation).

**Penyebab:** `/education` adalah route **top-level**, dan Dashboard membukanya dengan `context.go(...)`. `go` mengganti lokasi **tanpa menambah halaman ke tumpukan**, jadi tumpukan hanya berisi satu halaman → tidak ada yang bisa di-`pop` dan `AppBar` tidak menampilkan tombol kembali. Layar lain tidak terkena: Kalender/Pertumbuhan/Jurnal punya bottom nav, sedangkan Timeline, Detail Vaksin, Form Pertumbuhan/Jurnal, dan Detail Artikel/Kuis adalah **nested route** sehingga otomatis punya tombol kembali.

**Perbaikan:**

| Perubahan | File |
|-----------|------|
| Kartu **Edukasi** & **ImuniBot** dibuka dengan `context.push` (parameter baru `_buildMenuCard(..., push: true)`); Kalender/Tumbuh Kembang/Jurnal tetap `go` karena punya bottom nav | `dashboard_screen.dart` |
| `AppBar` hub Edukasi diberi `leading` eksplisit `context.canPop() ? pop() : go(/dashboard)` agar layar ini tidak pernah buntu, termasuk bila dibuka via deep link | `education_hub_screen.dart` |
| Test regresi: tombol kembali tampil & berfungsi, baik saat hub dibuka langsung maupun lewat `push` | `test/education_navigation_test.dart` (baru) |

### 25 September 2026 — Direktori Faskes, AI Chatbot, Bottom Nav & Bug Fixes

| Area | Yang bertambah | File |
|------|----------------|------|
| Direktori Faskes (6.1) | Screen baru `FaskesScreen`: toggle Daftar ↔ Peta, chip filter tipe (Semua/RS/Puskesmas/Klinik/Apotek), ListView kartu faskes (telepon tappable, tombol Navigasi), `FlutterMap` OSM markers berwarna per tipe, bottom sheet detail, bottom nav index 3 | `faskes_screen.dart`, `faskes_model.dart`, `faskes_mock_datasource.dart`, `faskes_provider.dart` |
| AI Chatbot / ImuniBot (7.1) | Screen baru `ChatbotScreen`: welcome state + 5 suggested chips, bubble chat user/bot, typing indicator 3 titik animasi, input bar, scroll via `ref.listen`, clear dengan ConfirmDialog, bottom nav index 2 | `chatbot_screen.dart`, `chat_message_model.dart`, `chatbot_mock_datasource.dart`, `chatbot_provider.dart` |
| Bottom Navigation Bar | Tab diubah: **Home · Kalender · ImuniBot · Faskes · Profil** (menggantikan Pertumbuhan & Jurnal). GrowthChartScreen & JournalListScreen dihapus bottom nav-nya karena bukan tab utama | `dashboard_screen.dart`, `calendar_screen.dart`, `growth_chart_screen.dart`, `journal_list_screen.dart`, `settings_screen.dart`, `faskes_screen.dart`, `chatbot_screen.dart` |
| Dashboard | Quick actions grid 6 kartu genap 2×3: tambah kartu **ImuniBot 🤖** & **Direktori Faskes**. Greeting dinamis (Pagi/Siang/Sore/Malam) | `dashboard_screen.dart` |
| Router | Route `/faskes` → `FaskesScreen()`, `/chatbot` → `ChatbotScreen()`. `_PlaceholderScreen` dihapus — **0 placeholder tersisa**, semua 20 route memakai screen asli | `app_router.dart` |
| pubspec.yaml | Tambah `flutter_map: ^7.0.2` dan `latlong2: ^0.9.1` (OpenStreetMap — gratis, tanpa API key) | `pubspec.yaml` |
| Bug fixes | #16 bottom nav, #17 grid slot, #23 filter kalender per hari, #24 detail vaksin selesai, #25 greeting statis, #26 FAB `go→push`, #27 bottom nav keliru di Growth & Journal | 7 file |

**Validasi 25 Sep:** `flutter pub get` ✅ · `flutter analyze` → **No issues found!**

### 25 September 2026 — UI/UX Polish: Warna, Kalender, Navigasi & Grafik Pertumbuhan

| Area | Yang diubah | File |
|------|-------------|------|
| **Standarisasi Warna** | `AppColors.surface` → `Colors.white`; `AppColors.border` → `Color(0xFFE2E8F0)` diterapkan seragam ke seluruh fitur. Warna kartu **ImuniBot** di Dashboard diubah dari ungu → `tealDark` agar konsisten dengan palet | `app_colors.dart`, `dashboard_screen.dart`, `calendar_screen.dart`, `chatbot_screen.dart`, `faskes_screen.dart`, `journal_list_screen.dart`, dll. |
| **Kalender — hapus faskes & back** | Menu "Faskes" dihapus dari kalender; tombol **Back** di AppBar kalender dihapus (kalender adalah tab utama) | `calendar_screen.dart` |
| **Kalender — urutan tab nav** | Posisi **Faskes** dan **ImuniBot** di bottom nav ditukar agar urutan = Home · Kalender · ImuniBot · Faskes · Profil | `calendar_screen.dart`, `faskes_screen.dart`, `chatbot_screen.dart`, `dashboard_screen.dart`, `settings_screen.dart` |
| **Kalender — jump ke tanggal** | Tombol "Lihat" pada jadwal yang akan datang kini memakai `_calendarController.animateTo(tanggal)` sehingga kalender langsung berpindah ke tanggal jadwal tersebut | `calendar_screen.dart` |
| **Kalender — hapus centang selesai** | Checkbox / centang status "selesai" di dalam daftar jadwal kalender dihapus agar tampilan lebih bersih | `calendar_screen.dart` |
| **Chip status vaksin** | Warna chip diseragamkan: Selesai → hijau, Terlewat → merah, Belum → kuning dengan teks kontras; palet mengikuti `AppColors` | `calendar_screen.dart` |
| **Timeline — status Terlewat** | Indikator berwarna merah + ikon `cancel` ditambahkan untuk status `VaccineStatus.terlewat` | `vaccine_timeline_screen.dart` |
| **FAB → AppBar actions (Tumbuh Kembang)** | `FloatingActionButton` "+" yang menutupi teks keterangan grafik dihapus; digantikan `IconButton` berlatar `AppColors.coral` di AppBar actions. Teks empty state diperbarui ("tombol + di atas") | `growth_chart_screen.dart` |
| **FAB → AppBar actions (Jurnal Sehat)** | Sama seperti di atas: FAB kuning dihapus, diganti `IconButton` berlatar `AppColors.yellow` di AppBar actions | `journal_list_screen.dart` |
| **Grafik Pertumbuhan — garis WHO** | Warna garis referensi WHO diubah dari `Colors.green.withOpacity(0.5)` (pudar) → `Color(0xFF16A34A)` solid; lebar 2→2.5; pola putus `[5,5]`→`[8,4]`; ditambah `belowBarData` shading hijau 7% agar garis lebih terbaca | `growth_chart_screen.dart` |
| **Grafik Pertumbuhan — maxY dinamis** | `maxY` berat badan tidak lagi hardcode ke 25 kg; dihitung dari data aktual (`dataMax > 23 ? dataMax + 3 : 25`) sehingga nilai > 25 kg tidak pernah terpotong di atas grafik | `growth_chart_screen.dart` |
| **Avatar & Foto Profil Anak** | Foto profil anak kini tampil di Dashboard (kartu header & popup ganti anak) serta di layar kelola profil anak (`baby_detail_screen.dart`). Jika foto belum ada, avatar diseragamkan memakai inisial nama anak berfont Baloo2 dan palet teal, konsisten antara Dashboard dan tab Profil | `dashboard_screen.dart`, `baby_detail_screen.dart`, `settings_screen.dart` |

### 25 September 2026 — +9 Global Shared Widgets (Commit `27463e9`)

| Area | Yang ditambah / diubah | File |
|------|------------------------|------|
| **10/10 Shared Widgets** | 9 komponen UI bersama baru dibuat di `lib/widgets/`: `app_bottom_nav_bar.dart` (bottom nav 5 tab seragam), `baby_avatar.dart` (avatar inisial / foto profil), `custom_text_field.dart` (form input bergaya neo), `empty_state_widget.dart` (state kosong informatif), `error_state_widget.dart` (state error dengan retry), `loading_overlay.dart` (overlay modal saat async operation), `section_header.dart` (judul seksi font Baloo 2), `status_badge.dart` (badge status seragam), dan `vaccine_card.dart` (kartu info vaksinasi) | `lib/widgets/*` (total 10 file) |
| **Integrasi ke Seluruh Screen** | Seluruh 19+ screen diperbarui untuk memakai komponen global ini, mengeliminasi duplikasi kode UI (khususnya AppBar, TextField, BottomNav, Avatar, Empty State, dan Error Handling) | 18 screen di `features/` |
| **Test Komponen Global** | 20+ test widget untuk menguji render dan interaksi ke-10 shared widgets | `test/global_widgets_test.dart` |

### 25 September 2026 — Major 20+ Bugs Fix & Clean Architecture Overhaul (Commit `8b777b6`)

| Area | Yang dikerjakan | File |
|------|-----------------|------|
| **Clean Arch Auth** | Lapisan domain & data auth lengkap: `user_entity.dart`, `i_auth_repository.dart`, 6 use case (`login_usecase`, `register_usecase`, `logout_usecase`, `auth_state_usecase`, `get_current_user_usecase`, `update_profile_usecase`), `auth_local_datasource.dart`, `auth_repository_impl.dart`. Temuan #22 ✅ | `features/auth/*` |
| **Clean Arch Growth & Journal** | Penerapan domain & data layer pada Growth (`growth_record_entity.dart`, `i_growth_repository.dart`, 3 use case, datasource, repo impl) dan Health Journal (`health_journal_entity.dart`, `i_health_journal_repository.dart`, 4 use case, datasource, repo impl). Temuan #4 & #32 ✅ | `features/growth/*`, `features/health_journal/*` |
| **DI Registry Pusat** | `lib/injection/dependency_injection.dart` diekspansi menjadi **30 provider Riverpod** berlapis mencakup Auth, Baby, Imunisasi, Growth, dan Journal | `lib/injection/dependency_injection.dart` |
| **Standar Pertumbuhan WHO** | Referensi baku WHO Child Growth Standards (0–24 bulan) dengan median, -2SD, dan +2SD untuk Berat Badan, Tinggi Badan, dan Lingkar Kepala laki-laki/perempuan diintegrasikan ke `GrowthChartScreen`. Temuan #8 ✅ | `lib/core/constants/who_growth_reference.dart`, `test/who_growth_reference_test.dart` |
| **Penyempurnaan Notifikasi** | Navigasi tap notifikasi ke `/calendar/detail/$scheduleId`, penanganan payload tertunda saat cold start, fallback otomatis exact alarm ke inexact alarm bila izin OS ditolak, pembatalan notifikasi saat vaksin selesai (`cancelNotification`), dan pelacakan flag anti-duplikasi `reminderH7Sent`/`reminderH1Sent`. Temuan #6, #7, #11 ✅ | `notification_service.dart`, `immunization_provider.dart`, `schedule_reminder_usecase.dart` |
| **Riwayat Kuis** | Penambahan field `attemptCount` dan `riwayatSkor` pada `QuizScoreModel` agar riwayat nilai kuis tersimpan dan tidak tertimpa. Temuan #15 ✅ | `quiz_score_model.dart`, `quiz_screen.dart` |
| **Ikon Monokrom Android** | Asset drawable `ic_stat_imunikita.xml` untuk ikon status bar Android sesuai spesifikasi sistem Android | `android/app/src/main/res/drawable/ic_stat_imunikita.xml` |
| **README & Otomasi CI** | Penulisan dokumentasi lengkap arsitektur dan panduan run `README.md` (Temuan #10 ✅) serta setup otomatisasi pipeline CI GitHub Actions | `README.md`, `.github/workflows/ci.yaml` |

### 25 September 2026 — Fix Bayi 18+ Bulan di Dashboard (Commit `76e1dd3`)

| Area | Yang dikerjakan | File |
|------|-----------------|------|
| **Dashboard Old Baby Handling** | Penanganan khusus kartu vaksin terdekat pada bayi berumur 18+ bulan (di mana semua 13 jadwal vaksin telah selesai atau terlewat) agar Dashboard tetap menampilkan ringkasan imunisasi yang akurat, tidak memunculkan kartu error, dan UI tetap rapi | `dashboard_screen.dart`, `test/dashboard_old_baby_test.dart` |

### 29 September 2026 — Bug Fixes & Refactoring (Growth Validation, Jurnal Slider, Kalender Filter & Clean Code, Onboarding UI, Status Color Test)

| Area | Yang diperbaiki / ditambah | File |
|------|---------------------------|------|
| **Validasi Pengukuran Anak (4.2)** | **Cegah input ganda per hari**: validasi form agar tidak bisa input data tumbuh kembang lebih dari 1 kali pada tanggal yang sama untuk bayi aktif (muncul SnackBar peringatan bahwa data tanggal tersebut sudah ada). **Batas tanggal lahir**: `firstDate` pada date picker kini dibatasi ke `currentBaby.tanggalLahir` sehingga user tidak bisa memilih tanggal sebelum bayi lahir | `add_growth_record_screen.dart` |
| **Hapus Jurnal Kesehatan (4.3)** | **Fix layar merah saat hapus via slider**: perbaikan `Dismissible` pada list jurnal dengan memastikan key unik berbasis `ValueKey(item.journalId)`, penanganan dialog konfirmasi `confirmDismiss` yang aman, dan penghapusan state sinkron sehingga tidak lagi memicu crash / error red screen saat swipe-to-delete | `journal_list_screen.dart` |
| **Kalender Imunisasi (3.1)** | **Filter langsung per kategori status**: saat chip *Terjadwal*, *Selesai*, atau *Terlewat* diklik, kalender langsung menampilkan seluruh jadwal sesuai kategori tersebut tanpa terikat/terbatasi tanggal yang diklik (`_selectedDay` di-reset ke `null`). Prioritas logika filtering didahulukan memeriksa kategori aktif terlebih dahulu, baru kemudian tanggal terpilih (`_selectedDay`). | `calendar_screen.dart` |
| **Refactoring & Clean Code Kalender (3.1)** | Pembersihan kode `calendar_screen.dart`: variabel `_selectedFilter` dijadikan non-nullable string default `'Semua'`, menghapus percabangan redundant / ternary duplikat pada judul dan *empty state*, serta menyederhanakan handler `onSelected` filter chip | `calendar_screen.dart` |
| **Onboarding UI (1.2)** | Perbaikan tampilan slide onboarding: icon tengah, shadow, border, dan lingkaran background yang sebelumnya berwarna hitam/gelap (`darkText`) kini menggunakan warna cerah sesuai slide (`coral`, `teal`, `yellow`) dengan opacity halus agar lebih hidup | `onboarding_screen.dart` |
| **Status Vaksin & CI Test** | Penyelarasan warna status `BELUM` menjadi kuning (`AppColors.yellow`) di helper status dan pembaruan unit test di `test/vaccine_status_test.dart` agar selaras dengan `AppColors.yellow`, meloloskan seluruh **168 test** di `flutter test` dan CI GitHub Actions | `vaccine_status_style.dart`, `test/vaccine_status_test.dart` |

**Validasi 29 Sep:** `flutter analyze` → **No issues found!** · `flutter test` → **168/168 test lulus (15 file test)** (All tests passed!).

---

## 📁 Setup & Arsitektur

| Item | Status | Catatan |
|------|--------|---------|
| Struktur folder Clean Architecture | ✅ Selesai | **101 direktori** di bawah `lib/`; **126 file Dart**. Seluruh 5 fitur domain (`auth`, `baby_profile`, `immunization`, `growth`, `health_journal`) memiliki lapisan Domain, Data, dan Presentation lengkap |
| pubspec.yaml (semua dependency UTS) | ✅ Selesai | 24 dependency utama + dev dependencies. Tambahan: `flutter_map: ^7.0.2`, `latlong2: ^0.9.1`. Pin `dependency_overrides: html: 0.15.6` terpasang stabil. Versi: `1.0.0+1` |
| Setup GoRouter (semua route) | ✅ Selesai | `app/router/app_router.dart` — **20 route**: **seluruh 20 route memakai screen asli**, 0 placeholder |
| Setup Hive CE DB + code generation | ✅ Selesai | `Hive.initFlutter()` + `Hive.registerAdapters()` di `main.dart`. Adapter ter-generate **6**: `UserModel` (typeId 0), `BabyModel` (1), `VaccineScheduleModel` (2), `GrowthRecordModel` (3), `HealthJournalModel` (4), `QuizScoreModel` (5) dengan dukungan riwayat |
| Setup Riverpod providers | ✅ Selesai | `ProviderScope` di `main`, `appRouterProvider`, `babyNotifierProvider`, `immunizationProvider`, `growthProvider`, `journalProvider`, `currentUserProvider`, `notificationEnabledProvider`, `activeBabyProvider`, `babyByIdProvider`, `faskesProvider`, `chatbotProvider` |
| Dependency injection registry | ✅ Selesai | `injection/dependency_injection.dart` — **30 provider** berlapis (datasource → repository → use case) mencakup Auth, Baby, Imunisasi, Growth, dan Health Journal |
| Komponen UI Global (Shared Widgets) | ✅ Selesai | **10 dari 10 komponen bersama** selesai di `lib/widgets/` dan terintegrasi di seluruh screen |
| AppTheme (warna, font, spacing) | ✅ Selesai | `app_colors.dart`, `app_text_styles.dart`, `app_theme.dart` |
| NotificationService | ✅ Selesai | Inisialisasi di `main.dart`, tap navigasi otomatis ke detail vaksin, inexact alarm fallback di Android 12+, dan `cancelNotification` saat vaksin selesai |
| Android permissions (AndroidManifest) | ✅ Selesai | POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, USE_EXACT_ALARM, VIBRATE, RECEIVE_BOOT_COMPLETED, WAKE_LOCK + receivers + desugaring JDK libs |
| Standar Pertumbuhan WHO | ✅ Selesai | `core/constants/who_growth_reference.dart` (Median, -2SD, +2SD untuk BB, TB, LK laki-laki/perempuan) |
| Otomasi CI (GitHub Actions) | ✅ Selesai | `.github/workflows/ci.yaml` menjalankan `flutter analyze` dan `flutter test` otomatis pada branch `main` dan `yeppp` |
| Unit / widget test | ✅ Selesai | **15 file test, 168 test lulus 100%**: mencakup entity, repository, use cases, datasources, notifications, WHO reference, shared widgets, dan UI navigation |

### 🗂️ Rincian Struktur Folder (kondisi terkini 29 Sep 2026)

```
lib/
├── app/
│   ├── app.dart                  # Root widget (MaterialApp.router, setRouter)
│   ├── app_version_provider.dart # Version provider
│   ├── router/                   # app_router.dart (20 route asli, 0 placeholder)
│   └── theme/                    # app_colors.dart, app_text_styles.dart, app_theme.dart
│
├── core/
│   ├── constants/                # vaccine_schedule.dart (13 jadwal), app_constants.dart, who_growth_reference.dart, health_gejala.dart
│   ├── errors/                   # failures.dart
│   ├── services/                 # notification_service.dart, local_storage_service.dart
│   └── utils/                    # age_calculator.dart, date_formatter.dart, notification_helper.dart
│
├── features/
│   ├── auth/                     # ✅ Clean Arch lengkap: entity, repo, 6 use cases, local datasource, repo impl, 5 screen, auth_provider
│   ├── baby_profile/             # ✅ Clean Arch lengkap: entity, repo, 4 use cases, local datasource, repo impl, 2 screen, active_baby_provider
│   ├── dashboard/                # ✅ 1 screen terhubung activeBabyProvider, next vaccine, 2x3 grid, summary, support old baby (18+ bln)
│   ├── immunization/             # ✅ Clean Arch lengkap: entity (status efektif), repo, 4 use cases, local datasource, repo impl, 3 screen
│   ├── growth/                   # ✅ Clean Arch lengkap: entity, repo, 3 use cases, local datasource, repo impl, 2 screen (WHO standard & validasi 1x/hari)
│   ├── health_journal/           # ✅ Clean Arch lengkap: entity, repo, 4 use cases, local datasource, repo impl, 2 screen (Dismissible safe)
│   ├── education/                # ✅ Mock datasource (8 artikel, 6 video, 3 kuis), 4 model, typeId 5 (riwayat), provider, 3 screen
│   ├── faskes/                   # ✅ Mock datasource (14 faskes, 3 kota, 4 tipe), provider, 1 screen (OSM flutter_map)
│   └── chatbot/                  # ✅ Mock datasource (31 keyword), provider, 1 screen (bubble, typing indicator, suggested chips)
│
├── injection/                    # ✅ dependency_injection.dart (30 Riverpod DI providers)
├── main.dart                     # ✅ bootstrap: Hive → timezone → notifikasi → WorkManager → ProviderScope
├── hive_registrar.g.dart         # ✅ 6 adapter terdaftar otomatis
└── widgets/                      # ✅ 10/10 Shared Global Widgets (100% Selesai)
    ├── app_bottom_nav_bar.dart   ├── baby_avatar.dart          ├── confirm_dialog.dart
    ├── custom_text_field.dart    ├── empty_state_widget.dart   ├── error_state_widget.dart
    ├── loading_overlay.dart      ├── section_header.dart       ├── status_badge.dart
    └── vaccine_card.dart
```

> **Catatan struktur**: folder `data/models`, `presentation/providers`, dan `presentation/widgets` pada fitur mock (education/faskes/chatbot) tidak eksplisit ada di pohon dev plan §1.1, tetapi dipakai karena kebutuhan model/provider/widget lokal. Semua direktori tetap dijaga lewat file `.gitkeep` (**58 file**) sehingga struktur ikut ter-track Git.

---

## 1. 🔐 Auth & Onboarding

### 1.1 Splash Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/auth/presentation/screens/splash_screen.dart` |
| **Status** | ✅ Selesai |
| **FR Terkait** | - |
| **Estimasi** | 2 jam |

**Elemen UI yang harus ada:**
- [x] Logo ImuniKita pill (`AppLogoPill` + `assets/images/syringe_logo.png`) + animasi scale & fade
- [x] Two-zone layout: Zona atas coral `#F0856A` dengan Confetti Dots (`ConfettiDotsPainter`) + karakter dari aset `assets/images/splash_character.png`; Zona bawah teal `#38B2AC` dengan headline Baloo 2 + subtitle Poppins
- [x] Pengecekan status login (SharedPreferences) → Onboarding (`seen_onboarding == false`), Login (`is_logged_in == false` + sudah onboarding), atau Dashboard (`is_logged_in == true`)
- [x] Animasi minimum 2,8 detik sebelum navigasi otomatis (`Timer`)

---

### 1.2 Onboarding Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/auth/presentation/screens/onboarding_screen.dart` |
| **Status** | ✅ Selesai |
| **FR Terkait** | - |
| **Estimasi** | 3 jam |

**Elemen UI yang harus ada:**
- [x] 3 halaman swipe (`PageView.builder`)
- [x] Slide 1: **Ikon** `Icons.child_care` + "Pantau Imunisasi Buah Hati"
- [x] Slide 2: **Ikon** `Icons.calendar_month` + "Pengingat Otomatis H-7 & H-1"
- [x] Slide 3: **Ikon** `Icons.bar_chart` + "Pantau Tumbuh Kembang si Kecil"
- [x] Indikator dot (`AnimatedContainer`) animasi
- [x] Tombol "Lewati" dan "Selanjutnya" (`NeoButton`)
- [x] Tombol "Mulai Sekarang" di slide terakhir + set flag `seen_onboarding`

> Catatan: ketiga slide memakai **ikon di dalam `Container` bulat ber-border** (gaya neo-brutalism), bukan ilustrasi gambar. Rincian widget ada di `docs/struktur-widget-auth.md`.

---

### 1.3 Login Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/auth/presentation/screens/login_screen.dart` |
| **Status** | ✅ Selesai |
| **FR Terkait** | - (Mock UTS) |
| **Estimasi** | 3 jam |

**Elemen UI yang harus ada:**
- [x] Logo ImuniKita di atas (`AppLogoPill`)
- [x] Input email dengan validasi format (`AuthValidators.email`)
- [x] Input password dengan toggle show/hide
- [x] Tombol "Masuk" (state loading)
- [x] Link "Belum punya akun? Daftar"
- [x] Mock logic: cari user di Hive `userBox`; jika kosong → snackbar + redirect ke Register
- [x] Snackbar error/success (`SnackbarHelper`)

---

### 1.4 Register Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/auth/presentation/screens/register_screen.dart` |
| **Status** | ✅ Selesai |
| **FR Terkait** | - (Mock UTS) |
| **Estimasi** | 3 jam |

**Elemen UI yang harus ada:**
- [x] Form: Nama Lengkap, Email, Nomor HP, Kota, Password, Konfirmasi Password
- [x] Validasi semua field (`required` + `confirmPassword` + `email`)
- [x] Tombol "Daftar" (state loading)
- [x] Simpan ke Hive CE (`UserModel` di `userBox`) + SharedPreferences untuk session
- [x] Navigasi ke AddBaby setelah daftar berhasil

---

### 1.5 Add Baby Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/baby_profile/presentation/screens/add_baby_screen.dart` |
| **Status** | ✅ Selesai (terverifikasi di device) |
| **FR Terkait** | **FR-01** |
| **Estimasi** | 4 jam |

**Elemen UI yang harus ada:**
- [x] Avatar placeholder + tombol upload foto (`image_picker` ke galeri)
- [x] Form: Nama Anak, Tanggal Lahir (DatePicker), Jenis Kelamin (toggle L/P)
- [x] Preview usia otomatis berdasarkan tanggal lahir (`AgeCalculator.label(...)`)
- [x] Tombol "Simpan Profil"
- [x] **Trigger**: Setelah simpan → `GenerateScheduleUseCase` → 13 jadwal vaksin otomatis → `ScheduleReminderUseCase` → notifikasi H-7 & H-1

**Layer Clean Architecture (FR-01):**

| Layer | File |
|-------|------|
| Domain | `domain/entities/baby_entity.dart` · `domain/repositories/i_baby_repository.dart` · `domain/usecases/{add,get,update}_baby_usecase.dart` |
| Data | `data/models/baby_model.dart` (Hive `typeId: 1`) + `.g.dart` · `data/datasources/baby_local_datasource.dart` · `data/repositories/baby_repository_impl.dart` |
| Presentation | `presentation/providers/baby_provider.dart` (`AsyncNotifier`) · `presentation/screens/add_baby_screen.dart` |

**Catatan implementasi:**
- Alur `_handleSave()`: `addBaby` → `GenerateScheduleUseCase` (13 jadwal dari `VaccineMaster`) → `ScheduleReminderUseCase`. Reminder yang tanggalnya sudah lewat otomatis dilewati.
- Pendaftaran notifikasi **non-fatal**: bila Android menolak izin exact alarm (umum di Android 14+), profil & jadwal tetap tersimpan; snackbar memberi tahu bahwa pengingat belum aktif, dan user tetap diarahkan ke Dashboard.
- ✅ `flutter analyze` bersih · ✅ `flutter build apk --debug` berhasil · ✅ **sudah diuji di device — profil bayi tersimpan & 13 jadwal terbentuk otomatis**.
- Untuk menguji ulang dari nol perlu hapus data aplikasi (`adb shell pm clear com.example.imunikita`) karena layar Settings/Logout (8.1) belum ada.
- Jalur sesi bergantung pada `LocalStorageService.getCurrentUserId()`; bila sesi tidak ada, screen melempar `LocalStorageFailure`.
- Sejak 24 Sep, profil anak yang sudah tersimpan bisa **diubah/dihapus** dari layar Kelola Profil Anak (route `/baby/detail/:id`, dibuka dari daftar anak di layar Profil) — lihat Temuan #21.

---

## 2. 🏠 Dashboard

### 2.1 Dashboard Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/dashboard/presentation/screens/dashboard_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | **FR-06** |
| **Estimasi** | 5 jam |

**Elemen UI yang harus ada:**
- [x] **Header Card**: avatar bayi (`BabyAvatar`), nama anak, greeting dinamis `_getGreeting()` (Pagi/Siang/Sore/Malam), jenis kelamin
- [x] Usia bayi (X bulan Y hari) — ditampilkan di header card via `AgeCalculator.label`
- [x] Foto profil bayi dari `fotoProfilPath` via `BabyAvatar` (atau inisial Baloo 2 palet teal bila foto belum ada)
- [x] Shortcut ganti anak aktif langsung di header card via modal bottom sheet
- [x] **Next Vaccine Card**: vaksin `BELUM` pertama, deskripsi, badge "$daysLeft Hari Lagi", warna warning bila <7 hari; aman untuk bayi 18+ bulan (tidak crash bila semua vaksin selesai/terlewat)
- [x] **Quick Action Grid** (2x3 genap): Kalender, Tumbuh Kembang, Jurnal Sehat, ImuniBot, Direktori Faskes, Edukasi
- [x] **Growth Summary Card**: BB / TB / LK terakhir dari `growthProvider`
- [x] **BottomNavigationBar**: Home, Kalender, ImuniBot, Faskes, Profil (`AppBottomNavBar`)
- [x] Pull-to-refresh (`RefreshIndicator` → refresh state)
- [x] Empty state bila belum ada profil anak (`EmptyStateWidget` + tombol ke `/add-baby`)

> ✅ Dashboard menampilkan **bayi aktif** (`activeBabyProvider`), bukan lagi `babies.first`: anak bisa dipilih dari header card atau daftar di layar Profil & Pengaturan (Temuan #2).
> ✅ Sejak perbaikan 24 Sep, vaksin yang sudah lewat tanggal target otomatis berstatus `TERLEWAT` sehingga tidak lagi muncul di kartu "terdekat" dengan badge "Hari Ini" (Temuan #3).
> ✅ Bayi berusia 18+ bulan ditangani khusus agar ringkasan vaksin tetap rapi (Temuan #30).

---

## 3. 💉 Imunisasi & Kalender

> Logika `GenerateScheduleUseCase` (13 jadwal nasional) dan `ScheduleReminderUseCase` (notifikasi H-7 & H-1) sudah selesai & dipakai oleh 1.5. Seluruh layar imunisasi telah menggunakan Clean Architecture penuh.
>
> **Status jadwal (diperbaiki 24 Sep / Temuan #3):** status efektif dihitung **saat data dibaca** — jadwal `BELUM` yang tanggal targetnya sudah lewat menjadi `TERLEWAT` (`VaccineStatus.effective`). Normalisasi ada di `ImmunizationRepositoryImpl`, sehingga Kalender, Timeline, Dashboard, dan Detail menampilkan status yang sama. Isi Hive tidak diubah (tetap `BELUM`) agar bisa dievaluasi ulang setiap hari.

### 3.1 Calendar Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/immunization/presentation/screens/calendar_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | **FR-02** |
| **Estimasi** | 5 jam |

**Elemen UI yang harus ada:**
- [x] Kalender interaktif `table_calendar` dengan marker titik per tanggal vaksin (`markerBuilder`)
- [x] Warna marker: 🟢 Selesai (`green`) · 🔵 Terjadwal (`teal`) · 🔴 Terlewat (`red`)
- [x] List vaksin terfilter tanggal terpilih (`_selectedDay`)
- [x] **Filter status langsung**: saat chip Terjadwal/Selesai/Terlewat diklik, langsung menampilkan semua jadwal kategori tersebut tanpa terikat tanggal klik (`_selectedDay = null`)
- [x] Tombol auto-jump tanggal kalender saat klik "Lihat" pada jadwal mendatang
- [x] Chip filter: Semua / Terjadwal / Selesai / Terlewat
- [x] Tombol ke timeline list (ikon `Icons.list_alt` di AppBar → `/calendar/timeline`)
- [x] Tap item → `/calendar/detail/:id`
- [x] Empty state informatif via `EmptyStateWidget`

### 3.2 Vaccine Timeline List Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/immunization/presentation/screens/vaccine_timeline_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | **FR-02** |
| **Estimasi** | 3 jam |

**Elemen UI yang harus ada:**
- [x] Timeline vertical (rail + garis penghubung), urut `usiaBulanTarget` (0 bulan → 5 tahun)
- [x] Setiap item menggunakan `VaccineCard` (shared widget)
- [x] Status badge (`StatusBadge`) & usia target ("X Bln") per item
- [x] Ikon indikator rail: check hijau (selesai), close merah (terlewat), radio button unchecked (belum)
- [x] Tap item → VaccineDetailScreen (lewat link "Lihat Detail ›")

### 3.3 Vaccine Detail Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/immunization/presentation/screens/vaccine_detail_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | **FR-02** |
| **Estimasi** | 3 jam |

**Elemen UI yang harus ada:**
- [x] Info vaksin: nama, deskripsi, usia target
- [x] Tanggal target tertera jelas di kartu info
- [x] Status badge (`StatusBadge` seragam)
- [x] Tombol "Simpan & Selesaikan Imunisasi" → `updateStatus('SELESAI', realisasiDate: now, reaksi: catatan)`
- [x] **Pembatalan notifikasi**: memanggil `NotificationService.cancelNotification` untuk H-7 & H-1 saat vaksin selesai (Temuan #7)
- [x] Form catatan KIPI: suhu tubuh (number input), gejala (multi-select `ChoiceChip`: Demam, Bengkak, Rewel, Muntah, Ruam Merah), catatan bebas (wajib)
- [x] Tombol simpan otomatis menulis ke HealthJournal via `addHealthJournalUseCase` dengan `vaccineScheduleId` terisi, lalu `context.pop()`
- [x] Bila status sudah `SELESAI`, menampilkan tanggal realisasi dan catatan reaksi

---

## 4. 📈 Pertumbuhan & Jurnal Kesehatan

### 4.1 Growth Chart Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/growth/presentation/screens/growth_chart_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | **FR-04** |
| **Estimasi** | 5 jam |

**Elemen UI yang harus ada:**
- [x] Tab selector: Berat Badan / Tinggi Badan / Lingkar Kepala
- [x] Line chart (`fl_chart`) dengan titik data (`FlDotData`) untuk ketiga metrik
- [x] **Referensi baku WHO Child Growth Standards** (`WhoGrowthReference`): median garis solid hijau (`#16A34A`), rentang -2SD & +2SD garis putus-putus dengan shading area bawah 7% (Temuan #8)
- [x] Batas atas `maxY` dinamis (tidak terpotong bila data aktual > 23 kg)
- [x] Card statistik: pengukuran terakhir
- [x] AppBar Action "+ Tambah Pengukuran" (menggantikan FAB agar tidak menutupi catatan grafik)
- [x] Empty state informatif bila belum ada data

### 4.2 Add Growth Record Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/growth/presentation/screens/add_growth_record_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | **FR-04** |
| **Estimasi** | 2 jam |

**Elemen UI yang harus ada:**
- [x] DatePicker tanggal pengukuran dengan pembatasan `firstDate` ke `currentBaby.tanggalLahir` (tidak bisa memilih sebelum bayi lahir)
- [x] **Validasi cegah input duplikat per hari**: form memblokir input lebih dari 1 kali pada tanggal yang sama untuk bayi aktif + SnackBar peringatan (Temuan #31)
- [x] Number input: Berat Badan (kg), Tinggi Badan (cm), Lingkar Kepala (cm, opsional)
- [x] Validasi range normal: BB 0–30 kg, TB 0–120 cm, LK 0–60 cm
- [x] Tombol "Simpan Pengukuran" → `AddGrowthRecordUseCase` → snackbar sukses → `context.pop()`
- [x] Data tersimpan di Hive box via `GrowthRepositoryImpl` (Clean Architecture)

### 4.3 Health Journal List Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/health_journal/presentation/screens/journal_list_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | **FR-04** |
| **Estimasi** | 2 jam |

**Elemen UI yang harus ada:**
- [x] List jurnal diurutkan by date (terbaru di atas — descending)
- [x] Card jurnal: tanggal, isi catatan, chip gejala, badge suhu (merah bila ≥37,5 °C)
- [x] **Swipe to delete aman**: `Dismissible` dengan `ValueKey(item.journalId)` unik, penanganan `confirmDismiss` asinkron aman, dan sinkron state removal (Temuan #32)
- [x] AppBar Action "+ Tambah Jurnal" (menggantikan FAB)
- [x] Empty state bila belum ada catatan

### 4.4 Add Health Journal Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/health_journal/presentation/screens/add_journal_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | **FR-04** |
| **Estimasi** | 3 jam |

**Elemen UI yang harus ada:**
- [x] DatePicker tanggal kejadian
- [x] Master gejala KIPI & kesehatan dari `health_gejala.dart` (`HealthGejalaMaster.daftarGejala`)
- [x] Number input suhu tubuh (validasi 35–42 °C)
- [x] Multi-select chip gejala
- [x] TextArea catatan bebas (wajib diisi)
- [x] Tombol "Simpan Catatan Jurnal" → `AddHealthJournalUseCase` via `journalProvider` (Clean Architecture)

---

## 5. 📚 Edukasi

> **Selesai dikodekan 24 September 2026** (kode + `flutter analyze` bersih + `flutter build apk --debug` berhasil; belum ada catatan uji di device).
> Konten dibaca dari `EducationMockDatasource` (hardcoded — sesuai dev plan §1.1 `education_mock_datasource.dart # [UTS] hardcoded mock`), dan skor kuis dipersist ke Hive CE.

**Layer implementasi (FR-05):**

| Layer | File |
|-------|------|
| Data — datasource | `data/datasources/education_mock_datasource.dart` (+ `EducationKategori` untuk chip filter) |
| Data — model | `data/models/{article,video,quiz}_model.dart` (konten, non-Hive) · `data/models/quiz_score_model.dart` (Hive `typeId: 5`) + `.g.dart` |
| Presentation — provider | `presentation/providers/education_provider.dart` |
| Presentation — widget | `presentation/widgets/education_thumbnail.dart` · `education_kategori_badge.dart` |
| Presentation — screen | `education_hub_screen.dart` · `article_detail_screen.dart` · `quiz_screen.dart` |
| Test | `test/education_test.dart` — 11 test (filter kategori, lookup by id, artikel terkait, validasi struktur soal, persentase skor) |

### 5.1 Education Hub Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/education/presentation/screens/education_hub_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | **FR-05** |
| **Estimasi** | 4 jam |

**Elemen UI yang harus ada:**
- [x] Tab: Artikel · Video · Kuis (`DefaultTabController` + `TabBar`)
- [x] **Artikel**: Card list (thumbnail, kategori, judul, ringkasan, estimasi baca)
- [x] **Video**: Thumbnail grid 2 kolom + badge durasi (`mainAxisExtent` dipatok agar tidak overflow di layar sempit), tap → YouTube **intent eksternal** via `url_launcher`
- [x] **Kuis**: List kuis dengan badge "Mulai" atau badge hijau "✓ persentase" bila sudah dikerjakan
- [x] Chip filter kategori: **Semua** · Imunisasi · Nutrisi · Tumbuh Kembang · MPASI
- [x] Empty state khusus per tab bila filter tidak menghasilkan konten

**Catatan implementasi:**
- Chip filter dipakai **bersama** oleh tab Artikel, Video, dan Kuis lewat `educationKategoriProvider` (`StateProvider`) agar terasa konsisten.
- Video membuka **pencarian YouTube berdasarkan judul**, bukan URL video tertentu, karena tim belum punya video yang di-host (UAS: ganti ke URL CMS). Pilihan ini menghindari tautan mati saat demo.
- Belum memakai InAppWebView — `webview_flutter` tidak ada di pubspec dev plan §7.
- **Tombol kembali selalu tersedia** di AppBar: dari Dashboard layar ini dibuka dengan `push` sehingga `pop()` mengembalikan ke Dashboard; bila dibuka tanpa riwayat (deep link) tombolnya mengarah ke Dashboard. Diperbaiki 24 Sep — sebelumnya layar ini buntu karena dibuka dengan `go` pada route top-level.

---

### 5.2 Article Detail Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/education/presentation/screens/article_detail_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | **FR-05** |
| **Estimasi** | 2 jam |

**Elemen UI yang harus ada:**
- [x] Hero image artikel (dengan fallback gradien + ikon bila gambar gagal dimuat/offline)
- [x] Judul, kategori, tanggal publish (format Indonesia via `DateFormatter`), estimasi baca, plus nama penulis
- [x] Body artikel dirender `flutter_html` (`Html` dengan style kustom untuk `body`, `h3`, `p`, `ul`, `li`)
- [x] Tombol share artikel (ikon `share_outlined` di AppBar) — **menyalin info artikel ke clipboard** + snackbar
- [x] Related articles di bawah artikel (kategori sama diprioritaskan, lalu dilengkapi artikel lain)
- [x] Penanganan id artikel tidak dikenal (menampilkan pesan "Artikel tidak ditemukan")

**Catatan implementasi:** share memakai `Clipboard` karena `share_plus` tidak ada di pubspec dev plan §7 dan konten masih mock (belum ada URL publik artikel). Terkait Temuan #13.

---

### 5.3 Quiz Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/education/presentation/screens/quiz_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | **FR-05** |
| **Estimasi** | 4 jam |

**Elemen UI yang harus ada:**
- [x] Progress bar soal (`LinearProgressIndicator` + label "Soal 3/5")
- [x] Pertanyaan + 4 pilihan jawaban (single select, label A–D)
- [x] Feedback langsung setelah jawab: ✅ Benar / ❌ Salah + penjelasan (plus jawaban benar bila salah)
- [x] Layar hasil akhir: skor persentase, jumlah benar/salah, badge **Excellent 🏆** (≥80) / **Good 👍** (≥60) / **Keep Trying 💪**, tombol "Coba Lagi" + "Kembali ke Edukasi"
- [x] Simpan skor ke lokal → **Hive CE `QuizScoreModel` (`typeId: 5`)** lewat `quizScoresProvider`

**Catatan implementasi:**
- Satu soal hanya dihitung sekali (tap berulang setelah menjawab diabaikan), dan tombol "Lanjut" baru aktif setelah user memilih.
- Skor disimpan **saat menekan "Lihat Hasil"** di soal terakhir; `QuizScoreModel` kini mencatat **`attemptCount` (jumlah percobaan) dan `riwayatSkor` (daftar nilai per percobaan)** sehingga perkembangan user tidak hilang (Temuan #15 ✅).

---

## 6. 🏥 Direktori Faskes

> **Selesai dikodekan 25 September 2026.** `flutter analyze` bersih. Belum ada catatan uji device.

**Layer implementasi:**

| Layer | File |
|-------|------|
| Model | `faskes/data/models/faskes_model.dart` — plain Dart class (id, nama, tipe, alamat, kota, telepon, lat, lng, jamOperasional) |
| Datasource | `faskes/data/datasources/faskes_mock_datasource.dart` — 14 faskes, 3 kota (Jakarta/Bandung/Surabaya), 4 tipe (RS/Puskesmas/Klinik/Apotek) |
| Provider | `faskes/presentation/providers/faskes_provider.dart` — `faskesDatasourceProvider`, `faskesTipeProvider` (StateProvider), `faskesListProvider` |
| Screen | `faskes/presentation/screens/faskes_screen.dart` |
| Peta | OpenStreetMap via `flutter_map: ^7.0.2` + `latlong2: ^0.9.1` — **tanpa API key, gratis** |

### 6.1 Faskes Directory Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/faskes/presentation/screens/faskes_screen.dart` |
| **Status** | 🧪 Perlu Testing (kode selesai, belum uji device) |
| **FR Terkait** | **FR-03** |
| **Estimasi** | 3 jam (aktual: ~3 jam) |

**Elemen UI yang tersedia:**
- [x] SearchBar filter nama/kota/alamat faskes
- [x] Chip filter tipe scrollable horizontal (Semua / RS / Puskesmas / Klinik / Apotek)
- [x] ListView kartu faskes: nama, badge tipe berwarna, alamat, telepon tappable (`url_launcher tel:`), tombol "Navigasi 🗺️"
- [x] **Tab Peta**: `FlutterMap` OpenStreetMap, marker berwarna per tipe (RS=teal, Puskesmas=green, Klinik=coral, Apotek=yellow)
- [x] Tap marker/kartu → bottom sheet detail (nama, tipe, alamat, telepon, jam operasional, tombol "Buka di Maps")
- [x] Tombol "Buka di Maps" → `url_launcher geo:lat,lng` fallback ke `maps.google.com`
- [x] Mock data 14 faskes dari 3 kota
- [x] Empty state dengan tombol Reset Filter
- [x] Bottom nav index 3 (Faskes)

**Catatan implementasi:**
- Tidak memakai Google Maps/API berbayar — murni OpenStreetMap (tile server publik OSM).
- Kartu `FaskesScreen` di Dashboard menggunakan `context.go` (bukan `push`) karena ini tab utama.
- File target awalnya `faskes_directory_screen.dart` (dev plan lama) → diubah menjadi `faskes_screen.dart` agar konsisten dengan pola penamaan screen lain.

---

## 7. 🤖 AI Chatbot

> **Selesai dikodekan 25 September 2026.** `flutter analyze` bersih. Belum ada catatan uji device.

**Layer implementasi:**

| Layer | File |
|-------|------|
| Model | `chatbot/data/models/chat_message_model.dart` — plain Dart class (id UUID, text, isUser, timestamp); in-memory, tidak pakai Hive |
| Datasource | `chatbot/data/datasources/chatbot_mock_datasource.dart` — **31 keyword group** (semua 13 vaksin nasional + topik umum); delay simulasi 300–700ms |
| Provider | `chatbot/presentation/providers/chatbot_provider.dart` — `ChatState` (messages + isLoading), `ChatNotifier` (StateNotifier), `chatProvider`, `chatbotDatasourceProvider` |
| Screen | `chatbot/presentation/screens/chatbot_screen.dart` |

### 7.1 Chatbot Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/chatbot/presentation/screens/chatbot_screen.dart` |
| **Status** | 🧪 Perlu Testing (kode selesai, belum uji device) |
| **FR Terkait** | **FR-07** |
| **Estimasi** | 4 jam (aktual: ~4 jam) |

**Elemen UI yang tersedia:**
- [x] AppBar bergaya: CircleAvatar bot (coral) + judul Baloo 2 "ImuniBot" + subtitle "Asisten Imunisasi & Parenting"
- [x] Chat bubble: user (kanan, teal, border-radius 18/4/18/18) + bot (kiri, cream + avatar 🤖, border-radius 4/18/18/18)
- [x] Timestamp HH:mm di bawah setiap bubble
- [x] **Typing indicator**: 3 titik animasi bounce staggered 200ms saat bot "memproses"
- [x] Input bar: TextField multiline + tombol send CircleAvatar teal (disabled saat kosong/loading)
- [x] **Suggested questions** 5 ActionChip di welcome state (saat riwayat kosong)
- [x] Tombol "Hapus Percakapan" (ikon trash di AppBar) + `ConfirmDialog` konfirmasi
- [x] Terhubung ke `ChatbotMockDatasource` (**31 keyword group**)
- [x] Scroll otomatis ke bawah via `ref.listen` (hanya saat pesan baru/loading berubah)
- [x] Bottom nav index 2 (ImuniBot)

**Catatan implementasi:**
- State in-memory (`ChatState`) — riwayat chat tidak di-persist ke Hive karena tidak ada kebutuhan riwayat lintas sesi di UTS.
- Keyword datasource mencakup semua 13 vaksin nasional sesuai dev plan §5 + topik umum (MPASI, stunting, posyandu, alergi, booster, halal/aman, dll).
- `_TypingIndicator` menggunakan `AnimationController` staggered — 3 controller independen dengan delay 0/200/400ms.
- Dashboard kartu "ImuniBot 🤖" dibuka dengan `context.go` (bukan `push`) karena sekarang tab utama bottom nav.

---

## 8. ⚙️ Settings & Profile

> **Selesai dikodekan 24 September 2026** (kode + `flutter analyze` bersih + `flutter build apk --debug` berhasil; belum ada catatan uji device).
> Sejak layar ini ada, alur demo bisa di-*reset* sendiri lewat tombol **Keluar** — tidak lagi memerlukan `adb shell pm clear`.

**Layer implementasi:**

| Layer | File |
|-------|------|
| Presentation — provider | `auth/presentation/providers/auth_provider.dart` — `CurrentUserNotifier` (`AsyncNotifier<UserModel?>`) & `NotificationPrefNotifier` (`AsyncNotifier<bool>`) |
| Presentation — screen | `auth/presentation/screens/settings_screen.dart` |
| Komponen global | `lib/widgets/confirm_dialog.dart` (`ConfirmDialog.show(...)`) |
| Core | `LocalStorageService.{clearSession,setCurrentUserName,isNotificationEnabled,setNotificationEnabled}` · `AppConstants.{prefNotificationsEnabled,appVersion}` |
| Test | `test/settings_test.dart` — 11 test (sesi/prefs, `CurrentUserProvider` + Hive, `ConfirmDialog`) |

### 8.1 Settings / Profile Screen
| Detail | Keterangan |
|--------|-----------|
| **File** | `lib/features/auth/presentation/screens/settings_screen.dart` |
| **Status** | ✅ Selesai (kode) |
| **FR Terkait** | - |
| **Estimasi** | 2 jam |

**Elemen UI yang harus ada:**
- [x] Avatar pengguna + nama + email (plus nomor HP & kota)
- [x] Daftar bayi yang terdaftar + tombol "+ Tambah Bayi"
- [x] Edit profil pengguna (bottom sheet form dengan validasi nama/email/HP/kota)
- [x] Toggle notifikasi on/off
- [x] Tombol "Keluar" (hapus session SharedPreferences: `is_logged_in`, `user_id`, `user_name`) + dialog konfirmasi
- [x] Versi aplikasi (`1.0.0+1`)
- [x] Bottom navigation (index 4) agar bisa kembali ke tab lain + pull-to-refresh

**Catatan implementasi:**
- **Keluar** hanya menghapus **sesi**; seluruh data domain (bayi, jadwal, pertumbuhan, jurnal) tetap tersimpan. Key `seen_onboarding` sengaja tidak dihapus agar user langsung diarahkan ke Login, bukan mengulang Onboarding.
- **Sunting profil** menolak email yang sudah dipakai akun lain, karena `LoginScreen` mencocokkan akun berdasarkan email (duplikat akan membuat login ambigu).
- **Toggle notifikasi** berefek nyata dua arah: saat dimatikan → `cancelAllNotifications()` dipanggil dan `ScheduleReminderUseCase` berhenti menjadwalkan; saat dinyalakan → pengingat H-7/H-1 untuk seluruh jadwal `BELUM` didaftarkan ulang (jumlahnya ditampilkan di snackbar). Bila izin alarm/notifikasi OS ditolak, preferensi tetap tersimpan dan user diberi pesan error.
- Kartu bayi menampilkan foto (bila tersedia), usia (`AgeCalculator`), jenis kelamin, dan **progres imunisasi `x/13`** dari `immunizationProvider`.
- Versi aplikasi dibaca dari `AppConstants.appVersion` (hardcode, disamakan manual dengan pubspec) — lihat Temuan #20.

---

## 🧩 Komponen UI Global (Shared Widgets)

Folder `lib/widgets/` kini berisi **10 dari 10 (100%)** komponen bersama yang direncanakan. Seluruh screen telah direfaktor untuk memanfaatkan widget bersama ini guna menjamin konsistensi UI/UX dan mengeliminasi duplikasi:

| Komponen | File | Status | Keterangan & Penggunaan |
|----------|------|--------|--------------------------|
| AppBottomNavBar | `widgets/app_bottom_nav_bar.dart` | ✅ Selesai | Bottom navigation bar 5 tab konsisten: Home, Kalender, ImuniBot, Faskes, Profil |
| BabyAvatar | `widgets/baby_avatar.dart` | ✅ Selesai | Avatar anak seragam; mendukung foto lokal galeri dengan fallback inisial nama anak (font Baloo 2, warna teal) |
| ConfirmDialog | `widgets/confirm_dialog.dart` | ✅ Selesai | Dialog konfirmasi modal untuk aksi destruktif (Keluar akun, hapus data bayi, hapus percakapan) |
| CustomTextField | `widgets/custom_text_field.dart` | ✅ Selesai | Input teks bergaya neo-brutalism dengan label, hint, keyboardType, dan validasi |
| EmptyStateWidget | `widgets/empty_state_widget.dart` | ✅ Selesai | Tampilan placeholder informatif dengan ikon, judul, pesan, dan tombol aksi opsional |
| ErrorStateWidget | `widgets/error_state_widget.dart` | ✅ Selesai | Tampilan penanganan error seragam dengan pesan deskriptif dan tombol Retry |
| LoadingOverlay | `widgets/loading_overlay.dart` | ✅ Selesai | Modal overlay loading dengan indikator berputar saat proses asinkron berjalan |
| SectionHeader | `widgets/section_header.dart` | ✅ Selesai | Header seksi konsisten berfont Baloo 2 dan subtitle Poppins di seluruh fitur |
| StatusBadge | `widgets/status_badge.dart` | ✅ Selesai | Badge status warna-warni untuk status imunisasi, chip kategori, dan pill ringkasan |
| VaccineCard | `widgets/vaccine_card.dart` | ✅ Selesai | Kartu informasi vaksinasi reusable dengan nama vaksin, usia target, deskripsi, dan trailing badge |

---

## 🚨 Temuan & Kesenjangan Teknis

> **Status per 29 Sep 2026**: Seluruh temuan gap teknis prioritas (#1–#11, #15–#17, #21–#27, dan #28–#33) telah selesai diimplementasikan (**✅ Selesai**).

| # | Temuan | Dampak | Status & Solusi |
|---|--------|--------|-----------------|
| 1 ✅ | `widgets/` kosong; pola UI diulang di banyak screen | Duplikasi kode | **Selesai 25 Sep:** 10 komponen bersama dibuat lengkap di `lib/widgets/` dan diintegrasikan ke seluruh screen (`test/global_widgets_test.dart`) |
| 2 ✅ | Semua screen memakai `babies.first` | Anak ke-2 dst. tidak bisa dipantau | **Selesai 24 Sep:** `activeBabyProvider` dengan persistensi SharedPreferences dan fallback otomatis; terpasang di seluruh screen |
| 3 ✅ | Status `TERLEWAT` tidak pernah di-*set* | Filter & marker merah tidak muncul | **Selesai 24 Sep:** evaluasi status efektif `VaccineStatus.effective` saat data dibaca di `ImmunizationRepositoryImpl` tanpa merusak data Hive |
| 4 ✅ | Nama box Hive di provider hardcode | Inkonsistensi storage key | **Selesai 24 Sep:** seluruh nama box dipusatkan ke `AppConstants` |
| 5 ✅ | String literal sesi auth di berbagai file | Risiko typo | **Selesai 24 Sep:** seluruh literal key diganti konstanta `AppConstants` |
| 6 ✅ | `NotificationService._onNotificationTap` kosong | Ketukan notifikasi tidak buka screen | **Selesai 25 Sep:** navigasi otomatis ke `/calendar/detail/$scheduleId`, penanganan cold start payload, dan fallback exact alarm |
| 7 ✅ | `cancelNotification` per-jadwal belum dipanggil | Pengingat tetap muncul walau vaksin selesai | **Selesai 25 Sep:** `immunization_provider.dart` membatalkan H-7 & H-1 saat jadwal diubah ke `SELESAI` via `NotificationService.cancelNotification` |
| 8 ✅ | Grafik pertumbuhan hanya 1 garis statis | Standar WHO tidak akurat | **Selesai 25 Sep:** integrasi tabel baku `WhoGrowthReference` (Median solid hijau, -2SD & +2SD putus-putus dengan shading area) |
| 9 ✅ | Belum ada unit test use case / widget test | Risiko regresi | **Selesai 24–29 Sep:** 15 file test dengan **168 test lulus** (`flutter test`) mencakup use case, datasource, widgets, dan model |
| 10 ✅ | `README.md` masih boilerplate Flutter | Informasi onboarding tim hilang | **Selesai 25 Sep:** penulisan dokumentasi lengkap `README.md` (arsitektur, fitur, prasyarat, testing, release) |
| 11 ✅ | Flag `reminderH7Sent`/`reminderH1Sent` tidak pernah disimpan | Notifikasi bisa dobel dijadwalkan | **Selesai 25 Sep:** `ScheduleReminderUseCase` memvalidasi dan memperbarui flag ke Hive lewat repository |
| 12 🌐 | Inkompatibilitas `flutter_html` 3.0.0 dengan `html` ≥ 0.15.7 | Build/test gagal bila override hilang | **Mitigasi terpasang:** `dependency_overrides: html: 0.15.6` aktif dan terdokumentasi di `pubspec.yaml` |
| 13 | Tombol share artikel menyalin ke clipboard | Belum berbagi link URL publik | Tetap clipboard untuk fase UTS; disiapkan migrasi `share_plus` di UAS |
| 14 | Konten edukasi & faskes masih mock hardcoded | Butuh koneksi CMS/backend | Sesuai scope UTS lokal; disiapkan API remote di UAS |
| 15 ✅ | Skor kuis menimpa percobaan sebelumnya | Riwayat nilai hilang | **Selesai 25 Sep:** penambahan `attemptCount` dan `riwayatSkor` di `QuizScoreModel` (`typeId: 5`) |
| 16 ✅ | Bottom navigation belum selaras | Faskes & Chatbot tidak ada di nav | **Selesai 25 Sep:** tab bawah diubah menjadi Home · Kalender · ImuniBot · Faskes · Profil |
| 17 ✅ | Slot grid dashboard ganjil (5 kartu) | UI tidak simetris | **Selesai 25 Sep:** grid dirapikan menjadi 6 kartu genap 2×3 |
| 18 | Peringatan versi AGP / Gradle pada build log | Potensi deprecation AGP di masa depan | Jadwalkan upgrade AGP/Gradle di fase UAS |
| 19 🔶 | Preferensi notifikasi per-perangkat | Logout tidak batalkan notif | **Sebagian selesai:** `logout()` memanggil `cancelAllNotifications()`. Preferensi multi-akun disempurnakan di UAS |
| 20 🌐 | Versi app hardcoded di `AppConstants` | Drift versi | Mitigasi komentar silang terpasang di `pubspec.yaml` |
| 21 ✅ | Belum ada UI kelola (ubah/hapus) profil anak | Data bayi tidak bisa diedit | **Selesai 24 Sep:** screen `baby_detail_screen.dart` dengan hitung ulang jadwal & cascade delete |
| 22 ✅ | Lapisan Clean Arch domain auth belum ada | Akses Hive langsung di screen | **Selesai 25 Sep:** domain entity, repo, 6 use cases, dan local datasource selesai dibuat & didaftarkan ke DI |
| 23 ✅ | Filter kalender menampilkan semua jadwal tanpa tanggal | Tidak bisa lihat jadwal per tanggal | **Selesai 25 Sep:** filter tanggal dan empty state informatif |
| 24 ✅ | Detail vaksin selesai tidak tampilkan tanggal realisasi | Info KIPI hilang setelah selesai | **Selesai 25 Sep:** kartu status selesai menampilkan tanggal & catatan reaksi |
| 25 ✅ | Greeting dashboard statis "Selamat Pagi!" | Tidak sesuai waktu nyata | **Selesai 25 Sep:** greeting dinamis Pagi/Siang/Sore/Malam berdasarkan jam |
| 26 ✅ | FAB Growth & Journal memakai `context.go` | Tombol kembali hilang di sub-screen | **Selesai 25 Sep:** diubah ke `context.push` |
| 27 ✅ | Bottom nav salah terpasang di Growth & Journal | Sub-screen menampilkan nav tab | **Selesai 25 Sep:** bottom nav dihapus dari kedua sub-screen |
| 28 ✅ | Clean Architecture Growth & Health Journal belum ada | Akses Hive langsung di provider | **Selesai 25 Sep:** domain entity, repo interface, use cases, datasource, dan repo impl lengkap di DI |
| 29 ✅ | Penolakan exact alarm di Android 12+ gagalkan pengingat | Notifikasi gagal senyap | **Selesai 25 Sep:** `NotificationService` menerapkan fallback otomatis ke inexact alarm bila izin ditolak |
| 30 ✅ | Bayi 18+ bulan memicu error/kosong di kartu vaksin Dashboard | UI tidak menangani usia >18 bln | **Selesai 25 Sep:** penanganan khusus di `dashboard_screen.dart` + `test/dashboard_old_baby_test.dart` |
| 31 ✅ | Pengukuran tumbuh kembang bisa diinput berkali-kali di hari sama | Data redundan di tanggal sama | **Selesai 29 Sep:** form memvalidasi 1 input per tanggal per bayi + batasan tanggal lahir |
| 32 ✅ | Red screen error saat swipe-to-delete jurnal | Crash UI saat hapus via slider | **Selesai 29 Sep:** `Dismissible` memakai `ValueKey` unik, konfirmasi aman, dan sinkron state removal |
| 33 ✅ | Belum ada pengujian otomatis di repository Git | Risiko regresi commit | **Selesai 25 Sep:** pipeline CI GitHub Actions (`.github/workflows/ci.yaml`) aktif pada setiap push/PR |

---

## 🚦 Checklist Demo UTS

**Sudah tersedia di kode** (✅ = kode selesai, analyze bersih, 168 test lulus):

- [x] Splash screen tampil dan navigasi otomatis (layout two-zone, confetti dots)
- [x] Onboarding bisa di-swipe dan di-skip (neo-brutalism, warna cerah tema slide)
- [x] Register & Login tersimpan lokal via Clean Architecture UseCase
- [x] Profil bayi bisa ditambahkan *(device)*
- [x] Profil bayi bisa **diubah & dihapus** (cascade delete jadwal, pertumbuhan, jurnal)
- [x] Anak kedua/berikutnya bisa dipilih sebagai **anak aktif** (header & profil)
- [x] Jadwal imunisasi otomatis terbentuk setelah tambah bayi (13 vaksin nasional)
- [x] Dashboard menampilkan vaksin terdekat, ringkasan pertumbuhan, grid 2x3, dan aman untuk bayi 18+ bulan
- [x] Kalender interaktif `table_calendar` dengan marker 🟢🔵🔴 dan filter langsung kategori status
- [x] Status vaksin terlewat terdeteksi otomatis (`TERLEWAT`) di Kalender, Timeline, Dashboard, & Detail
- [x] Status vaksin bisa diubah ke "Selesai", mencatat KIPI ke jurnal, dan membatalkan notifikasi terjadwal
- [x] Grafik pertumbuhan (`fl_chart`) dengan garis standar baku WHO Child Growth Standards (Median, -2SD, +2SD)
- [x] Form pertumbuhan memvalidasi 1x per tanggal dan membatasi tanggal sebelum lahir
- [x] Jurnal kesehatan bisa ditambah, dilihat, dan dihapus via slider aman
- [x] Education Hub menampilkan artikel, video (YouTube), & kuis interaktif
- [x] Kuis bisa dikerjakan & menyimpan riwayat attempts ke Hive CE
- [x] Chatbot ImuniBot merespons 31 keyword dengan bubble chat, typing indicator, dan suggested chips
- [x] Direktori Faskes menampilkan 14 faskes mock di peta OpenStreetMap (`flutter_map`) + tombol telepon/navigasi
- [x] Seluruh 10 Shared Global Widgets terintegrasi seragam di semua layar
- [x] Tab **Profil** membuka layar Profil & Pengaturan (edit profil, toggle notifikasi, daftar anak, versi, keluar)
- [x] Tombol **Keluar** berfungsi (sesi dihapus → diarahkan ke Login, data tetap aman di Hive)
- [x] Pipeline CI GitHub Actions otomatis menguji kode (`analyze` & `test`)
- [x] Seluruh **168 unit & widget test lulus** (`flutter test`)

---

## 📝 Catatan Tim

| Tanggal | Update |
|---------|--------|
| 15 Sep 2026 | Dokumen progress dibuat. Setup awal dimulai dari Sprint 0 (GoRouter, ProviderScope, AppTheme, NotificationService, Workmanager, Hive.init). |
| 15 Sep 2026 | Splash Screen, Onboarding, Login, dan Register selesai dengan layout two-zone dan validasi lengkap. |
| 16 Sep 2026 | Struktur folder Clean Architecture awal disiapkan. |
| 17 Sep 2026 | **1.5 Add Baby Screen selesai** dan diverifikasi di device fisik: profil bayi tersimpan & 13 jadwal imunisasi terbentuk otomatis. |
| 22 Sep 2026 | Sprint 2 & 3 masuk (Dashboard, Kalender table_calendar, Timeline, Detail Vaksin, Grafik Pertumbuhan fl_chart, Jurnal Kesehatan). Hive registrar menjadi 5 adapter. |
| 24 Sep 2026 | **Fitur Edukasi (FR-05)** selesai: Hub 3 tab, Article Detail (flutter_html), Quiz Screen + Hive QuizScoreModel (`typeId: 5`). Registrar jadi 6 adapter. Pin `dependency_overrides: html: 0.15.6`. |
| 24 Sep 2026 | **Profil & Pengaturan (8.1)** selesai: edit profil, toggle notifikasi, info versi, dialog konfirmasi Keluar. |
| 24 Sep 2026 | **Perbaikan gap prioritas 1 (#3)**: status TERLEWAT dinormalisasi on-read di domain & repository. |
| 24 Sep 2026 | **Kelola Profil Anak (#21) & Bayi Aktif (#2)**: screen `baby_detail_screen.dart`, cascade delete, hitung ulang jadwal, `activeBabyProvider`. |
| 24 Sep 2026 | **Unit test use case inti (#9)**: 16 test di `schedule_usecase_test.dart` (GenerateSchedule, NotificationHelper, ScheduleReminder). |
| 25 Sep 2026 | **Direktori Faskes (FR-03) & AI Chatbot (FR-07)** selesai: OpenStreetMap via `flutter_map`, chatbot 31 keyword, bottom nav diperbarui ke 5 tab utama. 0 placeholder tersisa. |
| 25 Sep 2026 | **+9 Global Shared Widgets (Commit `27463e9`)**: 10/10 komponen bersama di `lib/widgets/` selesai dibuat dan diintegrasikan ke seluruh 19+ screen. Ditambahkan `test/global_widgets_test.dart`. |
| 25 Sep 2026 | **Major 20+ Bugs Fix & Clean Architecture Overhaul (Commit `8b777b6`)**: Penerapan Clean Arch menyeluruh pada Auth, Growth, dan Health Journal; 30 DI providers di registry; standar pertumbuhan WHO (`who_growth_reference.dart`); tap notifikasi & inexact fallback; cancel notifikasi; flag anti-duplikasi; riwayat kuis; README komprehensif; CI GitHub Actions. |
| 25 Sep 2026 | **Fix Bayi 18+ Bulan di Dashboard (Commit `76e1dd3`)**: Penanganan kartu vaksin untuk bayi berusia > 18 bulan agar tidak crash/error. Ditambahkan `test/dashboard_old_baby_test.dart`. |
| 29 Sep 2026 | **Bug Fixes & Refactoring (Commit `280d58c` & `629dae6`)**: Validasi form pengukuran bayi (1x per tanggal & batas tanggal lahir); fix crash red screen swipe-to-delete jurnal (`ValueKey`); filter langsung kategori status pada kalender tanpa terikat tanggal klik + clean code; perbaikan warna ikon onboarding ke palet cerah tema; penyelarasan warna status `BELUM` kuning + update test `vaccine_status_test.dart`. |
| 29 Sep 2026 | **Verifikasi Akhir**: `flutter analyze` → **No issues found!** · `flutter test` → **168/168 test lulus (15 file test)**. Seluruh dokumen perencanaan dan progress disinkronkan 100% dengan kondisi kode terkini. |

---

*Update dokumen ini setiap ada perubahan status. Alur status: ⬜ Belum Mulai → 🔄 In Progress → 🧪 Perlu Testing (kode selesai, belum diuji di device) → ✅ Selesai (sudah lolos uji device).*
