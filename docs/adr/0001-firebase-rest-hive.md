# ADR 0001: Strategi Arsitektur Backend — Hybrid Firebase, REST API & Local-First Hive CE

- **Status**: 🟡 Menunggu Persetujuan Tim (*Pending Approval*)
- **Tanggal**: 30 Oktober 2026
- **Revisi**: 12 November 2026 — seluruh layanan berbayar (Storage, Functions, Cloud Run/Scheduler, Maps) dihapus; solusi diganti versi gratis.
- **Pengambil Keputusan**: Tim Pengembang Backend ImuniKita

---

##  Context & Problem Statement

Pada fase UTS, aplikasi ImuniKita menggunakan penyimpanan lokal penuh berbasis Hive CE dan SharedPreferences. Untuk fase UAS, aplikasi harus mendukung sinkronisasi data multi-device, autentikasi cloud yang aman, penyimpanan foto anak (lokal di perangkat), konten dinamis (edukasi & faskes), serta konsultasi AI Chatbot tanpa mengubah antarmuka pengguna (*Presentation Layer*) yang sudah ada (19 screen + 10 shared widgets). Seluruh solusi wajib berjalan pada **Firebase Spark (gratis)** tanpa verifikasi kartu kredit.

##  Decision Drivers

1. **Prinsip Swap Data Source**: Presentation layer dan domain logic tidak diubah; hanya memaintain/menambah Data Source dan Repository Impl.
2. **Offline-First & Resiliensi Jaringan**: Aplikasi harus tetap berfungsi 100% saat tidak ada koneksi internet (Hive CE sebagai cache/source of truth lokal).
3. **Keamanan Kredensial & Secrets**: Kredensial pengguna tidak boleh disimpan manual di Hive, dan API Key LLM Chatbot tidak boleh ada di APK/klien.
4. **Efisiensi & Batasan Kuota**: Menggunakan region terdekat (`asia-southeast2` Jakarta) dan mengoptimalkan kuota gratis Firebase.

## 💡 Decided Options

### 1. Firebase Authentication
- Digunakan untuk penanganan registrasi, login email/password, dan token sesi (`Firebase ID Token`).
- Password tidak disimpan sama sekali di Hive/SharedPreferences lokal.

### 2. Cloud Firestore (Region: `asia-southeast2` Jakarta)
- Digunakan untuk data domain anak, jadwal imunisasi, pertumbuhan, jurnal kesehatan, dan skor kuis.
- **Struktur Subkoleksi**: Seluruh koleksi pengguna ditempatkan di bawah `users/{uid}/...` untuk menyederhanakan Security Rules (*owner-only*).
- **Document ID**: Menggunakan UUID yang sudah ada (`babyId`, `scheduleId`, `recordId`, `journalId`, `quizId`) untuk menjamin operasi `set()` bersifat idempoten.

### 3. Hive CE (Local Database & Cache)
- Tetap dipertahankan sebagai penyimpanan lokal utama (*Offline-First*).
- Pembacaan UI selalu memprioritaskan cache lokal Hive CE agar antarmuka cepat dan bebas hambatan jaringan.
- Foto profil anak menggunakan path gambar lokal di perangkat (`fotoProfilPath`), tanpa memerlukan service Firebase Storage.

### 4. Custom REST API (Node.js + Express/Hono & Dio)
- Digunakan untuk menyajikan konten dinamis (artikel, video, kuis, faskes) dan sebagai proxy aman untuk AI Chatbot agar API Key LLM berada di server (`.env`).
- Deploy ke **hosting gratis tanpa kartu kredit** (Cloudflare Workers / Vercel / Deno Deploy) atau jalankan lokal saat demo. **Cloud Run/Functions tidak dipakai.**
- Bila tim tidak ingin mengelola server: konten dapat disimpan sebagai koleksi Firestore read-only, dan chatbot memakai mock keyword yang sudah ada.

### 5. Notifikasi H-7 & H-1 (Tanpa Billing)
- Jalur utama: `flutter_local_notifications` + `zonedSchedule` (sudah ada). Berjalan lokal, offline, dan tetap muncul saat aplikasi tertutup.
- Jalur opsional: FCM HTTP v1 dipicu **GitHub Actions cron** dengan service account yang disimpan sebagai repository secret. Ini menghindari Cloud Functions/Cloud Scheduler yang memerlukan billing.

### 6. Batasan Tanpa Billing (Firebase Spark)
Layanan berikut **tidak digunakan** karena membutuhkan Blaze + verifikasi kartu kredit:
- Firebase Storage → foto anak disimpan lokal di folder aplikasi.
- Cloud Functions / Cloud Run / Cloud Scheduler → cascade delete dilakukan dari klien; penjadwal memakai GitHub Actions atau notifikasi lokal.
- Test Lab, Extensions, Google Maps API → tidak dipakai (peta tetap OpenStreetMap).

## 📈 Consequences & Trade-offs

- **Keuntungan**:
  - Presentation Layer (UI) tidak perlu di-rewrite.
  - Keamanan kredensial dan API key terjamin.
  - Pengguna tidak kehilangan kemampuan offline.
  - **Nol biaya**: seluruh layanan berada di free tier; tidak ada ketergantungan pada kartu kredit.
- **Tantangan / Risiko**:
  - Memerlukan outbox queue (`SyncQueue`) untuk menyimpan operasi mutation saat offline dan men-drain otomatis saat online.
  - Memerlukan strategi penanganan konflik *Last-Write-Wins* (LWW) berbasis timestamp `updatedAt`.
  - Cascade delete harus dilakukan klien (beberapa batch request) — lebih lambat daripada trigger server.
  - Foto profil tidak menyebar antar-device (batasan yang diterima).
  - FCM opsional bergantung pada jadwal GitHub Actions (bukan realtime server).

---
*Dokumen ini dibuat otomatis pada Tahap B0-3 dan menunggu persetujuan resmi tim.*
