# ImuniKita REST API Server (Node.js + TypeScript + Express)

Backend REST API untuk menyajikan konten edukasi (artikel, video, kuis), direktori fasilitas kesehatan, serta proxy LLM AI Chatbot ImuniKita (Tahap 8).

---

## 🚀 Cara Menjalankan Server Lokal

### 1. Instalasi Dependency
```bash
cd backend/api
npm install
```

### 2. Konfigurasi Environment (`.env`)
Salin berkas `.env.example` menjadi `.env`:
```bash
cp .env.example .env
```

Isi variabel environment sesuai kebutuhan:
- `PORT`: Port server (default: `3000`).
- `GEMINI_API_KEY`: API Key Google Gemini (opsional — jika kosong, chatbot otomatis memakai fallback 31 aturan kata kunci medis ImuniKita).
- `GOOGLE_APPLICATION_CREDENTIALS`: Path ke file Service Account JSON Firebase (opsional — jika belum dipasang, server berjalan dalam mode demo lokal).

### 3. Menjalankan Server
Mode Pengembangan (*Hot Reload*):
```bash
npm run dev
```

Server akan berjalan di `http://localhost:3000`.

Akses dari Emulator Android memakai URL:
`http://10.0.2.2:3000`

---

## 🔒 Konfigurasi Firebase Service Account (Opsional)

Untuk memverifikasi Firebase ID Token secara riil di backend:
1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Masuk ke **Project Settings** > **Service accounts**.
3. Klik **Generate new private key**, lalu simpan file `.json` tersebut di folder `backend/api/service-account.json`.
4. Pastikan path di `.env` mengarah ke file tersebut:
   ```env
   GOOGLE_APPLICATION_CREDENTIALS=./service-account.json
   ```

---

## 📋 Endpoints

- `GET /healthz` — Health check server
- `GET /v1/education/articles?kategori=` — Daftar artikel edukasi
- `GET /v1/education/videos?kategori=` — Daftar video edukasi
- `GET /v1/education/quizzes` — Daftar kuis edukasi
- `GET /v1/faskes?kota=&tipe=` — Direktori fasilitas kesehatan
- `POST /v1/chatbot/messages` — Proxy AI Chatbot ImuniKita
