# 🛠️ Runbook Manual Setup Firebase Console (Langkah B0-4 — Revisi Tanpa Billing)

> **Status**: 🟡 Menunggu Eksekusi Manusia (*Manual Execution Required*)  
> **Estimasi Waktu**: ±15–20 menit  
> **Target**: Menyiapkan environment `imunikita-dev-f` dan `imunikita-prod-f` di Firebase Console untuk layanan Auth, Firestore, dan FCM.

---

## 📌 Prasyarat
- Akun Google / Firebase Console ([console.firebase.google.com](https://console.firebase.google.com)).
- Browser web desktop.

---

## 📋 Langkah Eksekusi Manual (Step-by-Step)

### 1. Buat Project Firebase (2 Project)
1. Buka [Firebase Console](https://console.firebase.google.com).
2. Klik **Add Project** / **Tambah Proyek**:
   - Proyek 1: Beri nama **`imunikita-dev-f`** (Lingkungan Eksperimen & Dev).
   - Proyek 2: Beri nama **`imunikita-prod-f`** (Lingkungan Rilis / Produksi — *jangan digunakan untuk testing*).
3. Matikan / batalkan centang Google Analytics pada `imunikita-dev-f` (opsional, agar setup lebih cepat).
4. Klik **Create Project** / **Buat Proyek** dan tunggu hingga proses pembuatan selesai.

---

### 2. Konfigurasi Firebase Authentication (`imunikita-dev-f`)
1. Pilih project **`imunikita-dev-f`**.
2. Di menu navigasi kiri, buka **Build** ➔ **Authentication** ➔ klik **Get Started**.
3. Pilih tab **Sign-in method**.
4. Klik penyedia **Email/Password**:
   - Aktifkan toggle **Enable** pada opsi Email/Password.
   - Biarkan opsi *Email link (passwordless sign-in)* tetap **Disabled**.
5. Klik **Save**.

---

### 3. Konfigurasi Cloud Firestore (`imunikita-dev-f`)
1. Di menu navigasi kiri, buka **Build** ➔ **Firestore Database** ➔ klik **Create Database**.
2. **Aturan Keamanan (Security Rules)**:
   - Pilih mode awal **Start in test mode** (aturan ini akan digantikan secara otomatis oleh `firestore.rules` teruji pada Tahap 3).
3. **PILIHAN REGION (KRUSIAL)**:
   - Pada pilihan *Location* / *Region*, pilih **`asia-southeast2` (Jakarta)** dari daftar dropdown.
   - *Peringatan*: Region database tidak dapat diubah setelah database dibuat.
4. Klik **Enable** / **Buat**.

---

### 4. Verifikasi Cloud Messaging (FCM — opsional)
1. Klik ikon **Project Settings (Gigi Roda)** di sudut kiri atas navigasi ➔ **Project settings**.
2. Buka tab **Cloud Messaging**.
3. Pastikan **Firebase Cloud Messaging API (V1)** dalam status **Enabled** (bawaan aktif untuk project Firebase baru).
4. FCM hanya dipakai bila tim memilih jalur push opsional (GitHub Actions). Pengingat utama tetap notifikasi lokal.

---

### 5. Billing — TIDAK Diperlukan

> **Jangan tautkan kartu kredit.** Rencana ini tidak memakai layanan yang membutuhkan Blaze. Yang dipakai hanya **Auth, Firestore (Spark), dan FCM tingkat klien** — semuanya gratis.

Layanan yang **tidak dipakai**: Cloud Functions, Cloud Run, Cloud Scheduler, Firebase Storage, Test Lab, Extensions, Google Maps API.

Pengganti gratis:
- Cascade delete → recursive delete dari klien (`lib/core/firestore/recursive_delete.dart`).
- Penjadwal notifikasi → `flutter_local_notifications` (utama) atau GitHub Actions cron + FCM HTTP v1 (opsional).
- Foto profil → file lokal di folder aplikasi.
- Peta faskes → OpenStreetMap (`flutter_map`, tanpa API key).

Bila suatu saat Cloud Functions tetap dibutuhkan, **baru** ikuti panduan billing: **Usage and billing** ➔ tautkan akun ➔ **Budgets & alerts** $1/bulan. Untuk UAS, langkah ini dilewati.

---

### 6. Ganti Kredensial Placeholder di Project Flutter (P1)

File `lib/firebase_options.dart` dan `android/app/google-services.json` di repo masih berisi **nilai placeholder**. Selama belum diganti, aplikasi (mode debug) akan menampilkan layar **"Konfigurasi Firebase belum benar"** dan tidak terhubung ke Firebase.

1. Pasang Firebase CLI (sekali saja):

   ```sh
   npm install -g firebase-tools
   firebase --version
   ```

2. Pasang FlutterFire CLI & login:

   ```sh
   dart pub global activate flutterfire_cli
   firebase login
   ```

3. Dari root project, tulis ulang konfigurasi untuk project **dev**:

   ```sh
   flutterfire configure --project=imunikita-dev-f --platforms=android,ios,web
   ```

   Perintah ini menimpa `lib/firebase_options.dart` **dan** `android/app/google-services.json` dengan kredensial asli.

4. Verifikasi di Android debug:

   ```sh
   flutter run --dart-define=ENV=dev
   ```

   Log harus memuat: `FirebaseBootstrap: Firebase siap (project imunikita-dev-f).`

5. (Opsional) Uji dengan emulator tanpa menyentuh cloud:

   ```sh
   firebase emulators:start --only auth,firestore
   flutter run --dart-define=ENV=dev --dart-define=USE_EMULATOR=true
   ```

> **Catatan**: `flutterfire configure` tidak mengubah `imunikita-prod-f`. Bila butuh build prod, jalankan ulang dengan `--project=imunikita-prod-f` lalu build memakai `--dart-define=ENV=prod`.

---

## 🏁 Output & Verifikasi
Setelah langkah di atas selesai dieksekusi:
- [ ] Project `imunikita-dev-f` aktif di Firebase Console dengan Auth, Firestore (`asia-southeast2`), dan FCM.
- [ ] `lib/firebase_options.dart` & `android/app/google-services.json` **bukan placeholder** (langkah 6).
- [ ] Log debug menampilkan `FirebaseBootstrap: Firebase siap (project imunikita-dev-f).`
- [ ] Lanjutkan ke **B1-Fix selesai** → **Tahap 2 (B2-1)**: `auth_remote_datasource.dart`.
