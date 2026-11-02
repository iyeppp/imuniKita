# 🔄 Konvensi Sinkronisasi Data & Manajemen Offline-First ImuniKita

- **Status**: 🟡 Menunggu Persetujuan Tim (*Pending Approval*)
- **Tanggal**: 30 Oktober 2026
- **Dokumen Referensi**: Tahap B0-5 Rencana Pengembangan Backend UAS

---

## 🎯 Prinsip Utama

Aplikasi ImuniKita mengadopsi pola **Local-First / Offline-First Architecture**. Pengalaman pengguna diutamakan agar aplikasi tetap cepat, responsif, dan dapat digunakan secara penuh tanpa ketergantungan pada koneksi internet.

---

## 📌 Aturan & Konvensi Teknis

### 1. Sumber Kebenaran Lokal (Local Source of Truth)
- Seluruh pembacaan data oleh Presentation Layer (UI/Riverpod Notifier) **selalu bersumber dari Hive CE lokal**.
- Operasi mutasi data (Tambah, Ubah, Hapus) **selalu ditulis ke Hive CE lokal terlebih dahulu**, sehingga UI diperbarui secara instan.

### 2. Strategi Document ID (UUID v4)
- Seluruh primary key entitas (`babyId`, `scheduleId`, `recordId`, `journalId`, `quizId`) wajib menggunakan string **UUID v4** yang di-generate pada sisi klien saat data pertama kali dibuat.
- String UUID ini dipakai secara konsisten sebagai **Firestore Document ID** (`users/{uid}/.../{docId}`).
- **Keuntungan**: Operasi penyimpanan ke Firestore menggunakan `set()` bersifat **idempoten** (aman dieksekusi berkali-kali tanpa risiko duplikasi data).

### 3. Penanganan Konflik Data (Last-Write-Wins via `updatedAt`)
- Seluruh model data domain wajib memiliki field timestamp `updatedAt` (`DateTime` / `Timestamp`).
- Jika terdapat perbedaan data antara lokal dan cloud saat pengunduhan (*pull*), data dengan nilai `updatedAt` paling baru yang digunakan (*Last-Write-Wins*).

### 4. Strategi Penghapusan Data (Delete via Outbox)
- Penghapusan data secara lokal akan mendaftarkan operasi `DELETE` ke dalam antrean outbox (`SyncQueue`).
- Saat proses pengunduhan (*pull*), klien akan memfilter dan mengabaikan dokumen cloud jika `entityId` dokumen tersebut masih berada dalam antrean `DELETE` lokal (mencegah data yang telah dihapus offline muncul kembali / *ghost data*).

### 5. Antrean Mutasi Offline (`SyncQueue` Outbox)
- Setiap operasi mutasi ke cloud yang gagal akibat ketiadaan koneksi internet dimasukkan ke dalam Hive box khusus `syncOutboxBox` (`SyncOperationModel`, `typeId: 6`).
- Begitu koneksi internet pulih (`Connectivity`), `SyncQueue` akan mengeksekusi secara berurutan seluruh antrean (*drain*) menggunakan strategi *exponential backoff*.

### 6. Isolasi Data Berbasis Pengguna (`userId`)
- Seluruh data transaksi di Firestore diorganisasikan di bawah hierarki `users/{uid}/...`.
- Keamanan data dijamin melalui Firestore Security Rules berbasis `request.auth.uid == uid`.

---
*Dokumen konvensi ini wajib dipahami oleh seluruh tim sebelum memasuki Tahap 1 (Koding Foundation).*
