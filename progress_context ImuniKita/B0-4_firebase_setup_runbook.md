# 🛠️ Runbook Manual Setup Firebase Console (Langkah B0-4 — Revisi Tanpa Storage)

> **Status**: 🟡 Menunggu Eksekusi Manusia (*Manual Execution Required*)  
> **Estimasi Waktu**: ±15–20 menit  
> **Target**: Menyiapkan environment `imunikita-dev` dan `imunikita-prod` di Firebase Console untuk layanan Auth, Firestore, dan FCM.

---

## 📌 Prasyarat
- Akun Google / Firebase Console ([console.firebase.google.com](https://console.firebase.google.com)).
- Browser web desktop.

---

## 📋 Langkah Eksekusi Manual (Step-by-Step)

### 1. Buat Project Firebase (2 Project)
1. Buka [Firebase Console](https://console.firebase.google.com).
2. Klik **Add Project** / **Tambah Proyek**:
   - Proyek 1: Beri nama **`imunikita-dev`** (Lingkungan Eksperimen & Dev).
   - Proyek 2: Beri nama **`imunikita-prod`** (Lingkungan Rilis / Produksi — *jangan digunakan untuk testing*).
3. Matikan / batalkan centang Google Analytics pada `imunikita-dev` (opsional, agar setup lebih cepat).
4. Klik **Create Project** / **Buat Proyek** dan tunggu hingga proses pembuatan selesai.

---

### 2. Konfigurasi Firebase Authentication (`imunikita-dev`)
1. Pilih project **`imunikita-dev`**.
2. Di menu navigasi kiri, buka **Build** ➔ **Authentication** ➔ klik **Get Started**.
3. Pilih tab **Sign-in method**.
4. Klik penyedia **Email/Password**:
   - Aktifkan toggle **Enable** pada opsi Email/Password.
   - Biarkan opsi *Email link (passwordless sign-in)* tetap **Disabled**.
5. Klik **Save**.

---

### 3. Konfigurasi Cloud Firestore (`imunikita-dev`)
1. Di menu navigasi kiri, buka **Build** ➔ **Firestore Database** ➔ klik **Create Database**.
2. **Aturan Keamanan (Security Rules)**:
   - Pilih mode awal **Start in test mode** (aturan ini akan digantikan secara otomatis oleh `firestore.rules` teruji pada Tahap 3).
3. **PILIHAN REGION (KRUSIAL)**:
   - Pada pilihan *Location* / *Region*, pilih **`asia-southeast2` (Jakarta)** dari daftar dropdown.
   - *Peringatan*: Region database tidak dapat diubah setelah database dibuat.
4. Klik **Enable** / **Buat**.

---

### 4. Verifikasi Cloud Messaging (FCM)
1. Klik ikon **Project Settings (Gigi Roda)** di sudut kiri atas navigasi ➔ **Project settings**.
2. Buka tab **Cloud Messaging**.
3. Pastikan **Firebase Cloud Messaging API (V1)** dalam status **Enabled** (bawaan aktif untuk project Firebase baru).

---

### 5. Pasang Billing & Budget Alert (< $1 / bulan)
1. Di Firebase Console, buka **Usage and billing** ➔ **Details & settings**.
2. Tautkan Billing Account (diperlukan bila menggunakan Cloud Functions kelak).
3. Masuk ke Google Cloud Billing Console ➔ **Budgets & alerts**.
4. Buat anggaran (*budget*) baru dengan nilai **$1.00 USD / bulan** dan aktifkan notifikasi email saat penggunaan mencapai 50%, 80%, dan 100%.

---

## 🏁 Output & Verifikasi
Setelah langkah di atas selesai dieksekusi:
- [ ] Project `imunikita-dev` aktif di Firebase Console dengan Auth, Firestore (`asia-southeast2`), dan FCM.
- [ ] Lanjutkan ke **Tahap 1 (B1-1)** untuk menjalankan FlutterFire CLI (`flutterfire configure --project=imunikita-dev`).
