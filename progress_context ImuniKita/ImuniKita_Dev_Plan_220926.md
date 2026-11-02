# 📋 ImuniKita — Dokumen Perencanaan Pengembangan Mobile App
### Fase UTS (Prototipe Frontend Lokal) → UAS (Offline-First + Firebase)
> **Stack**: Flutter · Riverpod · Hive CE DB · flutter_local_notifications · go_router
> **Tim**: TrioEmpat | **Terakhir diperbarui**: 29 September 2026

---

## 1. 🏛️ Rekomendasi Arsitektur: Clean Architecture + Repository Pattern

### Filosofi Inti
Tujuan utama arsitektur ini adalah **memisahkan UI dari sumber data (data source)**. Pada fase UTS, data source adalah Hive CE (lokal). Pada fase UAS, data source ditambahkan Firebase/REST API. **Lapisan UI tidak perlu diubah sama sekali.**

```
┌─────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                  │
│  (Screens, Widgets, Riverpod Providers/Notifiers)   │
└──────────────────────┬──────────────────────────────┘
                       │ calls
┌──────────────────────▼──────────────────────────────┐
│                   DOMAIN LAYER                       │
│  (Use Cases / Interactors, Abstract Repositories,   │
│   Entity Models — PURE DART, zero Flutter imports)  │
└──────────────────────┬──────────────────────────────┘
                       │ implements
┌──────────────────────▼──────────────────────────────┐
│                    DATA LAYER                        │
│  (Repository Impl, Data Sources, DTOs/Adapters)     │
│                                                     │
│  [UTS]  LocalDataSource (Hive CE)                   │
│  [UAS]  + RemoteDataSource (Firebase / REST API)    │
└─────────────────────────────────────────────────────┘
```

### 1.1 Struktur Folder Lengkap

```
lib/
├── main.dart                       # Bootstrap Hive, Timezone, NotificationService, Workmanager, ProviderScope
├── app/
│   ├── app.dart                    # Root widget (MaterialApp.router, NotificationService.setRouter)
│   ├── app_version_provider.dart   # App version provider via PackageInfo / constants
│   ├── router/
│   │   └── app_router.dart         # GoRouter configuration (20 routes, 0 placeholder)
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_text_styles.dart
│
├── core/
│   ├── constants/
│   │   ├── vaccine_schedule.dart   # Data master 13 jadwal imunisasi nasional
│   │   ├── app_constants.dart      # Hive box names, shared prefs keys, reminder hours
│   │   ├── who_growth_reference.dart # Referensi WHO Child Growth Standards (BB, TB, LK ±2SD & Median)
│   │   └── health_gejala.dart      # Daftar master gejala KIPI & kesehatan anak
│   ├── errors/
│   │   └── failures.dart           # Failure hierarchy
│   ├── utils/
│   │   ├── age_calculator.dart     # Hitung usia dalam bulan & format label
│   │   ├── date_formatter.dart
│   │   └── notification_helper.dart # Helper kalkulasi tanggal & ID pengingat H-7/H-1
│   └── services/
│       ├── notification_service.dart # Local notifications service + tap navigation + inexact alarm fallback
│       └── local_storage_service.dart  # SharedPreferences session wrapper
│
├── features/
│   │
│   ├── auth/                       # [UTS: local auth + Clean Arch] [UAS: Firebase Auth]
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_local_datasource.dart    # ✅ Local Hive & SharedPreferences data source
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart               # ✅ Hive @HiveType(typeId: 0)
│   │   │   │   └── user_model.g.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart     # ✅ IAuthRepository implementation
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart              # ✅ Pure Dart entity
│   │   │   ├── repositories/
│   │   │   │   └── i_auth_repository.dart        # ✅ Abstract interface
│   │   │   └── usecases/
│   │   │       ├── auth_state_usecase.dart       # ✅ CheckAuthStateUseCase & MarkOnboardingSeenUseCase
│   │   │       ├── get_current_user_usecase.dart # ✅
│   │   │       ├── login_usecase.dart            # ✅
│   │   │       ├── logout_usecase.dart           # ✅
│   │   │       ├── register_usecase.dart         # ✅
│   │   │       └── update_profile_usecase.dart   # ✅
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart            # ✅ currentUserProvider + notificationEnabledProvider
│   │       ├── screens/
│   │       │   ├── splash_screen.dart            # ✅
│   │       │   ├── onboarding_screen.dart        # ✅
│   │       │   ├── login_screen.dart             # ✅
│   │       │   ├── register_screen.dart          # ✅
│   │       │   └── settings_screen.dart          # ✅ (Profil & Pengaturan, ganti akun, logout)
│   │       ├── widgets/
│   │       │   ├── app_logo_pill.dart
│   │       │   ├── confetti_dots_painter.dart
│   │       │   └── neo_button.dart
│   │       └── utils/
│   │           ├── auth_validators.dart
│   │           └── snackbar_helper.dart
│   │
│   ├── baby_profile/               # FR-01 [✅ Clean Architecture lengkap]
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── baby_local_datasource.dart    # ✅ Hive CE CRUD
│   │   │   ├── models/
│   │   │   │   ├── baby_model.dart               # ✅ Hive @HiveType(typeId: 1)
│   │   │   │   └── baby_model.g.dart
│   │   │   └── repositories/
│   │   │       └── baby_repository_impl.dart     # ✅
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── baby_entity.dart              # ✅
│   │   │   ├── repositories/
│   │   │   │   └── i_baby_repository.dart        # ✅
│   │   │   └── usecases/
│   │   │       ├── add_baby_usecase.dart         # ✅
│   │   │       ├── get_babies_usecase.dart       # ✅
│   │   │       ├── update_baby_usecase.dart      # ✅
│   │   │       └── delete_baby_usecase.dart      # ✅ (Cascade delete jadwal, growth, jurnal)
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── baby_provider.dart            # ✅ babyNotifierProvider + babyByIdProvider
│   │       │   └── active_baby_provider.dart     # ✅ Active baby management
│   │       └── screens/
│   │           ├── add_baby_screen.dart          # ✅
│   │           └── baby_detail_screen.dart       # ✅ (Ubah/Hapus profil anak + hitung ulang jadwal)
│   │
│   ├── dashboard/                  # FR-06
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── dashboard_screen.dart         # ✅ Header avatar, usia, greeting, next vaccine, 2x3 grid, summary
│   │       └── widgets/                          # Memakai shared widgets di lib/widgets/
│   │
│   ├── immunization/               # FR-02 [✅ Clean Architecture lengkap]
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── vaccine_local_datasource.dart # ✅
│   │   │   ├── models/
│   │   │   │   ├── vaccine_schedule_model.dart   # ✅ Hive @HiveType(typeId: 2)
│   │   │   │   └── vaccine_schedule_model.g.dart
│   │   │   └── repositories/
│   │   │       └── immunization_repository_impl.dart # ✅ Evaluasi status efektif (TERLEWAT on read)
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── vaccine_schedule_entity.dart  # ✅ VaccineStatus & normalisasi
│   │   │   ├── repositories/
│   │   │   │   └── i_immunization_repository.dart# ✅
│   │   │   └── usecases/
│   │   │       ├── generate_schedule_usecase.dart# ✅
│   │   │       ├── schedule_reminder_usecase.dart# ✅ (H-7 & H-1 + update flag reminder)
│   │   │       ├── sync_baby_schedule_usecase.dart # ✅ Generate + schedule reminder helper
│   │   │       └── reschedule_all_reminders_usecase.dart # ✅ Reschedule saat toggle notif aktif
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── immunization_provider.dart    # ✅
│   │       ├── screens/
│   │       │   ├── calendar_screen.dart          # ✅ (Filter langsung kategori status, clean code)
│   │       │   ├── vaccine_timeline_screen.dart  # ✅
│   │       │   └── vaccine_detail_screen.dart    # ✅ (Form KIPI, tanggal target, cancel notif on done)
│   │       └── widgets/
│   │           └── vaccine_status_style.dart     # ✅ Helper styling status vaksin
│   │
│   ├── growth/                     # FR-04 [✅ Clean Architecture lengkap]
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── growth_local_datasource.dart  # ✅
│   │   │   ├── models/
│   │   │   │   ├── growth_record_model.dart      # ✅ Hive @HiveType(typeId: 3)
│   │   │   │   └── growth_record_model.g.dart
│   │   │   └── repositories/
│   │   │       └── growth_repository_impl.dart   # ✅
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── growth_record_entity.dart     # ✅
│   │   │   ├── repositories/
│   │   │   │   └── i_growth_repository.dart      # ✅
│   │   │   └── usecases/
│   │   │       ├── add_growth_record_usecase.dart# ✅
│   │   │       ├── get_growth_records_usecase.dart# ✅
│   │   │       └── delete_growth_records_by_baby_usecase.dart # ✅
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── growth_provider.dart          # ✅
│   │       └── screens/
│   │           ├── growth_chart_screen.dart      # ✅ (fl_chart 3 tab + WHO median, -2SD, +2SD dinamis)
│   │           └── add_growth_record_screen.dart # ✅ (Validasi 1x/hari & tgl lahir)
│   │
│   ├── health_journal/             # FR-04 [✅ Clean Architecture lengkap]
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── health_journal_local_datasource.dart # ✅
│   │   │   ├── models/
│   │   │   │   ├── health_journal_model.dart     # ✅ Hive @HiveType(typeId: 4)
│   │   │   │   └── health_journal_model.g.dart
│   │   │   └── repositories/
│   │   │       └── health_journal_repository_impl.dart # ✅
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── health_journal_entity.dart    # ✅
│   │   │   ├── repositories/
│   │   │   │   └── i_health_journal_repository.dart # ✅
│   │   │   └── usecases/
│   │   │       ├── add_health_journal_usecase.dart  # ✅
│   │   │       ├── get_health_journals_usecase.dart # ✅
│   │   │       ├── delete_health_journal_usecase.dart # ✅
│   │   │       └── delete_health_journals_by_baby_usecase.dart # ✅
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── journal_provider.dart         # ✅
│   │       └── screens/
│   │           ├── journal_list_screen.dart      # ✅ (Dismissible slider aman ValueKey)
│   │           └── add_journal_screen.dart       # ✅ (Master gejala health_gejala.dart)
│   │
│   ├── education/                  # FR-05 [✅ Selesai]
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── education_mock_datasource.dart# ✅ 8 artikel, 6 video, 3 kuis x 5 soal
│   │   │   └── models/
│   │   │       ├── article_model.dart
│   │   │       ├── video_model.dart
│   │   │       ├── quiz_model.dart
│   │   │       ├── quiz_score_model.dart         # ✅ Hive @HiveType(typeId: 5) + attemptCount & riwayatSkor
│   │   │       └── quiz_score_model.g.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── education_provider.dart
│   │       ├── widgets/
│   │       │   ├── education_thumbnail.dart
│   │       │   └── education_kategori_badge.dart
│   │       └── screens/
│   │           ├── education_hub_screen.dart     # ✅ Tab Artikel, Video, Kuis + shared category filter
│   │           ├── article_detail_screen.dart    # ✅ flutter_html renderer
│   │           └── quiz_screen.dart              # ✅ Quiz engine + badge hasil + Hive persistence
│   │
│   ├── faskes/                     # FR-03 [✅ Selesai]
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── faskes_mock_datasource.dart   # ✅ 14 faskes, 3 kota, 4 tipe
│   │   │   └── models/
│   │   │       └── faskes_model.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── faskes_provider.dart
│   │       └── screens/
│   │           └── faskes_screen.dart            # ✅ Toggle List ↔ Peta OpenStreetMap (flutter_map)
│   │
│   └── chatbot/                    # FR-07 [✅ Selesai]
│       ├── data/
│       │   ├── datasources/
│       │   │   └── chatbot_mock_datasource.dart  # ✅ 31 keyword groups
│       │   └── models/
│       │       └── chat_message_model.dart       # In-memory model
│       └── presentation/
│           ├── providers/
│           │   └── chatbot_provider.dart         # StateNotifier chat
│           └── screens/
│               └── chatbot_screen.dart           # ✅ Bubble chat, typing indicator, chips
│
├── injection/
│   └── dependency_injection.dart   # ✅ Riverpod DI Registry: 30 provider (Auth, Baby, Imunisasi, Growth, Journal)
│
└── widgets/                        # ✅ 10/10 Shared Global Widgets (100% Selesai)
    ├── app_bottom_nav_bar.dart     # Bottom nav konsisten 5 tab
    ├── baby_avatar.dart            # Avatar inisial / foto profil anak
    ├── confirm_dialog.dart         # Dialog konfirmasi aksi destruktif
    ├── custom_text_field.dart      # Input field seragam
    ├── empty_state_widget.dart     # Tampilan data kosong informatif
    ├── error_state_widget.dart     # Tampilan pesan error + tombol retry
    ├── loading_overlay.dart        # Overlay loading asinkron
    ├── section_header.dart         # Header seksi Baloo 2 seragam
    ├── status_badge.dart           # Badge status vaksin & kategori
    └── vaccine_card.dart           # Kartu info jadwal vaksinasi reusable
```

---

## 2. 🧠 State Management: Riverpod (Rekomendasi Utama)

### Alasan Memilih Riverpod vs BLoC

| Kriteria | **Riverpod** ✅ | BLoC |
|---|---|---|
| Boilerplate | Minimal | Tinggi |
| Testability | Excellent | Excellent |
| Async support | `AsyncNotifier`, `FutureProvider` built-in | Perlu `StreamBloc` |
| Dependency injection | Built-in (`ref.read`) | Perlu `GetIt` terpisah |
| Hot reload friendly | ✅ | ✅ |
| Learning curve | Sedang | Tinggi |
| Scalability UTS→UAS | ✅ Provider override | Perlu `BlocProvider` refactor |

### Pattern yang Dipakai: `AsyncNotifier` (tanpa codegen)

> **Catatan:** `riverpod_generator` **tidak dipakai** karena bergantung pada `build ^2.0.0`,
> sementara `hive_ce_generator` butuh `build ^4.0.0` — keduanya tidak bisa hidup berdampingan.
> Riverpod tetap berfungsi penuh tanpa codegen; provider ditulis manual.

```dart
// Contoh: BabyNotifier (baby_provider.dart)
class BabyNotifier extends AsyncNotifier<List<BabyEntity>> {
  @override
  Future<List<BabyEntity>> build() async {
    return ref.read(getBabiesUseCaseProvider).execute();
  }

  Future<void> addBaby(BabyEntity baby) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(addBabyUseCaseProvider).execute(baby),
    );
    ref.invalidateSelf(); // rebuild
  }
}

final babyNotifierProvider =
    AsyncNotifierProvider<BabyNotifier, List<BabyEntity>>(BabyNotifier.new);
```

---

## 3. 💾 Strategi Data Fase 1 (UTS): Hive CE Database

### Rekomendasi: **Hive CE** (`hive_ce`)

> **Catatan revisi (15 Sep 2026):** Rencana awal memakai **Isar 3.1.0**, tetapi Isar sudah
> *abandoned* (rilis terakhir 3 tahun lalu) dan **tidak bisa di-build** dengan Android Gradle
> Plugin (AGP) 9.x karena `isar_flutter_libs` belum mendefinisikan `namespace`. Fork komunitas
> `isar_community` juga tidak bisa dipakai karena `isar_community_generator`-nya bentrok dengan
> `riverpod_generator` pada paket `build` (`^3`/`^4` vs `^2`). Karena itu database diganti ke
> **Hive CE** — fork Hive v2 yang masih aktif dirawat, **100% pure Dart tanpa dependency native**,
> sehingga bebas dari masalah Gradle/NDK dan bisa memakai toolchain AGP terbaru.

| Kriteria | Hive CE ✅ | Isar 3.1.0 | sqflite |
|---|---|---|---|
| Dependency native | ✅ **Tidak ada** (pure Dart) | ❌ Ada (rust/NDK) | ❌ Ada (SQLite) |
| Status maintenance | ✅ Aktif (2026) | ❌ Abandoned (3 tahun) | ✅ Aktif |
| Kompatibel AGP 9.x | ✅ Ya | ❌ Tidak | ✅ Ya |
| Kecepatan | ⚡ Cepat | ⚡ Sangat cepat | Sedang |
| Code generation | ✅ Opsional (`GenerateAdapters`) | ✅ Wajib (`@collection`) | ❌ Raw SQL |
| Konflik dengan `riverpod_generator` | ✅ Tidak ada | ⚠️ Ada (via `analyzer`) | ✅ Tidak ada |
| Null-safety | ✅ | ✅ | ✅ |
| Lintas platform | ✅ Semua (mobile/desktop/web) | ⚠️ Terbatas | ⚠️ Terbatas |
| Enkripsi | ✅ Built-in | ❌ Tidak | ❌ Tidak |
| Migration UAS | Mudah (ganti datasource impl) | Mudah | Sedang |
| Setup complexity | Rendah | Sedang (build_runner) | Rendah |
| Async query | ✅ | ✅ | ✅ |

### 3.1 Skema Model Data Hive CE (Fase UTS)

> Model Hive memakai `@HiveType` + `@HiveField` dengan `typeId` unik. Adapter
> digenerate otomatis lewat `@GenerateAdapters` (Hive CE) + `build_runner`.
> `id` lokal tetap disimpan sebagai field `String` (UUID) agar mudah disinkronkan ke Firestore di fase UAS.

#### 📌 UserModel
```dart
@HiveType(typeId: 0)
class UserModel {
  @HiveField(0) late String localId;       // UUID generated locally
  @HiveField(1) late String namaLengkap;
  @HiveField(2) late String email;
  @HiveField(3) late String nomorTelepon;
  @HiveField(4) String? lokasiKota;
  @HiveField(5) late DateTime createdAt;
}
```

#### 📌 BabyModel
```dart
@HiveType(typeId: 1)
class BabyModel {
  @HiveField(0) late String babyId;          // UUID
  @HiveField(1) late String userId;          // FK ke UserModel.localId
  @HiveField(2) late String namaAnak;
  @HiveField(3) late DateTime tanggalLahir;
  @HiveField(4) late String jenisKelamin;    // 'L' atau 'P'
  @HiveField(5) String? fotoProfilPath;      // path lokal ke galeri
  @HiveField(6) late DateTime createdAt;
}
```

#### 📌 VaccineScheduleModel
```dart
@HiveType(typeId: 2)
class VaccineScheduleModel {
  @HiveField(0) late String scheduleId;
  @HiveField(1) late String babyId;
  @HiveField(2) late String namaVaksin;      // BCG, HB0, Polio1, DPT1, dll.
  @HiveField(3) late String deskripsi;
  @HiveField(4) late int usiaBulanTarget;    // misal: 0, 1, 2, 3, 4 bulan
  @HiveField(5) late DateTime tanggalTarget;
  @HiveField(6) late String status;          // 'BELUM' | 'SELESAI' | 'TERLEWAT'
  @HiveField(7) DateTime? tanggalRealisasi;
  @HiveField(8) String? catatanReaksi;       // KIPI notes
  @HiveField(9) bool reminderH7Sent = false;
  @HiveField(10) bool reminderH1Sent = false;
}
```

> **Catatan status (24 Sep 2026):** nilai yang **tersimpan** hanya `BELUM` / `SELESAI`. `TERLEWAT` dihitung **saat data dibaca** oleh `VaccineStatus.effective` (lihat `vaccine_schedule_entity.dart`, diterapkan di `ImmunizationRepositoryImpl`) sehingga tidak memerlukan job harian maupun migrasi data — status otomatis berubah begitu hari berganti.

#### 📌 GrowthRecordModel
```dart
@HiveType(typeId: 3)
class GrowthRecordModel {
  @HiveField(0) late String recordId;
  @HiveField(1) late String babyId;
  @HiveField(2) late DateTime tanggalPengukuran;
  @HiveField(3) late double beratBadan;     // kg
  @HiveField(4) late double tinggiBadan;    // cm
  @HiveField(5) double? lingkarKepala;      // cm (opsional)
}
```

#### 📌 HealthJournalModel
```dart
@HiveType(typeId: 4)
class HealthJournalModel {
  @HiveField(0) late String journalId;
  @HiveField(1) late String babyId;
  @HiveField(2) String? vaccineScheduleId;   // nullable, bisa jurnal harian biasa
  @HiveField(3) late DateTime tanggalCatatan;
  @HiveField(4) late String isiCatatan;
  @HiveField(5) double? suhuTubuh;           // Celsius
  @HiveField(6) List<String> gejala = [];    // ['demam', 'bengkak', 'rewel']
}
```

### 3.2 Data Master Vaksin (Hardcoded Constants)

```dart
// lib/core/constants/vaccine_schedule.dart
class VaccineMaster {
  static const List<Map<String, dynamic>> jadwalNasional = [
    {'nama': 'HB0',      'usia': 0,  'dosis': 1, 'deskripsi': 'Hepatitis B dosis pertama, diberikan sesegera mungkin setelah lahir'},
    {'nama': 'BCG',      'usia': 1,  'dosis': 1, 'deskripsi': 'Perlindungan terhadap Tuberkulosis (TBC)'},
    {'nama': 'Polio 0',  'usia': 0,  'dosis': 1, 'deskripsi': 'Polio tetes pertama saat lahir'},
    {'nama': 'DPT-HB-Hib 1', 'usia': 2, 'dosis': 1, 'deskripsi': 'Difteri, Pertusis, Tetanus, Hepatitis B, Hib'},
    {'nama': 'Polio 1',  'usia': 2,  'dosis': 1, 'deskripsi': 'Polio tetes kedua'},
    {'nama': 'DPT-HB-Hib 2', 'usia': 3, 'dosis': 2, 'deskripsi': '...'},
    {'nama': 'Polio 2',  'usia': 3,  'dosis': 1, 'deskripsi': '...'},
    {'nama': 'DPT-HB-Hib 3', 'usia': 4, 'dosis': 3, 'deskripsi': '...'},
    {'nama': 'Polio 3',  'usia': 4,  'dosis': 1, 'deskripsi': '...'},
    {'nama': 'IPV',      'usia': 4,  'dosis': 1, 'deskripsi': 'Inactivated Polio Vaccine (Polio suntik)'},
    {'nama': 'MR',       'usia': 9,  'dosis': 1, 'deskripsi': 'Measles-Rubella (Campak dan Rubella)'},
    {'nama': 'DPT-HB-Hib 4', 'usia': 18, 'dosis': 4, 'deskripsi': 'Booster DPT'},
    {'nama': 'MR Booster','usia': 18, 'dosis': 2, 'deskripsi': 'Booster Campak-Rubella'},
    // ... tambahkan sesuai jadwal IDAI terbaru
  ];
}
```

---

## 4. 🔔 Sistem Notifikasi H-7 & H-1 (Client-Side Only)

### Package yang Digunakan
- `flutter_local_notifications: ^22.3.1` (wajib desugaring + compileSdk ≥ 35)
- `timezone: ^0.11.0` (wajib untuk scheduled notifications)
- `workmanager: ^0.10.10` (background task jika app tertutup)

### Setup Android yang Diperlukan

**AndroidManifest.xml** — permissions:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

**AndroidManifest.xml** — receivers (di dalam `<application>`):
```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />
```

**build.gradle.kts** — desugaring wajib (v10+):
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### Alur Kerja

```
[Saat bayi didaftarkan]
       │
       ▼
GenerateScheduleUseCase
  → Kalkulasi tanggalTarget tiap vaksin
  → Simpan ke Hive CE (VaccineScheduleModel)
       │
       ▼
ScheduleReminderUseCase
  → Untuk setiap jadwal dengan status 'BELUM':
      ├── scheduleNotification(id, tanggalTarget - 7 hari)
      └── scheduleNotification(id, tanggalTarget - 1 hari)
       │
       ▼
flutter_local_notifications.zonedSchedule()
  → Notifikasi terjadwal di level OS Android
  → Akan muncul meski app tertutup (via AlarmManager)
```

### Implementasi Kode Notifikasi

```dart
// lib/core/services/notification_service.dart
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: androidSettings));
  }

  Future<void> scheduleVaccineReminder({
    required int notifId,
    required String namaAnak,
    required String namaVaksin,
    required DateTime scheduledDate,
    required int daysBeforeH, // 7 atau 1
  }) async {
    final scheduledTz = tz.TZDateTime.from(
      scheduledDate.subtract(Duration(days: daysBeforeH)),
      tz.local,
    );

    await _plugin.zonedSchedule(
      id: notifId,
      title: '🔔 Pengingat Imunisasi $namaAnak',
      body: 'Vaksin $namaVaksin dijadwalkan ${daysBeforeH == 7 ? "minggu" : "besok"}! Siapkan buku KIA-mu.',
      scheduledDate: scheduledTz,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'vaccine_reminder',
          'Pengingat Vaksinasi',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
```

### WorkManager untuk Background Check
```dart
// Daftarkan saat app launch
Workmanager().initialize(callbackDispatcher);
Workmanager().registerPeriodicTask(
  'vaccine-check',
  'checkMissedVaccines',
  frequency: const Duration(hours: 24),
  constraints: Constraints(networkType: NetworkType.not_required),
);

// Top-level callback (harus di luar class)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'checkMissedVaccines') {
      // Query Hive CE → cari jadwal yang sudah lewat & belum selesai
      // Update status ke 'TERLEWAT'
    }
    return Future.value(true);
  });
}
```

---

## 5. 🤖 AI Chatbot: Mock Strategy (Fase UTS)

### Pendekatan: Rule-Based Mock dengan Keyword Matching

```dart
// lib/features/chatbot/data/datasources/chatbot_mock_datasource.dart
class ChatbotMockDatasource {
  static const Map<String, String> _responses = {
    'demam': 'Demam ringan setelah vaksinasi adalah reaksi normal. Berikan paracetamol sesuai dosis dan kompres hangat. Jika suhu >39°C atau lebih dari 3 hari, segera ke dokter.',
    'bcg': 'Vaksin BCG biasanya diberikan segera setelah lahir. Bekas suntik yang membentuk benjolan kecil adalah reaksi normal dan akan hilang sendiri.',
    'asi': 'Pemberian ASI eksklusif direkomendasikan selama 6 bulan pertama. ASI mengandung antibodi alami yang melengkapi perlindungan vaksin.',
    'jadwal': 'Jadwal imunisasi sudah tercatat di aplikasi. Silakan cek menu Kalender untuk melihat vaksinasi berikutnya.',
    'berat badan': 'Pantau berat badan bayi setiap bulan. Pertambahan berat normal adalah 500-700g/bulan untuk 3-6 bulan pertama.',
    // ...tambahkan 20-30 keyword
  };

  static const String _defaultResponse =
    'Maaf, saya belum bisa menjawab pertanyaan ini secara detail. '
    'Silakan konsultasikan dengan dokter anak atau bidan terdekat untuk informasi lebih akurat. '
    'Anda bisa cari faskes terdekat di menu Direktori Faskes. 🏥';

  Future<String> getResponse(String userMessage) async {
    // Simulasi delay response API (100-500ms)
    await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(300)));

    final lowerMsg = userMessage.toLowerCase();
    for (final entry in _responses.entries) {
      if (lowerMsg.contains(entry.key)) {
        return entry.value;
      }
    }
    return _defaultResponse;
  }
}
```

### Tips Demo UTS
- Siapkan minimal **25 keyword** yang mencakup semua vaksin dari jadwal nasional
- Tambahkan **typing indicator** animasi (3 dots) saat menunggu "respons"
- Sertakan **suggested questions** di awal chat agar demo terkesan lancar

> **Status 25 Sep 2026**: Implementasi selesai. `ChatbotMockDatasource` ada di
> `lib/features/chatbot/data/datasources/chatbot_mock_datasource.dart` dengan
> **31 keyword group** (semua 13 vaksin nasional + topik umum: demam, KIPI, ASI,
> stunting, MPASI, posyandu, dll). `ChatbotScreen` selesai dengan bubble chat
> user/bot, typing indicator animasi 3 titik staggered, 5 suggested question chips,
> scroll otomatis via `ref.listen`, tombol hapus percakapan + `ConfirmDialog`.
> Route `/chatbot` aktif — bukan placeholder. Screen ini kini tab utama bottom nav
> (index 2, menggantikan Pertumbuhan).

---

## 6. 🚀 Roadmap Transisi ke Fase 2 (UAS)

### High-Level Technical Guide

#### 6.1 Prinsip Utama: Swap Data Source, Bukan Rewrite

Karena kita menggunakan **Repository Pattern + Dependency Injection (Riverpod)**, transisi hanya butuh:

1. **Tambah** `*_remote_datasource.dart` di tiap feature
2. **Modifikasi** `*_repository_impl.dart` → implementasi **offline-first logic**
3. **Update** provider di `dependency_injection.dart` (toggle env variable)
4. **UI tidak berubah sama sekali**

#### 6.2 Offline-First Strategy (UAS)

```dart
// Contoh: baby_repository_impl.dart versi UAS
class BabyRepositoryImpl implements IBabyRepository {
  final BabyLocalDatasource _local;
  final BabyRemoteDatasource _remote; // [UAS] ditambahkan

  @override
  Future<List<BabyEntity>> getBabies(String userId) async {
    try {
      // 1. Coba fetch dari remote
      final remoteData = await _remote.getBabies(userId);
      // 2. Sync ke local (upsert)
      await _local.upsertAll(remoteData);
      return remoteData.map((e) => e.toEntity()).toList();
    } catch (_) {
      // 3. Fallback ke local jika offline
      final localData = await _local.getBabies(userId);
      return localData.map((e) => e.toEntity()).toList();
    }
  }
}
```

#### 6.3 Migration Data UTS → UAS

```
Strategy: "Sync-on-Login"
1. User login pertama kali dengan Firebase Auth
2. App check: apakah ada data lokal Hive CE yang belum disync?
3. Jika ya → upload seluruh data (BabyModel, VaccineLog, GrowthRecord) ke Firestore
4. Tandai data lokal dengan field: isSynced = true, cloudId = firestore_doc_id
5. Selanjutnya, setiap write ke lokal diikuti write ke remote (fire-and-forget)
```

#### 6.4 Tambahan Package UAS

```yaml
# pubspec.yaml tambahan (UAS)
dependencies:
  firebase_core: ^3.x
  firebase_auth: ^5.x
  cloud_firestore: ^5.x
  firebase_storage: ^12.x    # untuk foto profil
  dio: ^5.x                   # HTTP client untuk custom backend
  retrofit: ^4.x              # Code gen untuk REST API
  connectivity_plus: ^6.x     # Monitor koneksi jaringan
  firebase_messaging: ^15.x   # Push notification dari server
```

---

## 7. 📦 Dependensi Lengkap (Fase UTS)

```yaml
# pubspec.yaml — Fase UTS
name: imunikita
description: "Sistem pelacakan imunisasi dan tumbuh kembang anak"
version: 1.0.0+1

environment:
  sdk: ^3.13.2

dependencies:
  flutter:
    sdk: flutter

  # State Management (tanpa codegen — provider ditulis manual)
  flutter_riverpod: ^2.5.1

  # Navigation
  go_router: ^14.2.0

  # Local Database
  # Local Database (Hive CE — pure Dart, tanpa dependency native)
  hive_ce: ^2.20.0
  hive_ce_flutter: ^2.3.4
  path_provider: ^2.1.3

  # Notifications
  flutter_local_notifications: ^22.3.1
  timezone: ^0.11.0
  workmanager: ^0.10.10

  # Utils
  uuid: ^4.4.2
  intl: ^0.19.0
  shared_preferences: ^2.3.2

  # Image & File
  image_picker: ^1.2.3

  # HTML rendering
  flutter_html: ^3.0.0

  # Deep link / URL
  url_launcher: ^6.3.2

  # Peta (Direktori Faskes — OpenStreetMap, tanpa API key)
  flutter_map: ^7.0.2
  latlong2: ^0.9.1

  # UI
  fl_chart: ^0.68.0        # Grafik pertumbuhan
  table_calendar: ^3.1.2   # Kalender imunisasi
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
  lottie: ^3.1.2           # Animasi splash/loading
  google_fonts: ^6.2.1

  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.12
  hive_ce_generator: ^1.11.3

# ⚠️ WAJIB (ditambahkan 24 Sep 2026 saat fitur Edukasi mulai memakai flutter_html):
# flutter_html 3.0.0 memanggil API internal `package:html/src/query_selector.dart`
# (fungsi top-level `matches()`) yang DIHAPUS pada `html` 0.15.7. Tanpa pin ini,
# `flutter test` / build gagal: "Method not found: 'matches'".
dependency_overrides:
  html: 0.15.6
```

---

## 8. 📅 Sprint Plan

> **Status per 29 September 2026** (rincian lengkap ada di `ImuniKita_Frontend_Progress_220926.md`):
> Sprint 0 ✅ · Sprint 1 ✅ · Sprint 2 ✅ · Sprint 3 ✅ · **Sprint 4 ✅ — Edukasi (FR-05) ✅ + Settings/Profil ✅ + Chatbot/ImuniBot (FR-07) ✅ + Direktori Faskes (FR-03) ✅ + 10/10 Shared Global Widgets ✅ + Clean Architecture Overhaul di Seluruh Fitur ✅**.
> Progress keseluruhan: **19 dari 19 screen kode selesai (100%)** · **10 dari 10 Shared Widgets selesai (100%)** · **30 DI Providers (Auth, Baby, Imunisasi, Growth, Journal)**.
> Validasi terkini: `flutter analyze` → **No issues found!** · `flutter test` → **168/168 unit & widget test lulus (15 file test)**.
> **Bug fixing & Refactoring (24–29 Sep):** Seluruh temuan gap teknis prioritas (#1–#11, #15–#17, #21–#27, dan #28–#33) telah selesai diimplementasikan.

### 🎯 FASE 1 — TARGET UTS

#### Sprint 0 — Setup & Arsitektur (Minggu 1)
| Task | Assignee | Estimasi | Status |
|------|----------|----------|--------|
| Setup project Flutter (clean slate) | All | 2 jam | ✅ |
| Inisialisasi struktur folder (Clean Arch) | Lead Dev | 3 jam | ✅ (101 direktori) |
| Setup pubspec.yaml (semua dependency UTS) | Lead Dev | 1 jam | ✅ |
| Setup GoRouter (routing semua screen) | Dev A | 3 jam | ✅ (20 route asli, 0 placeholder) |
| Setup Hive CE DB + generate models | Dev B | 4 jam | ✅ (6 adapter typeId 0-5) |
| Setup Riverpod + dependency injection | Dev A | 3 jam | ✅ (30 DI provider) |
| Setup Theme (warna, typography, spacing) | UI Dev | 3 jam | ✅ |
| Setup NotificationService + permissions | Dev B | 2 jam | ✅ (tap navigation & inexact fallback) |

#### Sprint 1 — Auth & Profil Bayi (Minggu 2)
| Task | Screen / Komponen | FR | Status |
|------|-------------------|----|--------|
| Splash Screen + animasi Lottie/Two-zone | SplashScreen | - | ✅ |
| Onboarding Screen (3 halaman swipe, neo-brutalism) | OnboardingScreen | - | ✅ (Warna cerah slide) |
| Login Screen (Clean Arch UseCase) | LoginScreen | - | ✅ |
| Register Screen (Clean Arch UseCase) | RegisterScreen | - | ✅ |
| Tambah Profil Bayi (form + validasi) | AddBabyScreen | FR-01 | ✅ |
| Kelola Profil Anak (ubah, hapus cascade, bayi aktif) | BabyDetailScreen | FR-01 | ✅ |
| Clean Architecture Auth (Domain, Data, Repo, 6 UseCase) | AuthCleanArch | - | ✅ (Temuan #22) |
| Generate jadwal imunisasi otomatis | GenerateScheduleUseCase | FR-01 | ✅ |

#### Sprint 2 — Dashboard & Kalender (Minggu 3)
| Task | Screen / Komponen | FR | Status |
|------|-------------------|----|--------|
| Dashboard Screen (greeting dinamis, usia bayi, next vaccine card, grid 2x3) | DashboardScreen | FR-06 | ✅ (Bayi 18+ bln aman) |
| Widget: Vaccine Card (reusable) | VaccineCard | FR-02 | ✅ (Shared widget) |
| Widget: Growth Summary Card | GrowthSummaryCard | FR-06 | ✅ |
| Widget: Quick Action Grid (6 shortcut 2x3) | QuickActionGrid | FR-06 | ✅ |
| Kalender Imunisasi (table_calendar + filter langsung kategori status) | CalendarScreen | FR-02 | ✅ (Clean code & refactored) |
| Timeline Imunisasi vertikal | VaccineTimelineScreen | FR-02 | ✅ |
| Detail Vaksin (status update + form KIPI + tanggal target + cancel notif) | VaccineDetailScreen | FR-02 | ✅ |
| Notifikasi lokal H-7 dan H-1 | ScheduleReminderUseCase | FR-02 | ✅ (Track reminder sent flags) |

#### Sprint 3 — Pertumbuhan & Jurnal (Minggu 4)
| Task | Screen / Komponen | FR | Status |
|------|-------------------|----|--------|
| Grafik pertumbuhan (fl_chart 3 tab + WHO median, -2SD, +2SD dinamis) | GrowthChartScreen | FR-04 | ✅ |
| Form tambah rekam pertumbuhan (validasi 1x/hari & tgl lahir) | AddGrowthRecordScreen | FR-04 | ✅ |
| Clean Architecture Growth (Domain, Data, Repo, 3 UseCase) | GrowthCleanArch | FR-04 | ✅ |
| List jurnal kesehatan (Dismissible slider aman ValueKey) | JournalListScreen | FR-04 | ✅ |
| Form tambah jurnal (master gejala health_gejala.dart) | AddJournalScreen | FR-04 | ✅ |
| Clean Architecture Health Journal (Domain, Data, Repo, 4 UseCase) | JournalCleanArch | FR-04 | ✅ |
| Direktori Faskes (14 faskes mock + OSM flutter_map) | FaskesScreen | FR-03 | ✅ |

#### Sprint 4 — Edukasi, Chatbot & Polish (Minggu 5)
| Task | Screen / Komponen | FR | Status |
|------|-------------------|----|--------|
| Education Hub (list artikel + video YouTube + kuis interaktif) | EducationHubScreen | FR-05 | ✅ |
| Detail Artikel (flutter_html renderer) | ArticleDetailScreen | FR-05 | ✅ |
| Kuis Interaktif + simpan riwayat & attempts ke Hive CE | QuizScreen | FR-05 | ✅ (typeId: 5) |
| Chatbot Screen (bubble chat + typing indicator + 31 keyword) | ChatbotScreen | FR-07 | ✅ |
| Settings Screen (edit profil, toggle notifikasi, daftar anak, keluar) | SettingsScreen | - | ✅ |
| 10 Shared Global Widgets di `lib/widgets/` | All shared widgets | - | ✅ (10/10 Selesai) |
| CI GitHub Actions (`.github/workflows/ci.yaml`) | CI Pipeline | - | ✅ |
| Bug fixing & pengujian unit/widget test komprehensif | Test Suite | - | ✅ (168 test lulus) |

**Catatan implementasi Edukasi (24 Sep 2026):**
- Konten dibaca lewat `EducationMockDatasource` (8 artikel, 6 video, 3 kuis × 5 soal) + `education_provider.dart`; chip filter kategori (`Semua/Imunisasi/Nutrisi/Tumbuh Kembang/MPASI`) dipakai bersama ketiga tab.
- Body artikel dirender `flutter_html`; skor kuis dipersist ke **Hive `QuizScoreModel` (`typeId: 5`)** dengan dukungan `attemptCount` dan `riwayatSkor` → registrar total **6 adapter**.
- Entry point: quick action **Edukasi** di Dashboard (route `/education` memakai screen asli dengan tombol kembali aman).
- Validasi: `flutter analyze` bersih · `flutter test` lulus.

**Catatan implementasi Profil & Pengaturan (24 Sep 2026):**
- Isi layar: profil pengguna + sunting profil (tolak email duplikat), daftar bayi + tambah bayi, toggle notifikasi pengingat, info versi, dan tombol Keluar berkonfirmasi (`ConfirmDialog`).
- Provider `auth_provider.dart` (`currentUserProvider`, `notificationEnabledProvider`) terhubung ke layer Clean Architecture auth.
- `ScheduleReminderUseCase` membaca preferensi notifikasi — berhenti menjadwalkan bila toggle mati, dan pengingat didaftarkan ulang saat toggle dinyalakan via `RescheduleAllRemindersUseCase`.

**Catatan implementasi Direktori Faskes & Chatbot (25 Sep 2026):**
- Package peta: `flutter_map: ^7.0.2` + `latlong2: ^0.9.1` — OpenStreetMap, **gratis tanpa API key**.
- Data: `FaskesMockDatasource` (14 faskes, 3 kota, 4 tipe) dan `ChatbotMockDatasource` (**31 keyword groups**).
- Tab bottom nav: **Home · Kalender · ImuniBot (index 2) · Faskes (index 3) · Profil (index 4)**. 0 placeholder tersisa.

**Catatan +9 Global Widgets (Commit `27463e9` — 25 Sep 2026):**
- Seluruh 10 komponen bersama di `lib/widgets/` selesai dibuat: `app_bottom_nav_bar.dart`, `baby_avatar.dart`, `confirm_dialog.dart`, `custom_text_field.dart`, `empty_state_widget.dart`, `error_state_widget.dart`, `loading_overlay.dart`, `section_header.dart`, `status_badge.dart`, dan `vaccine_card.dart`.
- Komponen diintegrasikan ke seluruh screen untuk mengeliminasi duplikasi kode UI.
- Unit & widget test lengkap ditambahkan di `test/global_widgets_test.dart`.

**Catatan Major 20+ Bugs Fix & Clean Architecture Overhaul (Commit `8b777b6` — 25 Sep 2026):**
- **Clean Architecture Penuh**: Layer Domain (Entity, IRepository, UseCases) dan Data (LocalDatasource, RepositoryImpl) diterapkan merata pada `auth`, `growth`, dan `health_journal`.
- **DI Registry**: `lib/injection/dependency_injection.dart` diekspansi menjadi 30 provider Riverpod yang terstruktur.
- **Standar Pertumbuhan WHO**: Menambahkan `lib/core/constants/who_growth_reference.dart` yang memuat tabel baku WHO Child Growth Standards (Median, -2SD, +2SD) untuk BB, TB, dan LK laki-laki/perempuan, diintegrasikan ke `GrowthChartScreen`.
- **Penyempurnaan Notifikasi**: Penanganan tap notifikasi di `NotificationService` yang otomatis mengarahkan ke `/calendar/detail/$scheduleId`, fallback otomatis dari exact ke inexact alarm bila izin ditolak OS, pembatalan notifikasi jadwal saat vaksin selesai (`cancelNotification`), dan pelacakan flag anti-duplikasi `reminderH7Sent`/`reminderH1Sent`.
- **Riwayat Kuis**: `QuizScoreModel` diperkaya dengan field `attemptCount` dan `riwayatSkor`.
- **Status Bar Icon Monokrom**: Menambahkan `ic_stat_imunikita.xml` untuk ikon notifikasi Android sesuai pedoman Material Design.
- **Dokumentasi & CI**: Penulisan komprehensif `README.md` dan setup otomatisasi CI GitHub Actions (`.github/workflows/ci.yaml`).

**Catatan Bayi 18 Bulan ke Atas (Commit `76e1dd3` — 25 Sep 2026):**
- Penanganan khusus pada kartu vaksin berikutnya di `DashboardScreen` untuk bayi berusia di atas 18 bulan (di mana semua vaksin wajib mungkin sudah selesai atau terlewat) agar UI tetap rapi, tidak crash, dan menampilkan status yang tepat. Ditambahkan `test/dashboard_old_baby_test.dart`.

**Catatan Bug Fixes & Refactoring (Commit `280d58c` & `629dae6` — 29 Sep 2026):**
- **Validasi Tumbuh Kembang (4.2)**: Form pengukuran bayi memblokir input duplikat pada tanggal yang sama untuk bayi aktif (SnackBar peringatan) dan membatasi `firstDate` pada date picker ke `currentBaby.tanggalLahir`.
- **Fix Slider Hapus Jurnal (4.3)**: Memperbaiki crash red screen saat swipe-to-delete pada `JournalListScreen` dengan penguncian `ValueKey` unik item jurnal, penanganan `confirmDismiss` aman, dan pembersihan state sinkron.
- **Kalender Imunisasi (3.1)**: Filter status (*Terjadwal*, *Selesai*, *Terlewat*) langsung menampilkan jadwal sesuai kategori tanpa terikat tanggal klik (`_selectedDay` otomatis di-reset ke `null`). Prioritas logika filtering diperbaiki dan kode di-refactor bersih.
- **Onboarding UI (1.2)**: Icon, border, dan lingkaran latar belakang slide onboarding diperbarui menggunakan warna cerah tema (`coral`, `teal`, `yellow`) ber-alpha halus.
- **Penyelarasan Warna Status & CI Test**: Penyelarasan warna status `BELUM` menjadi kuning (`AppColors.yellow`) di helper `VaccineStatusStyle` dan update unit test di `test/vaccine_status_test.dart`.
- Validasi: `flutter analyze` → **No issues found!** · `flutter test` → **168/168 test lulus (15 file test)**.

---

### 🚀 FASE 2 — TARGET UAS

#### Sprint 5 — Firebase Foundation (Minggu 1 UAS)
| Task | Detail |
|------|--------|
| Setup Firebase project | FlutterFire CLI |
| Firebase Auth (Email/Password) | Replace mock login |
| Firestore schema design | Mirror model Hive CE |
| Migrate UserModel → Firestore | Sync-on-login strategy |

#### Sprint 6 — Sinkronisasi Data Utama (Minggu 2 UAS)
| Task | Detail |
|------|--------|
| BabyRemoteDatasource (Firestore CRUD) | FR-01 |
| VaccineRemoteDatasource (Firestore) | FR-02 |
| GrowthRemoteDatasource (Firestore) | FR-04 |
| HealthJournalRemoteDatasource | FR-04 |
| Offline-first logic di Repository Impl | connectivity_plus |
| Migrasi data lokal UTS → Firestore | Sync-on-first-login |

#### Sprint 7 — Custom Backend Integration (Minggu 3 UAS)
| Task | Detail |
|------|--------|
| Setup Dio + Retrofit codegen | API client layer |
| Integrate custom backend (TBD) | Auth token, CRUD |
| Firebase Cloud Messaging (FCM) | Server-side push notif |
| Replace mock chatbot | Real AI API call |
| Replace mock education content | CMS API |
| Error handling (offline banner, retry) | UX polish |

#### Sprint 8 — Polish UAS & Final (Minggu 4 UAS)
| Task | Detail |
|------|--------|
| Performance profiling | Flutter DevTools |
| Security audit (token storage, data sanitasi) | - |
| Google Maps integration (FR-03 real) | maps_flutter |
| Final UI/UX polish & testing | - |
| Build release APK + dokumentasi | - |

---

## 9. ⚡ Tips Eksekusi Tim

1. **Code generation**: Jalankan `dart run build_runner build --delete-conflicting-outputs` setiap kali ubah model Hive CE (adapter `@HiveType`).
2. **Feature flag**: Gunakan `AppConstants.isUASPhase = false` untuk toggle antara mock datasource (UTS) dan real datasource (UAS) tanpa mengubah logika bisnis.
3. **Naming convention**: File model selalu berakhiran `_model.dart`, entity berakhiran `_entity.dart`, datasource berakhiran `_datasource.dart`.
4. **Testing priority UTS**: Fokus pada `UseCase` unit test dan Widget test untuk screen utama.
   _Status 24 Sep 2026: unit test `GenerateScheduleUseCase`, `ScheduleReminderUseCase`, dan `NotificationHelper` sudah ada (`test/schedule_usecase_test.dart`); widget test layar menyusul._
5. **Git strategy**: Gunakan branch `feat/uts-*` untuk semua pekerjaan UTS, merge ke `main` sebelum demo. Buat branch `feat/uas-*` untuk pekerjaan UAS.
6. **Navigasi (GoRouter)**: pakai `context.go` untuk layar yang **menggantikan** posisi sekarang (tab bottom nav), dan `context.push` untuk **layar sekunder** yang tidak punya bottom nav. Dengan `go`, AppBar tidak akan menampilkan tombol kembali karena tumpukan hanya berisi satu halaman (kasus hub Edukasi, 24 Sep 2026) — layar seperti itu wajib menyediakan tombol kembali sendiri.

---

*Dokumen ini dibuat berdasarkan Mini SRS TrioEmpat dan pemetaan teknis proyek ImuniKita.*
